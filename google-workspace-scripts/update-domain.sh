#!/bin/bash
# This script requires authorized gam scope, achieved by executing the install script

# Path to GAM executable
# Should be this if you installed it correctly
GAM_EXC_PATH="/root/bin/gam/gam"

old_suff="@studenten-bilden-schueler.de"
new_suff="@studytutors.de"

###########
## Users ##
###########

searched_group="bundesvorstand$new_suff"

declare -a users

orig_IFS=$IFS

# Get all users that are part of the "Bundesvorstand" and not suspended
while IFS=',' read -ra line;
do
    if [[ "${line[0]}" == "$searched_group"* ]] && \
    [[ ! "${line[3]}" ==  *"$new_suff"* ]];
    then
        if [[ "${line[3]}" == *'$login'* ]]; then
            continue
        fi
        users+=("${line[3]}")
    fi
done	<	<($GAM_EXC_PATH print group-members group "$searched_group" membernames)

# For each user, set their new email

for user_email in "${users[@]}";
do
    username=$(echo "$user_email" | cut -d '@' -f 1)
    echo "Updating $username Email"

    $GAM_EXC_PATH update user \
    "$user_email" email "$username$new_suff"
done

##############
## Chapters ##
##############

searched_group="studenten$old_suff"

declare -a chapters

# different scopes to be considered
declare -a scopes=("studenten" "schueler" "info")

while IFS=',' read -ra line;
do
    if [[ "${line[0]}" == "$searched_group"* ]];
    then
        email="${line[3]}"

        # Only update chapters that don't have the new domain
        if [[ ! "$email" == *"$new_suff"* ]];
        then
            # Remove everything before the dot (including)
            tmp="${email#*.}"

            # Remove everything after the @ symbol (including)
            result="${tmp%%@*}"
            chapters+=("$result")
        fi

    fi
done	<	<($GAM_EXC_PATH print group-members group "$searched_group" membernames)

# Now for each city and scope, set new email

for chapter in "${chapters[@]}";
do
    for scope in "${scopes[@]}";
    do
        new_scope="$scope"
        # Rename studenten to studierende
        if [[ "$scope" == "studenten" ]];
        then
            new_scope="studierende"
        fi

        echo "Now updating $scope.$chapter Email"

        $GAM_EXC_PATH update user \
        "$scope.$chapter$old_suff" email \
        "$new_scope.$chapter$new_suff"

    done
done

############
## Groups ##
############

# Last but not least, update all groups

declare -a groups

while read -ra line;
do
    if [[ ! "$line" == *"$new_suff"* ]];
    then
        group_name=$(echo "$line" | cut -d '@' -f 1)
        groups+=("$group_name")
    fi
done	<	<($GAM_EXC_PATH print group-members group "$searched_group" membernames)


for group in "${groups[@]}";
do
    echo "Updating group $group"
    $GAM_EXC_PATH update group "$group$old_suff" email "$group$new_suff"
done

# Reset IFS
IFS=$orig_IFS
