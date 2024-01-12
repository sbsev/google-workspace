#!/bin/bash
# This script requires authorized gam scope, achieved by executing the install script

# Path to GAM executable
# Should be this if you installed it correctly
GAM_EXC_PATH="/root/bin/gam/gam"

suff=@studytutors.de

# Gets the recovery email adress (circular dependency, order is arbitrary)
getRecovName() {
    case $1 in
        schueler)
            echo "studenten";
        ;;

        info)
            echo "schueler";
        ;;

        studenten)
            echo "info";
        ;;
    esac
}

#####################
## Read user input ##
#####################

echo -n "Please enter a city name (lowercase): "
read cityName

echo -n "Now creating accounts (info, studenten, schueler) for $cityName. Confirm? (Y/N)"
read consent


#######################
## Validate to start ##
#######################

# Terminate if the answer is not "Y"
if [ ! "y" == "${consent,,}" ];
then
    echo "Option not valid"
    exit 1;
fi

#########################################
## Create the mapping and city strings ##
#########################################

# Set lower- and uppercase city names
city=$(echo "$cityName" | tr "[:upper:]" "[:lower:]")
City=$(echo "$city" | sed 's/[^ _-]*/\u&/g')

# Set the mapping
# emailprefix <-> name in google workspace
declare -A divisions=([schueler]=Schüler [studenten]=Studierende [info]=Kommunikation)

###########################################
## Create Users for each divison in the  ##
## new city as well as first-time setup  ##
## e.g. signatures, profile picture, ... ##
###########################################

for div in "${!divisions[@]}";
do
    # Create the account
    $GAM_EXC_PATH create user $div.$city \
    firstname ${divisions[$div]} \
    lastname $City \
    password Abcdef1234 \
    changepassword on \
    org /Standorte \
    recoveryemail "$(getRecovName $div)".$city$suff

    # Set profile picture & signature
    $GAM_EXC_PATH user $div.$city update photo $(readlink -f "../gmail/images/sbs-owls.png")
    $GAM_EXC_PATH update group $div add member $div.$city
    $GAM_EXC_PATH user $div.$city signature file $(readlink -f "../gmail/signatures/chapters.html") html replace firstName ${divisions[$div]} replace lastName $City
done

# Division info needs special treatment
$GAM_EXC_PATH update group kommunikation add member info.$city
$GAM_EXC_PATH update group info remove member info.$city
