#!/bin/bash

read -p "Enter the path to the subnet file: " SUBNET_FILE

if [ ! -f "$SUBNET_FILE" ]; then
    echo "File not found: $SUBNET_FILE"
    exit 1
fi

GATEWAY=$(ping -c 1 _gateway | grep PING | sed -r 's/^PING[^(]+\(([^)]+)\).+$/\1/')

if [ -z "$GATEWAY" ]; then
    echo "Gateway address could not be determined automatically."
    read -p "Please enter the gateway address manually: " GATEWAY
fi

echo "Using gateway address: $GATEWAY"

read -p "Enter the network interface (e.g., eth0): " INTERFACE

while IFS= read -r subnet
do
    echo "Adding route: sudo route add -net $subnet gw $GATEWAY $INTERFACE"

    sudo route add -net "$subnet" gw "$GATEWAY" "$INTERFACE"
    if [ $? -ne 0 ]; then
        echo "Failed to add route for subnet: $subnet"
    fi
done < "$SUBNET_FILE"

echo "Finished adding routes."
