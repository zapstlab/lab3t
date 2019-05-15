#!/bin/bash

set -e

ctx logger info "Installing Apache HTTP daemon"

sudo apt-get update
sudo apt-get -y -q --force-yes install apache2

ctx logger info "Installation of Apache HTTP daemon completed"

