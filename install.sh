#!/bin/bash

# Install gam
bash <(curl -s -S -L https://gam-shortn.appspot.com/gam-install) -l

# Add gam to path and set alias
export PATH="${PATH}:/root/bin/gam/gam"

# Shorthand to executable
function gam() { "/root/bin/gam/gam" "$@" ; }

# Start the interactive creation
gam create project