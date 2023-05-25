#!/bin/bash

# Setup Service

if [ -f /etc/systemd/system/quotes.service ] 
then
    echo "Service already setup setup."
else
    sudo cp quotes.service /etc/systemd/system/ && sudo systemctl daemon-reload
fi

if (systemctl is-active quotes.service) 
then
    echo "Quotes is running"
else
    sudo systemctl restart quotes.service
fi
