#CURRENT DIR FOR WINDOWS & UNIX SYSTEMS
CURRENT_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
SHELL=/bin/bash
VERSION=${shell cat VERSION}
DOMAIN :=laravel.local
PROJECT_FOLDER :=src
NGINX_CERTS_PATH :=${CURRENT_DIR}services/nginx/certs

#DEFAULT BEHAVIOR
all:build

.PHONY: build
build:install env docker/build-nc up

install:
	@chmod -R u+x "${CURRENT_DIR}scripts"
	$(SHELL) -c "${CURRENT_DIR}scripts/install-dependencies.sh"
	@mkdir -p src
	@make certs

env:
	@if [ ! -f ${CURRENT_DIR}.env ]; then cp ${CURRENT_DIR}.env.example ${CURRENT_DIR}.env; fi

.PHONY: clean
clean:
	@$(SHELL) -c "rm -rfv ${CURRENT_DIR}${PROJECT_FOLDER}/{*,.*} ||:"

certs:
	mkcert -cert-file ssl.crt \
		-cert-file ssl.crt \
		-key-file ssl.key \
		${DOMAIN}
	mkdir -p ${NGINX_CERTS_PATH}
	mv ssl.crt ${NGINX_CERTS_PATH}
	mv ssl.key ${NGINX_CERTS_PATH}
	$(SHELL) -c "${CURRENT_DIR}scripts/manage-etc-hosts.sh add ${DOMAIN}"


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
docker/restart: CND=restart
docker/destroy: CMD=down --rmi all --volumes --remove-orphans
docker/destroy-volumes: CMD=down --volumes --remove-orphans
docker/run: CMD=run --rm $(command)
docker/exec: CMD=exec $(command)
	
docker/ps docker/up docker/build docker/build-nc docker/stop docker/restart docker/down docker/destroy docker/destroy-volumes docker/run docker/exec:
	docker-compose ${CMD}

shell/nginx: CMD="nginx bash"
shell/php: CMD="php bash"
shell/db: CMD="db bash"
shell/redis: CMD="redis bash"

.PHONY: shell
shell shell/nginx shell/php shell/db shell/redis:
	@make docker/exec command=${CMD}

composer/install: ACTION=install
composer/update: ACTION=update
composer/require: ACTION=require $(packages)
composer/remove: ACTION=remove $(packages)
composer/dump-autoload: ACTION=dump-autoload
composer/install-laravel: ACTION=create-project --prefer-dist laravel/laravel .

laravel/install:docker/down clean composer/install-laravel up

.PHONY: composer
composer composer/install composer/update composer/require composer/remove composer/install-laravel composer/dump-autoload:
	@make docker/run command="composer ${ACTION}"


artisan/optimize: command=optimize:clear
artisan/tinker: command=tinker

.PHONY: artisan
artisan artisan/optimize artisan/tinker:
	@make docker/run command="artisan $(command)" 

npm/install: command=install
npm/update: command=update
npm/dev: command=run dev

.PHONY: npm
npm npm/install npm/update npm/dev:
	@make docker/run command="npm $(command)" 
