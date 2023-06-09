.PHONY: clean build push start connect stop rm

help: ## display this help.
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

default: all ## default target is all.

all: clean install build ## make clean install build.

clean: ## clean.

build: ## build the image.
	@exec docker build \
		-t jupyterlabbenchmarks/jlab-base:latest \
		-f Dockerfile.base \
		--LabApp.token=''\
		.
	@exec docker build \
		-t jupyterlabbenchmarks/jlab-2-2-8:latest \
		-f Dockerfile.2-2-8 \
		.
	@exec docker build \
		-t jupyterlabbenchmarks/jlab-virtual-notebook:latest \
		-f Dockerfile.virtual-notebook \
		.
	@exec docker build \
		-t jupyterlabbenchmarks/jlab-virtual-notebook-window:latest \
		-f Dockerfile.virtual-notebook-window \
		.
	@exec docker build \
		-t jupyterlabbenchmarks/jlab-delayout:latest \
		-f Dockerfile.delayout \
		.

push: ## push the image.
	@exec docker push \
	    jupyterlabbenchmarks/jlab-base:latest
	@exec docker push \
	    jupyterlabbenchmarks/jlab-2-2-8:latest
	@exec docker push \
	    jupyterlabbenchmarks/jlab-virtual-notebook:latest
	@exec docker push \
	    jupyterlabbenchmarks/jlab-virtual-notebook-window:latest
	@exec docker push \
	    jupyterlabbenchmarks/jlab-delayout:latest

start-2-2-8: rm ## start the container.
	@exec docker run -it \
		-e JUPYTER_ENABLE_LAB=true \
		--rm \
		-d \
		--name jlab \
		-p 8888:8888 \
		jupyterlabbenchmarks/jlab-2-2-8:latest
	@exec sleep 1s
	make token
	make logs

start-virtual-notebook: rm ## start the container.
	@exec docker run -it \
		-e JUPYTER_ENABLE_LAB=true \
		--rm \
		-d \
		--name jlab \
		-p 8888:8888 \
		jupyterlabbenchmarks/jlab-virtual-notebook:latest
	@exec sleep 1s
	make token
	make logs

start-virtual-notebook-window: rm ## start the container.
	@exec docker run -it \
		-e JUPYTER_ENABLE_LAB=true \
		--rm \
		-d \
		--name jlab \
		-p 8888:8888 \
		jupyterlabbenchmarks/jlab-virtual-notebook-window:latest
	@exec sleep 1s
	make token
	make logs

start-delayout: rm ## start the container.
	@exec docker run -it \
		-e JUPYTER_ENABLE_LAB=true \
		--rm \
		-d \
		--name jlab \
		-p 8888:8888 \
		jupyterlabbenchmarks/jlab-delayout:latest
	@exec sleep 1s
	make token
	make logs

connect: ## connect to the container.
	@exec docker exec -it jlab bash

token: ## get the notebook token(s).
	@exec docker exec -it jlab jupyter notebook list

logs: ## show container logs
	docker logs jlab -f

attach:
	docker exec -it jlab bash

stop: ## stop the container.
	@exec docker stop jlab

rm: ## remove the container.
	docker rm -f jlab || true
