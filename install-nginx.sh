#!/bin/bash

# ========== Install Nginx ========== #

# Nginx
if ( which nginx >/dev/null ) 
then
    echo "Nginx Present"
else
    sudo apt update

    # Install signing dependencies
    sudo apt install -y curl gnupg2 ca-certificates lsb-release ubuntu-keyring

    # Add an official Nginx signing key
    curl https://nginx.org/keys/nginx_signing.key | gpg --dearmor |
        sudo tee /usr/share/keyrings/nginx-archive-keyring.gpg >/dev/null

    # Verify said key
    gpg --dry-run --quiet --no-keyring --import --import-options import-show /usr/share/keyrings/nginx-archive-keyring.gpg

    # Add Nginx to apt repository source list
    echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] \
    http://nginx.org/packages/ubuntu $(lsb_release -cs) nginx" |
        sudo tee /etc/apt/sources.list.d/nginx.list

    # Specify which repository to use
    echo -e "Package: *\nPin: origin nginx.org\nPin: release o=nginx\nPin-Priority: 900\n" |
        sudo tee /etc/apt/preferences.d/99nginx

    # Install
    sudo apt install -y nginx

    sudo systemctl start nginx
fi

# ========== Configure Nginx Server ========== #

# Copy relativepath.conf to /etc/nginx/sites-available directory.
if [ -f /etc/nginx/sites-available/quotes ] 
then
    echo "Server Config Already Copied"
else
    echo "Copying Server Config"
    sudo cp ~/server.conf /etc/nginx/sites-available/quotes
fi

# Check for old symlink to Nginx default site
if [ -L /etc/nginx/sites-enabled/default ]
then
    echo "Removing Old Server Config"
    sudo rm /etc/nginx/sites-enabled/default
fi

# Create symlink in /etc/nginx/sites-enabled directory
if [ -L /etc/nginx/sites-enabled/quotes ] 
then
    echo "Symlinks Properly Configured"
else
    sudo ln -s /etc/nginx/sites-available/quotes /etc/nginx/sites-enabled/quotes
fi

# Restart Nginx to apply changes
sudo systemctl reload nginx
