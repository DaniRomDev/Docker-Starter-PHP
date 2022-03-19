<div align="center">
  <h1 style="margin: 0;">Docker-Starter-Laravel</h1>
  <img width="100" height="100" src="https://logopng.com.br/logos/docker-27.png" alt="docker" />
  <img width="100" height="100" src="https://upload.wikimedia.org/wikipedia/commons/thumb/9/9a/Laravel.svg/1200px-Laravel.svg.png" alt="laravel" />
  <p>A minimalistic docker environment for Laravel projects without over-engineering and easily customizable.</p>
</div>

# Table of contents

- [Table of contents](#table-of-contents)
- [Features](#features)
- [Prerequisites](#prerequisites)
  - [Make tool](#make-tool)
    - [Windows](#windows)
        - [WSL 2](#wsl-2)
    - [Unix based systems](#unix-based-systems)
- [Makefile](#makefile)
  - [Makefile variables](#makefile-variables)
  - [Environment root file _(.env)_](#environment-root-file-env)
  - [Build and get running the local dev environment](#build-and-get-running-the-local-dev-environment)
    - [Create fresh laravel project](#create-fresh-laravel-project)
    - [Post Laravel installation](#post-laravel-installation)
    - [Working with containers](#working-with-containers)
  - [Use HTTPS and Custom domain on your local environment](#use-https-and-custom-domain-on-your-local-environment)
    - [Disable HTTPS support on local environment](#disable-https-support-on-local-environment)

# Features

- #### Create your laravel environment in no time, **focus on your idea.**
- #### Share your site with [ngrok](https://ngrok.com/)
- #### Easily customizable via **.env** files
- #### Minimal stack to avoid opinionated setups
- #### Nginx configuration have SSL implemented, automatically created on initial build
- #### You can add more services in docker-compose.yml without problem
- #### No more permissions conflict while creating files inside containers

# Prerequisites

---

## Make tool

### Windows

- Install [Chocolatey package manager](https://chocolatey.org/install)
- Once installed run: `sh choco install make`

##### WSL 2

We strongly recommend using Ubuntu as a subsystem when it comes to work as programmer on windows environments, it will save you a lot of trouble in the future. Here we give you the best resources to prepare the setup on your Windows system.
[How to setup the perfect development environment for windows](https://char.gd/blog/2017/how-to-set-up-the-perfect-modern-dev-environment-on-windows)
[Window 10 for web dev](https://fireship.io/lessons/windows-10-for-web-dev)
[Window terminal preview](https://www.microsoft.com/en-us/p/windows-terminal-preview/9n0dx20hk701?activetab=pivot:overviewtab#)

---

### Unix based systems

Usually is installed by default but if for whatever reason you don't have it, just install the build-essential package via terminal.

```sh
# DEBIAN based
sudo apt install build-essential

# CentOS and others that use yum
yum install make
```

# Makefile

This file help us to abstract the layer that interacts with your application in a standard way without needed to touch docker directly.

The default make command install automatically the dependencies needed to raise the local development environment and modify your **/etc/hosts** to setup your custom domain that you're plan to use for HTTPS, because of this you need to provide your user password in order to execute commands as **'sudo'** _(don't hesitate to check the bash scripts to make sure there is no malicious code)_.

**_Note: If you're using WSL you need to manually edit the /etc/hosts on your Window OS to setup the custom domain_**.

## Makefile variables

```sh
#CURRENT DIR FOR WINDOWS & UNIX SYSTEMS
CURRENT_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
SHELL=/bin/bash
VERSION=${shell cat VERSION}
DOMAIN :=laravel.local
PROJECT_FOLDER :=${CURRENT_DIR}src
DOCKER_PATH :=${CURRENT_DIR}docker
NGINX_CERTS_PATH :=${DOCKER_PATH}/nginx/certs

```

## Environment root file _(.env)_

Default configuration variables to be used on ` docker-compose.yml`, feel free to modify them to fit your requisites.

```sh
APP_USER=laravel

CONTAINER_PREFIX=laravel-app
NGINX_INTERNAL_PORT=80

DB_PORT=3306
DB_NAME=laravel_db
DB_USER=laravel
DB_USER_PASSWORD=secret
DB_ROOT_PASSWORD=secret
DB_ALLOW_EMPTY_PASSWORD=yes

NGROK_PROTOCOL=http
NGROK_TOKEN=# When you create a ngrok account you only need to provide your token here
NGROK_REGION=eu
```

## Build and get running the local dev environment

```sh
make or make build
```

### Create fresh laravel project

```sh
# Be sure to build the docker environment first
make install-laravel
```

### Post Laravel installation

Once installed you need to fill **.env** values inside src laravel folder to point to the containers and start using the database, mail interceptor, redis, etc.

```sh
APP_NAME=Laravel
APP_ENV=local
APP_KEY=base64:UmTYomiL4uePMyVQYo0NWxAKMfDJtdenq4I380KE9y0=
APP_DEBUG=true
APP_URL=https://laravel.local # Your custom domain selected here or https://localhost:8080

LOG_CHANNEL=stack
LOG_DEPRECATIONS_CHANNEL=null
LOG_LEVEL=debug

DB_CONNECTION=db # The docker container for database
DB_HOST=mysql
DB_PORT=3306
# This values are defined on the root .env file
DB_NAME=laravel_db
DB_USER=laravel
DB_USER_PASSWORD=secret
DB_ROOT_PASSWORD=secret
DB_ALLOW_EMPTY_PASSWORD=yes

BROADCAST_DRIVER=log
CACHE_DRIVER=file
FILESYSTEM_DRIVER=local
QUEUE_CONNECTION=sync
SESSION_DRIVER=file
SESSION_LIFETIME=120

MEMCACHED_HOST=127.0.0.1

REDIS_HOST=redis
REDIS_PASSWORD=null
REDIS_PORT=6379

MAIL_MAILER=smtp
MAIL_HOST=mailhog # Docker container to intercept emails
MAIL_PORT=1025
#Feel free to fill this ones with the values that makes sense for your app
MAIL_USERNAME=laravel
MAIL_PASSWORD=null
MAIL_ENCRYPTION=TLS
MAIL_FROM_ADDRESS=laravel@docker-starter.com
MAIL_FROM_NAME="${APP_NAME}"

AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
AWS_DEFAULT_REGION=us-east-1
AWS_BUCKET=
AWS_USE_PATH_STYLE_ENDPOINT=false

PUSHER_APP_ID=
PUSHER_APP_KEY=
PUSHER_APP_SECRET=
PUSHER_APP_CLUSTER=mt1

MIX_PUSHER_APP_KEY="${PUSHER_APP_KEY}"
MIX_PUSHER_APP_CLUSTER="${PUSHER_APP_CLUSTER}"

```

### Working with containers

**_For full documentation open the Makefile and see all the commands available_**

```sh
# For local environment setup

make up # Start the containers
make down # To turn down completely
make restart # To restart all the containers

make destroy # To destroy them if you need a complete rebuild

make shell/php # Bash session inside php container (to use artisan commands, composer, npm, etc.)
```

## Use HTTPS and Custom domain on your local environment

_(Source on detail: https://hackerrdave.com/https-local-docker-nginx/)_

This process is automatically made on the build but if you want to manually run it just do:

```sh
make certs
```

### Disable HTTPS support on local environment

If for any reason you don't want to use the https port on your nginx server, just comment out the server block for 443 port
on file before build the containers

```sh:docker/nginx/default.conf
# COMMENT THIS PART
server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;

    ssl_certificate /etc/nginx/ssl/ssl.crt;
    ssl_certificate_key /etc/nginx/ssl/ssl.key;
    ssl_protocols TLSv1.2;

    server_name localhost *.ngrok.io;
    index index.php index.html index.htm;
    error_log  /var/log/nginx/error.log;
    access_log /var/log/nginx/access.log;
    root /var/www/html/public;

    location ~ \.php$ {
        try_files $uri =404;
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass php:9000;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_param PATH_INFO $fastcgi_path_info;
    }
    location / {
        proxy_set_header Host $http_host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        try_files $uri $uri/ /index.php?$query_string;
        gzip_static on;
    }
}
```
