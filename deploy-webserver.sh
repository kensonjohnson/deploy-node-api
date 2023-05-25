#!/bin/bash

# ========== Setup Dependencies ========== #

# rsync

# SSH keys
if [ -f id_ed25519 ]; 
then
    echo "SSH Keys Found"
else
    # Keys not present
    echo "Setting up SSH Keys..."
    ssh-keygen -t ed25519 -q -f id_ed25519 -C "developer@relative.path" -N ""
fi

# Cloud-Init
if [ -f cloud-init.yaml ] 
then
    echo "Cloud Init OK"
else
    # cloud-init.yaml not present
    echo "Generating Cloud Init File..."
    cat <<-EOF >cloud-init.yaml
users:
  - default
  - name: developer
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
    ssh_authorized_keys:
      - $(cat id_ed25519.pub)
EOF
fi

# Snap
if ( which snap > /dev/null ) 
then
    echo "Snap Present"
else
    # Snap not present
    echo "Installing Snap Package Manager..."
    sudo apt update && sudo apt install snapd
fi

# Multipass
if ( multipass version > /dev/null ) 
then
    echo "Multipass Present"
else
    # Multipass not present
    echo "Installing Multipass..."
    sudo snap install multipass
fi

# ========== Create or Start VM ========== #

# Check if Ubuntu VM Exists
if ( multipass info quotes > /dev/null )
then
    echo "'quotes' VM Present"
else
    # VM not present
    echo "Initializing 'quotes' VM..."
    multipass launch --name quotes --cloud-init cloud-init.yaml --disk 20G --cpus 4 --memory 4G

    # Use scp to transfer setup-server script to VM
    scp -i id_ed25519 -o StrictHostKeyChecking=no setup-service.sh install-nginx.sh install-node-app.sh server.conf quotes.service developer@$(multipass info quotes | grep IPv4 | awk '{print $2}'):/home/developer

    # Run setup-server script
    ssh -i id_ed25519 -o StrictHostKeyChecking=no developer@$(multipass info quotes | grep IPv4 | awk '{print $2}') 'bash install-nginx.sh && bash install-node-app.sh && bash setup-service.sh'
fi

# Check if VM in "Running" state
if ( multipass info quotes | grep Running > /dev/null )
then
    echo "'quotes' VM Running"
else
    # VM not running
    echo "'quotes' VM not in 'Running' state. Starting VM..."
    multipass start quotes
fi
