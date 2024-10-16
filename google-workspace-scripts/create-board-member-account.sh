#!/bin/bash
# This script requires authorized gam scope, achieved by executing the install script

# Path to GAM executable
# Should be this if you installed it correctly
GAM_EXC_PATH="/root/bin/gam7/gam"

suff=@studytutors.de

########################################
## Start interactive creation process ##
########################################

echo -n "Firstname of Board member: "
read firstName
l_firstName=$(echo "$firstName" | tr '[:upper:]' '[:lower:]')

echo -n "Lastname of Board member: "
read lastName
l_lastName=$(echo "$lastName" | tr '[:upper:]' '[:lower:]')

echo -n "Login (if empty: $l_firstName.$l_lastName): "
read login

# Set some defaults
if [ ! -n "${login}" ];
then
    login="$l_firstName.$l_lastName"
fi

echo -n "Recovery email (if empty: it$suff): "
read recovMail

# Set default recovery mail (please don't use it@ as recovery)
if [ ! -n "${recovMail}" ];
then
    recovMail='it$suff'
fi

groups=("bundesvorstand")

##################################
## Add user to workspace groups ##
##   Default: Bundesvorstand    ##
##################################

while :
do
    # Get the group name
    # Note: This name is assumed to be the email adress of the group
    # e.g. if you want to add a user to the IT-group and, since the email
    # is it@..., you would enter "it" here
    echo -n "Which other group should the user be added to (besides BV)?: "
    read group

    # Set group to lowercase
    group=$(echo "$group" | tr '[:upper:]' '[:lower:]')

    # Check whether group is already in scope
    if ! [[ ${groups[*]} =~ "$group" ]];
    then
        groups+=("${group}")
    else
        echo -n "Group already present. "
    fi

    echo -n "Do you wish to add more groups? (Y/N): "
    read more
    more=$(echo "$more" | tr '[:upper:]' '[:lower:]')

    # If "N/n" is selected, terminate loop
    [ "n" == "$more" ] && break;
done

#########################
## Image and Signature ##
#########################

echo -n "Image file path (if empty: owl): "
read imgFilePath

if [ ! -n "${imgFilePath}" ];
then
    imgFilePath="$(readlink -f ../gmail/images/sbs-owls.png)"
fi

echo -n "Signature file (if empty: board.html): "
read signPath

if [ ! -n "$signPath"  ];
then
    signPath=$(readlink -f "../gmail/signatures/board.html")
fi

#########################
## Finally: GAM action ##
#########################

# Create account
$GAM_EXC_PATH create user $login \
firstname "${firstName}" \
lastname "${lastName}" \
password Abcdef1234 \
changepassword on \
org /Bundesvorstand

# Add the recovery email
$GAM_EXC_PATH user $login recoveryemail "${recovMail}"

# Add the profile picture
$GAM_EXC_PATH user $login update photo $imgFilePath

# Add to all groups specified
for group in "${groups[@]}";
do
    $GAM_EXC_PATH update group ${group} add member $login
done

echo "User successfully created. You might want to update the signature by running"
echo -e "\e[1;34m     ./update-board-signature.sh\e[0m"
