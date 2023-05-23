#!bin/bash

# ========== Setup Dependencies ========== #

# Git
if (! which git >/dev/null); then
    sudo apt install git -y
fi

# Fast Node Manager (fnm)
if (! which fnm >/dev/null); then
    # Install dependencies
    sudo apt install curl unzip

    # Download and run script for fnm
    curl -fsSL https://fnm.vercel.app/install | bash
    source source ~/.bashrc
fi

# Node
if (! which node >/dev/null); then
    # --lts installs the current Long Term Support version
    fnm install --lts
fi
