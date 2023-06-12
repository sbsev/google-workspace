#!/bin/bash
# This script requires authorized gam scope

# Path to GAM executable
# Should be this of you installed it correctly
GAM_EXC_PATH="/root/bin/gam/gam"

echo -n "Please enter a city name (lowercase)"
read cityName

city=$(echo $cityName | tr "[:upper:]" "[:lower:]")

# Set the mapping
declare -A divisions=([schueler]=Schüler [studenten]=Studierende [info]=Kommunikation)

for div in "${!divisions[@]}";
    $GAM_EXC_PATH update user $div.$city suspended on
done
