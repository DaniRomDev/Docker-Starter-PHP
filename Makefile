#CURRENT DIR FOR WINDOWS & UNIX SYSTEMS
current-dir := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
SHELL=/bin/sh
VERSION=${shell cat VERSION}
DOMAIN=laravel.local

#DEFAULT BEHAVIOR
all:build


build:install env docker/build docker/up

install:
	$(SHELL) -c "${current-dir}scripts/install-dependencies.sh"
	$(SHELL) -c "${current-dir}scripts/manage-etc-hosts.sh addhost ${DOMAIN}"
	@make certs

env:
	@if [ ! -f ${current-dir}.env ]; then cp ${current-dir}.env.example ${current-dir}.env; fi

certs:
	mkcert -cert-file ${DOMAIN}.crt \
		-cert-file ${DOMAIN}.crt \
		-key-file ${DOMAIN}.key \
		${DOMAIN}
	mkdir -p {current-dir}/services/nginx/certs
	mv ${DOMAIN}.crt {current-dir}/services/nginx/certs
	mv ${DOMAIN}.key {current-dir}/services/nginx/certs

up: docker/up
restart:docker/down docker/up
destroy:docker/destroy
	$(SHELL) -c "${current-dir}scripts/manage-etc-hosts.sh removehost ${DOMAIN}"

# DOCKER GENERIC COMMANDS
docker/build: CMD=build --no-cache
docker/up: CMD=up -d
docker/stop: CMD=stop
docker/down: CMD=down --remove-orphans
docker/destroy: CMD=down --rmi all --volumes --remove-orphans
docker/destroy-volumes: CMD=down --volumes --remove-orphans
docker/run: CMD=run --rm $(command)
docker/exec: CMD=exec $(command)
	
docker/up docker/build docker/stop docker/down docker/destroy/ docker/destroy-volumes docker/run docker/exec:
	docker-compose ${CMD}

shell/nginx: CMD="nginx bash"
shell/php: CMD="php bash"
shell/db: CMD="db bash"
shell/redis: CMD="redis bash"

shell/nginx shell/php shell/db shell/redis:
	@make docker/exec command=${CMD}

composer/install: ACTION="install"
composer/update: ACTION=update
composer/require: ACTION="require $(packages)"
composer/remove: ACTION="remove $(packages)"
composer/install-laravel: ACTION="create-project --prefer-dist laravel/laravel ."

composer/install composer/update composer/require composer/remove composer/install-laravel:
	@make docker/run command="composer ${ACTION}"

laravel/install:composer/install-laravel
