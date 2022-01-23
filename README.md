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
  - [Windows](#windows)
  - [Unix based systems](#unix-based-systems)
- [Makefile](#makefile)
  - [Environment root file _(.env)_](#environment-root-file-env)
  - [List of available commands](#list-of-available-commands)
    - [Create fresh laravel project](#create-fresh-laravel-project)
    - [Working with containers](#working-with-containers)
  - [Use Https and Custom domain on your local environment](#use-https-and-custom-domain-on-your-local-environment)
    - [Post installation](#post-installation)
- [Installed Packages on Post-Install](#installed-packages-on-post-install)
  - [Secure headers](#secure-headers)
  - [Predis](#predis)
  - [Laravel-DOMPDF](#laravel-dompdf)

# Features

- #### Create your laravel environment in no time, **focus on your idea.**
- #### Share your site with [ngrok](https://ngrok.com/)
- #### Easily customizable via **.env** files
- #### Minimal stack to avoid opinionated setups
- #### (Optional )Nginx configuration have SSL implemented, just add a self certificate
- #### You can add more services in docker-compose.yml without problem

# Prerequisites

[Needs docker](https://www.docker.com/products/docker-desktop)
In order to use make utils that allow us execute the Makefile commands, depending on your OS system it will be installed in one way or another.

**_Note: You can use the commands without make utils and ignore Makefile but we recommend use it for reasons of convenience_**

## Windows

- Install [Chocolatey package manager](https://chocolatey.org/install)
- Once installed run: `sh choco install make`

## Unix based systems

Normally is installed by default but if for whatever reason you don't have it, just install the build-essential package via terminal.

```sh
# DEBIAN based
sudo apt install build-essential

# CentOS and others that use yum
yum install make
```

# Makefile

## Environment root file _(.env)_

Copy the **.env.example** and create new file called **.env**. Docker compose use this file values to build the containers. Do this in a manual way or run in the root:

```sh
cp .env.example .env
```

And feel free to modify them to your liking.

## List of available commands

```sh
make help
```

### Create fresh laravel project

```sh
make create-project
```

### Working with containers

```sh
# For local environment setup

make up # Start the containers
make down # To turn down completely
make restart # To restart all the containers

make destroy # To destroy them if you need a complete rebuild

# Using Artisan & Compose
docker compose run --rm artisan # your command here...
docker compose run --rm compose # your command here...

#Examples
docker compose run --rm artisan migrate:fresh --seed
docker compose run --rm composer require predis/predis doctrine/dbal
```

You can create aliases to make work with containers in an easy way, this step is optional:

```sh
source create-command-alias.sh

# or run the commands on console

#! /bin/bash

alias _artisan='docker-compose run --rm artisan'
alias _composer='docker-compose run --rm composer'
alias _npm='docker-compose run --rm npm'
```

## Use Https and Custom domain on your local environment

_(Source on detail: https://hackerrdave.com/https-local-docker-nginx/)_

- Edit /etc/hosts and add your own custom domain for 127.0.0.1
- Install mkcert on your machine
- Run mkcert -install
- mkcert -key-file ssl.key -cert-file ssl.crt **yourcustomdomain.local**
- Create inside nginx folder another one with the name of 'certs'
- Move on this one the files that mkcert creates for you (ssl.crt and ssl.key)
- Go to https://yourcustomdomain.local to see the certificate working

### Post installation

Once installed you need to fill **.env** values inside root laravel folder to get it running. The values exposed below are just for example purposes, feel free to change them according to your \*_docker-compose.yml_ configuration.

```env
# DATABASE (This values comes from the docker-compose.yml)
DB_CONNECTION=mysql
DB_HOST=db # docker container
DB_PORT=3306 # The exposed port from db container
DB_DATABASE=laravel-db
DB_USERNAME=laravel
DB_PASSWORD=secret

# REDIS RELATED OPTIONS
REDIS_CLIENT=predis # We use the package predis/predis so we need to select this client.
REDIS_HOST=redis  # docker container
REDIS_PORT=6379 # The exposed port defined on root .env
CACHE_DRIVER=redis
QUEUE_CONNECTION=redis

# MAIL
*Free to change this values, this defined below are just for example purpose*
MAIL_FROM_ADDRESS=admin@laravel.com
MAIL_FROM_NAME=Laravel-App

```

Once configured you can execute post installation script with:

```sh
make post-install
```

# Installed Packages on Post-Install

Once the command is executed, some recommended packages have been installed in the process, this are useful for 95% of the cases but nothing stop you to remove them.

If you want to keep them _(100% recommended)_, just configure with the steps presented below:

## [Secure headers](https://github.com/BePsvPT/secure-headers)

Add an extra security layer for incoming requests easy to configure.

Publish config file

```sh
php artisan vendor:publish --provider="Bepsvpt\SecureHeaders\SecureHeadersServiceProvider"
```

Add global middleware in `app/Http/Kernel.php`

```php
\Bepsvpt\SecureHeaders\SecureHeadersMiddleware::class,
```

Set up config file `config/secure-headers.php` _(You can leave the default one)_

And done!

## Predis

We use package predis/predis as redis client recommended from the [official laravel docs](https://laravel.com/docs/8.x/redis#predis), in file **.env.example** you can see the **REDIS*CLIENT=\_predis***, just remove this line and remove the package from **composer.json** if you do not intend to use it or would like an alternative.

## [Laravel-DOMPDF](https://github.com/barryvdh/laravel-dompdf)

What application sooner or later does not have to deal with PDFs? this one is pretty good and we recommend it without doubt.

After updating composer, add the ServiceProvider to the providers array in config/app.php

    Barryvdh\DomPDF\ServiceProvider::class,

You can optionally use the facade for shorter code. Add this to your facades:

    'PDF' => Barryvdh\DomPDF\Facade::class,
