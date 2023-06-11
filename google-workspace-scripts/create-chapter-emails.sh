#!/bin/bash
# This script requires authorized gam scope

GAM_EXC_PATH="/root/bin/gam/gam"

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

echo -n "Please enter a city name (lowercase): "
read cityName


echo -n "Now creating accounts (info, studenten, schueler) for $cityName. Confirm? (Y/N)"
read consent

# Terminate if the answer is not "Y"
[ "$consent" != "Y" ] && exit 1;

# Set lower- and uppercase city names
city=$(echo "$cityName" | tr "[:upper:]" "[:lower:]")
City=$(echo "$city" | sed 's/[^ _-]*/\u&/g')

# Set the default
declare -A divisions=([schueler]=Schüler [studenten]=Studierende [info]=Kommunikation)


for div in "${!divisions[@]}";
do
    $GAM_EXC_PATH create user $div.$city \
    firstname ${divisions[$div]} \
    lastname $City \
    password Abcdef1234 \
    changepassword on \
    org /Standorte \
    recoveryemail "$(getRecovName $div)".$city@studenten-bilden-schueler.de
    
    $GAM_EXC_PATH user $div.$city update photo gmail/images/sbs-owls.png
    $GAM_EXC_PATH update group $div add member $div.$city
    $GAM_EXC_PATH user $div.$city signature file gmail/signatures/chapters.html html replace firstName ${divisions[$div]} replace lastName $City
done

$GAM_EXC_PATH update group kommunikation add member info.$city
$GAM_EXC_PATH update group info remove member info.$city