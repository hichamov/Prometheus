#!/bin/bash

echo "Adding repository ..."
echo "deb [signed-by=/usr/share/keyrings/grafana.key] https://apt.grafana.com stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list

echo "Updating system ..."
sudo apt-get update

echo "Installing grafana ..."
sudo apt-get install grafana -y
