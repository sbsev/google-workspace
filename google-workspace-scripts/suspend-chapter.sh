#!/bin/bash
# This script requires authorized gam scope

# Path to GAM executable
# Should be this of you installed it correctly
GAM_EXC_PATH="/root/bin/gam7/gam"

echo -n "Please enter a city name: "
read cityName

city=$(echo $cityName | tr "[:upper:]" "[:lower:]")

# Set the mapping
# emailprefix <-> name in google workspace
declare -A divisions=([schueler]=Schüler [studierende]=Studierende [info]=Kommunikation)

for div in "${!divisions[@]}";
do
  echo "$div"
  $GAM_EXC_PATH update user $div.$city suspended on
done
