#!/bin/bash

# Install gam
bash <(curl -s -S -L https://gam-shortn.appspot.com/gam-install) -l

# Add gam to path and set alias
export PATH="${PATH}:/root/bin/gam/gam"

# Shorthand to executable
function gam() { "/root/bin/gam/gam" "$@" ; }

# Add alias
alias gam=/root/bin/gam/gam

# Start the interactive creation
gam create project

# After completing the GAM setup some things might not work.
# TODO: in readme

# 1. 403 on configured apps: -> superadmin
# 2. ERROR: User <...>@studenten-bilden-schueler.de: unauthorized_client: Client is unauthorized to retrieve access tokens using this method, or client not authorized for any of the scopes requested.
#   -> run 'gam user <username> check serviceaccount' and follow
#   cf. https://github.com/sbsev/google-workspace/issues/14