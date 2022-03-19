#!/bin/bash

if [ "$(uname)" == "Darwin" ]; then
    command -v brew >/dev/null 2>&1 || {
        echo >&2 "Detected MacOs System, Installing Homebrew Now"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
    }

    brew tap homebrew/cask-versions
    brew install curl wget mkcert nss docker docker-compose 

    export HOST_UID=$(id -u) && export HOST_GID=$(id -g)

elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ] || [ "$(uname)" == "cygwin"]; then
    sudo apt update
    sudo apt install curl wget libnss3-tools -y

    if ! which mkcert; then
        wget https://github.com/FiloSottile/mkcert/releases/download/v1.4.3/mkcert-v1.4.3-linux-amd64
        sudo mv mkcert-v1.4.3-linux-amd64 /usr/bin/mkcert
        sudo chmod +x /usr/bin/mkcert
        mkcert --version
    fi

    if ! which docker || ! which docker-compose; then
        sudo apt install docker docker-compose -y
    fi
    
    sudo apt autoremove --purge

elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW32_NT" ] || [ "$(expr substr $(uname -s) 1 10)" == "MINGW64_NT" ]; then
    echo -e "$(tput setaf 1) We recommend use WSL on Windows but if you don't want to, you need to install docker manually, more info on $(tput setaf 2)https://docs.docker.com/docker-for-windows/install/"
else
    echo -e "$(tput setaf 1) All dependencies are up to date, continuing with the build process..."
fi
