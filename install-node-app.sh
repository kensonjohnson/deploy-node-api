#!bin/bash

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

# ========== Clone and Setup WebApp ========== #

# Look for directory in expected path
if [! -d ~/webapp]; then
    # Directory not present: clone repo, install node packages, and build frontend (React)
    git clone https://github.com/kensonjohnson/vite-express-project.git ~/webapp
    pushd ~/webapp
    npm install
    npm run build
    popd
fi
