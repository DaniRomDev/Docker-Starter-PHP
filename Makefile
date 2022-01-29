#CURRENT DIR FOR WINDOWS & UNIX SYSTEMS
current-dir := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
SHELL=/bin/sh
VERSION=${shell cat VERSION}

#DEFAULT BEHAVIOR
all:build

env:
	@if [ ! -f ${current-dir}.env ]; then cp ${current-dir}.env.example ${current-dir}.env; fi

build:env docker/build
	@docker-compose ps

restart:docker/down docker/up
destroy:docker/destroy

# DOCKER GENERIC COMMANDS
docker/build: CMD=build
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
shell/composer: CMD="composer bash"

shell/nginx shell/php shell/db shell/redis shell/composer:
	@make docker/exec command=${CMD}

composer/install: ACTION="install"
composer/update: ACTION=update
composer/require: ACTION="require $(packages)"
composer/remove: ACTION="remove $(packages)"
composer/install-laravel: ACTION="create-project --prefer-dist laravel/laravel ."

composer/install composer/update composer/require composer/remove composer/install-laravel:
	@make docker/run command="composer ${ACTION}"

laravel/install:composer/install-laravel
