#!/bin/bash

GAM_EXC_PATH="/root/bin/gam/gam"

suff="@studytutors.de"

searched_group="studenten$suff"

declare -a cities

orig_IFS=$IFS

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

# Now that we have the cities, we can update all chapter emails
for chapter in "${cities[@]}";
do
  echo "Adding alias to studierende.$chapter"

  $GAM_EXC_PATH create alias \
    studenten.$chapter \
    user studierende.$chapter
done

IFS=$orig_IFS
