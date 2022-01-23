include .env

help:
	@echo "Available Commands (USAGE: make <Command>)"
	@echo "-------------------"
	@echo "DOCKER RELATED:"
	@echo "     up               Up all the containers in detach mode"
	@echo "     build            Build images in --no-cache mode"
	@echo "     stop             Stop executing all the containers"
	@echo "     down             Remove the networks and stop the containers"
	@echo "     restart          Restart the containers and rebuild then if changes detected"
	@echo "     destroy          Destroy containers, remove network and volumes created and free disk space"
	@echo "     destroy-volumes  Destroy only the volumes"
	@echo "-------------------"
	@echo "LARAVEL/PHP RELATED:"
	@echo "     create-project   		 	Build the containers and install laravel packages"
	@echo "     laravel-install  	 	    Download latest version of laravel official repository"
	@echo "     post-install     			Run migrations and install npm packages inside laravel project"
	@echo "     build-project   			Build and existing laravel project inside the folder defined on .env file"
	@echo "     install-recommend-packages  Install recommended packages for new laravel projects"
	@echo "     composer-install   			Install via composer the packages and run artisan:optimize after" 
	@echo "     artisan-key  				Generate new app key via artisan"
	@echo "     optimize					Generate new app key via artisan"
	@echo "     run-migrations 			    Run database migrations and seeds"
	@echo "     npm-install 				NPM install auditing packages"

# DOCKER GENERIC COMMANDS
up:
	docker-compose up -d 
build:
	docker-compose build 
stop:
	docker-compose stop
down:
	docker-compose down --remove-orphans
restart:
	@make down
	@make up
destroy:
	docker-compose down --rmi all --volumes --remove-orphans
destroy-volumes:
	docker-compose down --volumes --remove-orphans

# LARAVEL COMMANDS
create-project:
	@make build
	@make up
	@make laravel-install
laravel-install:
	@echo "INSTALLING LARAVEL PROJECT ON FOLDER: ${PROJECT_FOLDER}"
	docker-compose run --rm composer create-project --prefer-dist laravel/laravel .
post-install:
	@make install-recommend-packages
	@make run-migrations
	@make optimize
	@make npm-install
build-project:
	@make build
	@make up
	@make composer-install
	@make artisan-key
install-recommend-packages:
	docker-compose run --rm composer require doctrine/dbal bepsvpt/secure-headers predis/predis barryvdh/laravel-dompdf
composer-install:
	docker-compose run --rm composer install --ignore-platform-reqs
	@make optimize
artisan-key:
	docker-compose run --rm artisan key:generate
optimize:
	docker-compose run --rm artisan optimize:clear
run-migrations:
	docker-compose run --rm artisan migrate:fresh --seed
npm-install:
	docker-compose run npm set progress=false
	docker-compose run npm install --no-fund
	docker-compose run npm audit fix
	docker-compose run npm run dev
