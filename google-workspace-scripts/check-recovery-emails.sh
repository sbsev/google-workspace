#!/bin/bash

GAM_EXC_PATH=/root/bin/gam7/gam

suff=@studytutors.de

searched_group="bundesvorstand$suff"

user_info_line="Recovery Email:"

criterion="it$suff"

declare -a users

orig_IFS=$IFS

# Get all users that are part of the "Bundesvorstand" and not suspended
while IFS=',' read -ra line;
do
    if [[ "${line[0]}" == "$searched_group"* ]] && [[ "${line[6]}" == "ACTIVE" ]];
    then
        users+=("${line[3]}")
    fi
done	<	<($GAM_EXC_PATH print group-members group "$searched_group" membernames)


# For each user, check whether their recovery email is set to it@...
for user in "${users[@]}";
do
    while IFS= read -r line;
    do
        if [[ "$line" == "$user_info_line $criterion"* ]];
        then
            echo "$user" >> "out.txt"
        fi
    done <	<($GAM_EXC_PATH info user "$user")
done

IFS=$orig_IFS
