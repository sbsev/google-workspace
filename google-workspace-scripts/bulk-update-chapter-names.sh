#!/bin/bash

GAM_EXC_PATH=/root/bin/gam/gam

# Function for changing name
change_name() {
    local old_name="$1"
    # output new name
    echo "Bereichsleitung $old_name"
}

# different scopes to be considered
declare -a scopes=("studenten" "schueler" "info")
declare -a cities

# Mapping from scope to name
declare -A scope_name_map
scope_name_map["info"]="Kommunikation"
scope_name_map["studenten"]="Studierende"
scope_name_map["schueler"]="Schüler"

suff=@studenten-bilden-schueler.de

orig_IFS=$IFS

# Get all cities that are currently signed up
# This assumes (for runtime sake) that each chapter has all three accounts
searched_group=studenten@studenten-bilden-schueler.de
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
for group in "${scopes[@]}";
do
    for chapter in "${cities[@]}";
    do
        echo "Updating $group.$chapter$suff"
        new_name=$(change_name "${scope_name_map[$group]}")
        echo "New name: $new_name"
        $GAM_EXC_PATH update user "$group.$chapter$suff" firstname "$new_name"
    done
done

IFS=$orig_IFS