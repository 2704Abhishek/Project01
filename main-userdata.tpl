#!/bin/bash

# Update packages
sudo apt-get update -y
sudo apt-get upgrade -y

# Create keyring directory
sudo mkdir -p /etc/apt/keyrings/

# Download Grafana GPG key
wget -q -O - https://packages.grafana.com/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/grafana.gpg

# Add Grafana repository
echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://packages.grafana.com/oss/deb stable main" \
| sudo tee /etc/apt/sources.list.d/grafana.list

# Update repo & install Grafana
sudo apt-get update -y
sudo apt-get install grafana -y

# Start and enable Grafana service
sudo systemctl start grafana-server
sudo systemctl enable grafana-server
