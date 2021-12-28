FROM elixir:latest as builder

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
      cmake python3-dev python3-pip \
    && rm -rf /var/lib/apt/lists/*

RUN pip3 install typing_extensions pyaml

RUN git clone -b master --recurse-submodule https://github.com/pytorch/pytorch.git /pytorch
RUN mkdir /pytorch-build && cd /pytorch-build
RUN cmake -DBUILD_SHARED_LIBS:BOOL=ON -DCMAKE_BUILD_TYPE:STRING=Release -DPYTHON_XECUTABLE:PATH=`which python3` -DCMAKE_INSTALL_PREFIX:PATH=../pytorch-install ../pytorch
RUN cmake --build . --target install
RUN (cd /pytorch-install && tar -zcf "/pytorch-lib-`arch`.tar.gz" *)
RUN rm -rf /pytorch

FROM elixir:latest

COPY --from=builder /pytorch-install/ /pytorch-lib/
COPY --from=builder /pytorch-lib-*.tar.gz /

ENV LIBTORCH_DIR="/pytorch-lib"

RUN apt-get update \
    && apt-get install -y --no-install-recommends cmake \
    && rm -rf /var/lib/apt/lists/*

RUN mix local.hex --force && \
    mix local.rebar --force

RUN git clone https://github.com/elixir-nx/nx.git /nx \
    && (cd /nx && make)
