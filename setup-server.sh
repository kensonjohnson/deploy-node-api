#!/bin/bash

# ========== Setup Dependencies ========== #

# Git
if (! which git >/dev/null); then
    sudo apt install git -y
fi

# Node
if (! which node >/dev/null); then
    curl -fsSL https://deb.nodesource.com/setup_19.x | sudo -E bash -
    sudo apt install -y nodejs
fi

# Nginx
if (! which nginx >/dev/null); then
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
if [! -f /etc/nginx/sites-available/quotes ]; then
    sudo cp ~/server.conf /etc/nginx/sites-available/quotes
fi

# Check for old symlink to Nginx default site
if [ -L /etc/nginx/sites-enabled/default ]; then
    sudo rm /etc/nginx/sites-enabled/default
fi

# Create symlink in /etc/nginx/sites-enabled directory
if [ -L /etc/nginx/sites-enabled/quotes ]; then
else
    sudo ln -s /etc/nginx/sites-available/quotes /etc/nginx/sites-enabled/quotes
fi

# Restart Nginx to apply changes
sudo systemctl reload nginx

# ========== Clone and Setup WebApp ========== #

# Look for directory in expected path
if [! -d ~/webapp]; then
    # Directory not present:
    # Clone repo, install node packages, and build frontend (React)
    git clone https://github.com/kensonjohnson/vite-express-project.git ~/webapp
    pushd ~/webapp
    npm install
    npm run build
    popd
fi
