#!/bin/bash

saveIFS=$IFS
IFS=$(echo -e "\n\b\015")

# --------------------------------------------------
# External funtions to include
. /mnt/c/Users/kkanjanapitak/Desktop/Repositories/atsCodes/libraries-shell/olympusatCantemo.lib
# --------------------------------------------------

export cantemoItemId="$1"
export rightslineDealsContracts="$2"

# --------------------------------------------------
export cantemoItemTitle=$(filterVidispineItemMetadata "$cantemoItemId" "metadata" "title")
export cantemoContractId=$(filterVidispineItemMetadata "$cantemoItemId" "metadata" "oly_rightslineContractId")
export cantemoContractCode=$(filterVidispineItemMetadata "$cantemoItemId" "metadata" "oly_contractCode")

# --------------------------------------------------
# Get contract information
useDealIdFromTitle=0
if [[ $cantemoItemTitle == "CA_"* ]];
then
    rightslineContractId=$(echo $cantemoItemTitle | awk -F "_" '{print $2}')
    if [[ $rightslineContractId != "" ]];
    then
        useDealIdFromTitle=1
    fi
fi
# --------------------------------------------------

if [[ "$cantemoContractId" != "" ]];
then
    rightslineContractId=$cantemoContractId
fi

# Enable extended globbing
shopt -s extglob

# Clean the rightslineContractId
rightslineContractId=$(echo "$rightslineContractId" | sed -e 's/^[[:space:]]*//' -e 's/CA//g' -e 's/^0*//')

if [[ "$cantemoContractCode" == "" ]];
then
    oldIFS=$IFS
    IFS=,
    while read -r col1 col2 rest; do
        if [[ "$col1" == "$rightslineContractId" ]];
        then
            cantemoContractCode="$col2"
        fi
    done < "$rightslineDealsContracts"
    IFS=$oldIFS
fi
# --------------------------------------------------

IFS=$saveIFS