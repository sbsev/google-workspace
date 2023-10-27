#!/bin/bash
# This script requires authorized gam scope, achieved by executing the install script

# Path to GAM executable
# Should be this if you installed it correctly
GAM_EXC_PATH="/root/bin/gam/gam"

# Get the login name of the user
echo -n "Login name (e.g. firstname.lastname): "
read login

# Get the new signature path
echo -n "Signature file path (defaults to board.html): "
read signPath

# Set the default to board signature
if [ ! -n "$signPath" ];
then
    signPath="../gmail/signatures/board.html"
fi

###############################
## Information for signature ##
###############################

# First name (capitalize pls)
echo -n "First name: "
read firstName

# Last name (capitalize pls)
echo -n "Last name: "
read lastName

# Department the user is engaged
echo -n "Department (defaults to 'Bundesvorstand'): "
read department

# Default department: Bundesvorstand
if [ ! -n "$department" ];
then
    department="Bundesvorstand"
fi

# Description of role the user has
echo -n "Jobtitle (e.g. IT): "
read jobTitle

## The signature will look somewhat like this (assuming board.html)
## ---
## {firstName} {lastName}
## {department} {jobTitle}
## studenten-bilden-schueler.de
$GAM_EXC_PATH user $login signature file $signPath html replace firstName $firstName replace lastName $lastName replace department $department replace jobtitle $jobTitle
