#!/bin/bash

node_mongo () { #function for installation of the Node.js and MongoDB
    node_version=$1 #taking the Node.js installation mode options like LTS, Current or Custom

    if [ $node_version == "lts" ]; then  # If mode is LTS then it will install Long Term Support version
        printf "\n->Installing Node.js LTS version"
        curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
        sudo apt-get install -y nodejs
        printf "\n->Installation of Node.js LTS is completed"
    fi

    if [ $node_version == "current" ]; then # If mode is Current then it will install latest version
        printf "\n->Installing Node.js Current version"
        curl -fsSL https://deb.nodesource.com/setup_current.x | sudo -E bash -
        sudo apt-get install -y nodejs
        printf "\n->Installation of Node.js Current is completed"
    fi

    if [ $node_version == "custom"]; then  # If mode is custom then it will install the user defined version
        n_version=$2 #if installation mode is custom then taking exact value of the version like 14.4.2
        printf "\n->Installing Node.js version $n_version"
        curl -fsSL https://deb.nodesource.com/setup_$n_version.x | sudo -E bash -
        sudo apt-get install -y nodejs
        printf "\n->Installation of Node.js $n_version is completed"
    fi

    printf "\n->Installing PM2" # Installation of the PM2 will be bonus
    sudo npm install pm2@latest -g
    printf "\nPM2 installation completed"

    printf "\n->Installing NGINX" # Installation of NGINX
    sudo apt-get install nginx -y
    printf "\nNGINX has been installed"
    
    printf "\n->Installing MongoDB v5.0" # Currently keeping the MongoDb version 5.0
    ubuntu_version=$(lsb_release -c)
    ubuntu_version_name=$(cut -f2 <<< "$ubuntu_version")
    wget -qO - https://www.mongodb.org/static/pgp/server-5.0.asc | sudo apt-key add -
    sudo mkdir -p /etc/apt/sources.list.d
    sudo touch /etc/apt/sources.list.d/mongodb-org-5.0.list
    echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu $ubuntu_version_name/mongodb-org/5.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-5.0.list
    sudo apt-get update
    sudo apt-get install mongodb-org -y
    sudo mkdir -p /data/db
    printf "\n->MongoDB installation is completed"

    printf "\n->Hurray!!! Node.js and MongoDB has been installed!"
}

lamp() { # function for the LAMP stack installation
    printf "\n->You've selected the LAMP setup"
    version=$1 # Taking the PHP version from the user side
    printf "\n->Installing Apache2"
    sudo apt-get install apache2 -y
    printf "\n->Apache2 has been installed"

    printf "\n->Installing PHP v$version"   # Installing the user defined version of the PHP
    sudo add-apt-repository ppa:ondrej/php
    sudo apt-get update 
    sudo apt-get install php$version -y
    sudo apt-get install php$version-cli  
    printf "\n->Installation of PHP v$version is completed"

    printf "\n->Installing MySQL" # Installing MySQL and initiate the mysql_secure_installation mode
    sudo apt-get install mysql-server -y
    sudo mysql_secure_installation
    printf "\n->MySQL has been installed"

    printf "\n->Installing phpMyAdmin" # Installing phpMyAdmin 
    sudo apt install phpmyadmin php-mbstring php-zip php-gd php-json php-curl
    sudo phpenmod mbstring
    sudo systemctl apache2 restart
    printf "\n->Installation of phpMyAdmin is completed"
    printf "\n->Hurray!!! LAMP setup has been finished!"
}

printf "*****************************************\nWelcome to the automated environment setup program\n\Created by Dharmit Saradva\n*****************************************"

printf "\nWhich environment do you want to proceed with?"
printf "\n[1] Node.js and MongoDB\n[2] LAMP (Apache2, MySQL and PHP)"
printf "\nEnter the number only:"
read choice

case $choice in # Based on the user's input, choice will be made of
    1)
        printf "\nWhich Node.js version do you want to install?"
        printf "\n [1] lts \n [2] current \n [3] custom"
        printf "\nEnter the order number only:"
        read node_choice # Taking the choice of the Node.js version installation mode
        if [ $node_choice -eq 1 ]; then
            node_mongo "lts" # Passing the argument value of the node.js version
        fi
        if [ $node_choice -eq 2 ]; then
            node_mongo "current"
        fi 
        if [ $node_choice -eq 3 ]; then
            printf "\nWhich custom version do you want to install?"
            read version
            node_mongo "custom" $version # Passing 2 arguments for custom mode
        fi
     ;;
    2)
        printf "\nWhich PHP version do you want to install?"
        printf "\nEnter exact version:" 
        read version
        lamp $version
     ;;
esac
# End of the installation script
# Thank you for using it!