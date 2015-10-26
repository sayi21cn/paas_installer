#!/bin/bash

if ! (which pip); then
    sudo apt-get update
    sudo apt-get install -y python-pip
    sudo apt-get install -y python-yaml
fi

if ! (which shyaml); then
   pip install shyaml
fi

