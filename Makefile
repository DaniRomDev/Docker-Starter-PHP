#CURRENT DIR FOR WINDOWS & UNIX SYSTEMS
SHELL=/bin/sh
VERSION=${shell cat VERSION}
CURRENT_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
DOMAIN :=laravel.local

#DEFAULT BEHAVIOR
all:build

.PHONY: build
build:install env docker/build docker/up

install:
	@chmod -R u+x "${CURRENT_DIR}scripts"
	$(SHELL) -c "${CURRENT_DIR}scripts/install-dependencies.sh"
	$(SHELL) -c "${CURRENT_DIR}scripts/manage-etc-hosts.sh add ${DOMAIN}"
	@make certs

env:
	@if [ ! -f ${CURRENT_DIR}.env ]; then cp ${CURRENT_DIR}.env.example ${CURRENT_DIR}.env; fi

certs:
	mkcert -cert-file ssl.crt \
		-cert-file ssl.crt \
		-key-file ssl.key \
		${DOMAIN}
	mkdir -p ${CURRENT_DIR}services/nginx/certs
	mv ssl.crt ${CURRENT_DIR}services/nginx/certs
	mv ssl.key ${CURRENT_DIR}services/nginx/certs

up: docker/up
	@make ps
down: docker/down
	@make ps
ps: docker/ps
restart:docker/down docker/up
destroy:docker/destroy
	$(SHELL) -c "${CURRENT_DIR}scripts/manage-etc-hosts.sh remove ${DOMAIN}"

# DOCKER GENERIC COMMANDS
docker/ps: CMD=ps
docker/build: CMD=build
docker/build-nc: CMD=build --no-cache
docker/up: CMD=up -d
docker/stop: CMD=stop
docker/down: CMD=down --remove-orphans
docker/destroy: CMD=down --rmi all --volumes --remove-orphans
docker/destroy-volumes: CMD=down --volumes --remove-orphans
docker/run: CMD=run --rm $(command)
docker/exec: CMD=exec $(command)
	
docker/ps docker/up docker/build docker/build-nc docker/stop docker/down docker/destroy docker/destroy-volumes docker/run docker/exec:
	docker-compose ${CMD}

shell/nginx: CMD="nginx bash"
shell/php: CMD="php bash"
shell/db: CMD="db bash"
shell/redis: CMD="redis bash"

.PHONY: shell
shell shell/nginx shell/php shell/db shell/redis:
	@make docker/exec command=${CMD}

composer/install: ACTION="install"
composer/update: ACTION=update
composer/require: ACTION="require $(packages)"
composer/remove: ACTION="remove $(packages)"
composer/install-laravel: ACTION=create-project --prefer-dist laravel/laravel .

laravel/install:composer/install-laravel

.PHONY: composer
composer composer/install composer/update composer/require composer/remove composer/install-laravel:
	@make docker/run command="composer ${ACTION}"

.PHONY: artisan
artisan:
	@make docker/run command="artisan $(command)" 

