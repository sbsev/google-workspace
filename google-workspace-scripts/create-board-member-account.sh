#!/bin/bash

GAM_EXC_PATH="/root/bin/gam/gam"

echo -n "Firstname of Board member"
read firstName

echo -n "Lastname of Board member"
read lastName

echo -n "Login (if $firstName.$lastName just press enter)"
read login

if [ ! -n "${login}" ];
then
    login="$firstName.$lastName"
fi

echo -n "Recovery email (if empty: it@)"
read recovMail

if [ ! -n "${recovMail}" ];
then
    recovMail="it@studenten-bilden-schueler.de"
fi

groups=("bundesvorstand")

while ! [ "${group,,}" == "d" ];
    echo -n "Which other group should the user be added to (besides BV)?"
    read group
    group=${group,,}
    if [ ! "${groups[@]}" in *"${group}"* ];
    then
        groups+=(${group})
    else
        echo -n "Group already present."
    fi

    echo -n "Do you wish to add more groups? (Y/N)"
    read more
    if [ ! "y" == "${more,,}" ] && break;
done

echo -n "Image file path (if empty: owl)"
read imgFilePath

if [ ! -n "${imgFilePath}" ];
then
    imgFilePath=gmail/images/sbs-owls.png
fi

# Create account
$GAM_EXC_PATH create user $login \
firstname $firstName \
lastname $lastName \
password Abcdef1234 \
changepassword on \
org /Bundesvorstand \
recoveryemail $recovMail

$GAM_EXC_PATH user $login signature file $imgFilePath html replace firstName $firstName replace lastName $lastName
# set initial profile picture to owl logo just so its not empty
$GAM_EXC_PATH user $login update photo gmail/images/sbs-owls.png

for group in "${groups[@]}";
do
    $GAM_EXC_PATH update group ${group} add member $login
done