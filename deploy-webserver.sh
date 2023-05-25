#!/bin/bash

# ========== Setup Dependencies ========== #

# rsync

# SSH keys
if [! -f id_ed25519 ]; then
    # Keys not present
    ssh-keygen -t ed25519 -q -f id_ed25519 -C "developer@relative.path" -N ""
fi

# Cloud-Init
if [! -f cloud-init.yaml ]; then
    # cloud-init.yaml not present
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
if (! which snap >/dev/null); then
    # Snap not present
    sudo apt update && sudo apt install snapd
fi

# Multipass
if (multipass version >/dev/null); then
    echo "Multipass is installed!"
else
    # Multipass not present
    sudo snap install multipass
fi

# ========== Create or Start VM ========== #

# Check if Ubuntu VM Exists
if (! multipass info quotes >/dev/null); then
    # VM not present
    multipass launch --name quotes --cloud-init cloud-init.yaml --disk 20G --cpus 4 --memory 4G

    # Use scp to transfer setup-server script to VM
    scp -i id_ed25519 -o StrictHostKeyChecking=no setup-server.sh developer@$(multipass info quotes | grep IPv4 | awk '{print $2}'):/home/developer

    # Run setup-server script
    ssh -i id_ed25519 -o StrictHostKeyChecking=no developer@$(multipass info quotes | grep IPv4 | awk '{print $2}') 'bash install-nginx.sh && bash install-node-app.sh && bash setup-service.sh'
fi

# Check if VM in "Running" state
if (multipass info quotes | grep Running >/dev/null); then
    # VM not running
    multipass start quotes
fi
