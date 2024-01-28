#!/bin/bash

GAM_EXC_PATH=/root/bin/gam/gam

# different scopes to be considered
declare -a cities

suff=@studytutors.de

orig_IFS=$IFS

# Get all cities that are currently signed up
# This assumes (for runtime sake) that each chapter has all three accounts
searched_group="studenten@$suff"
while IFS=',' read -ra line;
do
    if [[ "${line[0]}" == "$searched_group"* ]];
    then
        email="${line[3]}"
        # Remove everything before the dot (including)
        tmp="${email#*.}"

        # Remove everything after the @ symbol (including)
        result="${tmp%%@*}"
        cities+=("$result")
    fi
done	<	<($GAM_EXC_PATH print group-members group "$searched_group" membernames)

# We just need to check one city, if the recovery e-mail is "it@<>" we need to change

user_info_line="Recovery Email:"
criterion="it$suff"

declare -a needs_update

for chapter in "${cities[@]}";
do
    while IFS= read -r line;
    do
        if [[ "$line" == "$user_info_line $criterion"* ]];
        then
            needs_update+=("$chapter")
        fi
    done <	<($GAM_EXC_PATH info user "studenten.$chapter$suff")
done

# Now we can set the recovery emails in circular closure
declare -a groups=("studierende" "schueler" "info")

getRecovName() {
    case $1 in
        schueler)
            echo "studierende";
        ;;

        info)
            echo "schueler";
        ;;

        studierende)
            echo "info";
        ;;
    esac
}

# Update all chapters that need update
for chapter in "${needs_update[@]}";
do
    echo "Now updating $chapter"
    for group in "${groups[@]}";
    do
        $GAM_EXC_PATH update user $group.$chapter$suff \
        recoveryemail "$(getRecovName $group)".$chapter$suff
    done
done

IFS=$orig_IFS
