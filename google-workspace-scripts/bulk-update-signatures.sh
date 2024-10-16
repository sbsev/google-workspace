#!/bin/bash
# This script requires authorized gam scope, achieved by executing the install script

# Path to GAM executable
# Should be this if you installed it correctly
GAM_EXC_PATH="/root/bin/gam7/gam"

signature_path=$(readlink -f "../gmail/signatures/board.html")

suff="@studytutors.de"

searched_group="bundesvorstand$suff"

declare -a users

orig_IFS=$IFS

# Get all users that are part of the "Bundesvorstand" and not suspended
while IFS=',' read -ra line;
do
    if [[ "${line[0]}" == "$searched_group"* ]] && \
    [[ "${line[6]}" == "ACTIVE" ]];
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

  login=$(echo "$user_email" | cut -d '@' -f 1)
  echo "Updating $login Signature"

  # First name (capitalize pls)
  echo -n "First name: "
  read firstName

  # If firstname is s, skip
  if [[ "$firstName" == "s" ]]; then
      continue
  fi

  # Last name (capitalize pls)
  echo -n "Last name: "
  read lastName

  # Department the user is engaged
  echo -n "Department (defaults to 'Bundesvorstand'): "
  read department

  # Default department: Bundesvorstand
  if [ ! -n "$department" ];
  then
      department="Bundesvorstand"
  fi

  # Description of role the user has
  echo -n "Jobtitle (e.g. IT): "
  read jobTitle

  ## The signature will look somewhat like this (assuming board.html)
  ## ---
  ## {firstName} {lastName}
  ## {department} {jobTitle}
  ## studenten-bilden-schueler.de
  $GAM_EXC_PATH user $login signature \
    file $signature_path html \
    replace firstName "${firstName}" \
    replace lastName "${lastName}" \
    replace department "${department}" \
    replace jobtitle "${jobTitle}"
done

signature_path=$(readlink -f "../gmail/signatures/chapters.html")

searched_group="studenten$suff"

declare -a scopes=("studierende" "schueler" "info")
declare -a cities

declare -A scope_name_map
scope_name_map["info"]="Kommunikation"
scope_name_map["studierende"]="Studierende"
scope_name_map["schueler"]="Schüler"


while IFS=',' read -ra line;
do
    if [[ "${line[0]}" == *"$searched_group"* ]];
    then
        email="${line[3]}"
        # Remove everything before the dot (including)
        tmp="${email#*.}"

        # Remove everything after the @ symbol (including)
        result="${tmp%%@*}"
        cities+=("$result")
    fi
done	<	<($GAM_EXC_PATH print group-members group "$searched_group" membernames)

for group in "${scopes[@]}";
do
    for chapter in "${cities[@]}";
    do
      echo "Updating $group.$chapter Signature"
      City=$(echo "$chapter" | sed 's/[^ _-]*/\u&/g')
      $GAM_EXC_PATH user $group.$chapter signature \
        file $signature_path html \
        replace firstName ${scope_name_map[$group]} \
        replace lastName $City
    done
done

IFS=$orig_IFS
