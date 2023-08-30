#!/bin/bash

GAM_EXC_PATH=/root/bin/gam/gam

searched_group=bundesvorstand@studenten-bilden-schueler.de

user_info_line="Recovery Email:"

criterion=it@studenten-bilden-schueler.de

declare -a users

orig_IFS=$IFS

# Eet all users that are part of the "Bundesvorstand" and not suspended
while IFS=',' read -ra line;
do
	if [[ "${line[0]}" == "$searched_group"* ]] && [[ "${line[6]}" == "ACTIVE" ]];
	then
		echo "${line[@]}"
		echo "${line[3]}"
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
