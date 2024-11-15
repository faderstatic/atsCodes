#!/bin/bash

# This script gathers Contract Metadata from Rightsline (for legacy contents) and apply them to Cantemo
# PREREQUISITE: This script must receive Cantemo item ID as an argument, column header and file location of Rightsline CSV export.
# It requests oly_rightslineItemId from Vidispine and updates metadata fields
#   Usage: importRightslineLegacyInfo-contract_vX.X.sh [Cantemo item ID] [column header which contains Rightsline ID]
#          [file which contains csv export from Rightsline]

# System requirements: This script can run on LINUX and MacOS

saveIFS=$IFS
IFS=$(echo -e "\n\b\015")

# --------------------------------------------------
# External funtions to include
. /opt/olympusat/scriptsLibrary/olympusatCantemo.lib
# --------------------------------------------------

# --------------------------------------------------
# Internal funtions
convertToCamelCase ()
{
    #currentFieldValue=$1
    currentValue=$1
    #combinedValue=""
    #numberOfValues=$(echo "$currentFieldValue" | awk -F'[|,]' '{print NF}')
    #for (( i=1 ; i<=$numberOfValues ; i++ ));
    #do
        #currentValue=$(echo "$currentFieldValue" | awk -F'[|,]' '{print $'$i'}')
        firstWord=$(echo $currentValue | awk -F ' ' '{print $1}' | tr '[:upper:]' '[:lower:]' | sed -e 's/[,.]//g')
        numberOfWords=$(echo $currentValue | awk -F ' ' '{print NF}')
        if [[ $numberOfWords -gt 1 ]];
        then
            restOfTheWords=$(echo $currentValue | cut -d " " -f2-$NF | tr '[:upper:]' '[:lower:]' | sed 's/\([a-z]\)\([a-zA-Z0-9]*\)/\u\1\2/g' | sed -e 's/[ ,.]//g')
        else
            restOfTheWords=""
        fi
        #if [[ "$combinedValue" = "" ]];
        #then
            combinedValue=$(echo $firstWord$restOfTheWords)
        #else
        #    combinedValue=$(echo $combinedValue,$firstWord$restOfTheWords)
        #fi
    #done
    echo "$combinedValue"
}

createTags ()
{
    currentFieldValue="$1"
    currentFieldName="$2"
    currentOutputFile="$3"
    echo "      <field>
         <name>$currentFieldName</name>" >> "$currentOutputFile"
    numberOfValues=$(echo "$currentFieldValue" | awk -F'[|,]' '{print NF}')
    for (( j=1 ; j<=$numberOfValues ; j++ ));
    do
        currentValue=$(echo "$currentFieldValue" | awk -F'[|,]' '{print $'$j'}')
        echo "         <value>$currentValue</value>" >> "$currentOutputFile"
    done
    echo "      </field>" >> "$currentOutputFile"
}

countDaMuthaFukkingColumns ()
{
    countingString="$1"
    holdFurtherCount="false"
    properFieldCount=0
    maximumColumns=$(echo "$countingString" | awk -F "," '{print NF+1}')
    for (( m=1 ; m<=$maximumColumns ; m++ ));
    do
        currentReadValue=$(echo "$countingString" | awk -F "," '{print $'$m'}')
        if [[ "$currentReadValue" == "\""* ]];
        then
            holdFurtherCount="true"
        elif [[ "$currentReadValue" == *"\"" ]];
        then
            holdFurtherCount="false"
        fi
        if [[ "$holdFurtherCount" = "false" ]];
        then
            properFieldCount=$(($properFieldCount + 1))
        fi
    done
    echo $properFieldCount
}
# --------------------------------------------------

# --------------------------------------------------
# Set some parameters
export cantemoItemId="$1"
export userName="$2"
export columnHeader="$3"
export inputFile="$4"
export rightslineItemId="$5"
#export rightslineItemId=$(filterVidispineItemMetadata "$cantemoItemId" "metadata" "oly_rightslineItemId")
export cantemoItemTitle=$(filterVidispineItemMetadata "$cantemoItemId" "metadata" "title")

export mydate=$(date +%Y-%m-%d)
#logfile="/opt/olympusat/logs/importRightslineLegacyInfo-$mydate.log"
logfile="/opt/olympusat/logs/ingestMetadataWorkflow-$mydate.log"

# --------------------------------------------------

# --------------------------------------------------
# Sanitize rightslineItemId to remove any empty spaces
echo "$(date +%Y/%m/%d_%H:%M:%S) - (importContractMetadata) - [$cantemoItemId] - Import Contract Metadata Job Initiated - {$rightslineItemId}" >> "$logfile"
rightslineItemId=$(echo $rightslineItemId | tr -d ' ')

#echo "$(date +%Y/%m/%d_%H:%M:%S) - (importContractMetadata) - [$cantemoItemId] - Reading Information in CSV" >> "$logfile"

partialRow="false"
lineReadComplete="false"

# --------------------------------------------------
# Read Header Row Values and Count Columns
headerRow=$(sed -n '1p' "$inputFile")
columnCounter=1
noMoreColumns="false"
while [ "$noMoreColumns" == "false" ];
do
    if [[ $columnCounter -eq 1 ]];
    then
        fieldName[$columnCounter]=$(echo $headerRow | awk 'BEGIN { FPAT = "([^,]*)|(\"[^\"]+\")" } {print $'$columnCounter'}' | sed -e 's/\"//g') #| sed -e 's/^.//')
    else
        fieldName[$columnCounter]=$(echo $headerRow | awk 'BEGIN { FPAT = "([^,]*)|(\"[^\"]+\")" } {print $'$columnCounter'}' | sed -e 's/\"//g')
    fi
    if [[ "${fieldName[$columnCounter]}" == *"$columnHeader" ]];
    then
        rightslineIdColumn=$columnCounter
    fi
    if [[ "${fieldName[$columnCounter]}" = "" ]];
    then
        noMoreColumns="true"
        columnCounts=$(($columnCounter -1))
    else
        columnCounter=$(($columnCounter + 1))
    fi
done
for matchedRow in $(grep -n "$inputFile" -e "\<$rightslineItemId\>" | awk -F ',' '{print $'$rightslineIdColumn'}')
do
    matchedValue=$(echo $matchedRow | awk -F ':' '{print $2}')
    if [[ $matchedValue -eq $rightslineItemId ]];
    then
        matchedRowNumber=$(echo $matchedRow | awk -F ':' '{print $1}')
    fi
done
# --------------------------------------------------

# --------------------------------------------------
# Read Specific Line
if [ ! -z "$matchedRowNumber" ];
then

    line=$(sed -n ''$matchedRowNumber'p' "$inputFile")
    cleanLine=$(echo $line | sed -e 's/\"\"/-/g')
    # columnsForThisRow=$(echo "$cleanLine" | awk 'BEGIN { FPAT = "([^,]*)|(\"[^\"]+)|(\"[^\"]+\")" } {print NF+1}' )
    columnsForThisRow=$(countDaMuthaFukkingColumns "$cleanLine")
    while [[ $columnsForThisRow -lt $columnCounts ]];
    do
        matchedRowNumber=$(($matchedRowNumber + 1))
        nextLine=$(sed -n ''$matchedRowNumber'p' "$inputFile")
        cleanNextLine=$(echo $nextLine | sed -e 's/\"\"/-/g')
        cleanLine="$cleanLine $cleanNextLine"
        columnsForThisRow=$(countDaMuthaFukkingColumns "$cleanLine")
    done

    columnCounter=1
    while [[ $columnCounter -le $columnCounts ]];
    do
        fieldValue[$columnCounter]=$(echo $cleanLine | awk 'BEGIN { FPAT = "([^,]*)|(\"[^\"]+)|(\"[^\"]+\")" } {print $'$columnCounter'}' | sed -e 's/\"//g')
        columnCounter=$(($columnCounter + 1))
    done

    # --------------------------------------------------

    # --------------------------------------------------
    # Writing XML File

    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (importContractMetadata) - [$cantemoItemId] - Creating XML with Information" >> "$logfile"

    # --------------------------------------------------
    # Checking Cantemo Item for existing metadata

    urlGetItemMetadata="http://10.1.1.34:8080/API/item/$cantemoItemId/metadata?field=oly_rightslineContractId%2Coly_contractCode%2Coly_licensor&terse=yes&includeConstraintValue=all"
    bulkMetadataHttpResponse=$(curl --location --request GET $urlGetItemMetadata --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=Tkb9vkSC8v4SceB8CHUyB3iaMPjvgoHrzhLrvo36agG3wqv0jHc7nsOtdTo9JEyM')

    sleep 1

    # --------------------------------------------------
    # Choose what information from the CSV export file needed to be printed
    columnCounter=1
    while [ $columnCounter -le $columnCounts ];
    do
        case "${fieldName[$columnCounter]}" in

            "oly_licensor")
                if [[ ! -z "${fieldValue[$columnCounter]}" ]];
                then
                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (importContractMetadata) - [$cantemoItemId] - [${fieldValue[$columnCounter]}] Column is NOT empty" >> "$logfile"
                    licensor=$(convertToCamelCase ${fieldValue[$columnCounter]})
                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (importContractMetadata) - [$cantemoItemId] - oly_licensor - [$licensor]" >> "$logfile"
                    updateVidispineMetadata $cantemoItemId "oly_licensor" "$licensor"
                    sleep 1
                    columnCounter=$(($columnCounter + 1))
                else
                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (importContractMetadata) - [$cantemoItemId] - [${fieldValue[$columnCounter]}] Column is EMPTY" >> "$logfile"
                    columnCounter=$(($columnCounter + 1))
                fi
            ;;
            "oly_rightslineItemId")
                columnCounter=$(($columnCounter + 1))
            ;;
            "oly_rightslineContractId")
                columnCounter=$(($columnCounter + 1))
            ;;
            "oly_contractCode")
                if [[ ! -z "${fieldValue[$columnCounter]}" && "$bulkMetadataHttpResponse" != *"</${fieldName[$columnCounter]}>"* ]];
                then
                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (importContractMetadata) - [$cantemoItemId] - [${fieldValue[$columnCounter]}] Column NOT empty" >> "$logfile"
                    export contractCode="${fieldValue[$columnCounter]}"
                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (importContractMetadata) - [$cantemoItemId] - oly_contractCode - [$contractCode]" >> "$logfile"
                    updateVidispineMetadata $cantemoItemId "oly_contractCode" "$contractCode"
                    sleep 1
                    columnCounter=$(($columnCounter + 1))
                else
                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (importContractMetadata) - [$cantemoItemId] - [${fieldValue[$columnCounter]}] Column is EMPTY" >> "$logfile"
                    columnCounter=$(($columnCounter + 1))
                fi
            ;;
            *)
                columnCounter=$(($columnCounter + 1))
            ;;

        esac
    done
    # --------------------------------------------------
    sleep 2
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (importContractMetadata) - [$cantemoItemId] - Import Rightsline Contract Information Completed" >> "$logfile"

else
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (importContractMetadata) - [$cantemoItemId] - Import Metadata Job Skipped - No Matching Rightsline Item Id Found in CSV" >> "$logfile"
fi

IFS=$saveIFS

exit 0