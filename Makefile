all:
	docker build -t nx .
	docker run -v $$PWD/pytorch_artefacts:/opt/mount --rm -ti nx:latest bash -c "cp /pytorch-lib-*.tar.gz /opt/mount/"

