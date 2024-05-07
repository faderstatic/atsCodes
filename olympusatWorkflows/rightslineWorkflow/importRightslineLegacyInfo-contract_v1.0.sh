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
    currentFieldValue=$1
    combinedValue=""
    numberOfValues=$(echo "$currentFieldValue" | awk -F'[|,]' '{print NF}')
    for (( i=1 ; i<=$numberOfValues ; i++ ));
    do
        currentValue=$(echo "$currentFieldValue" | awk -F'[|,]' '{print $'$i'}')
        firstWord=$(echo $currentValue | awk '{print $1}' | tr '[:upper:]' '[:lower:]')
        numberOfWords=$(echo $currentValue | awk '{print NF}')
        if [[ $numberOfWords -gt 1 ]];
        then
            restOfTheWords=$(echo $currentValue | awk '{print $NF}' | tr '[:upper:]' '[:lower:]')
            restOfTheWords=$(echo $restOfTheWords | sed 's/.*/\u&/')
            restOfTheWords=$(echo $restOfTheWords | cut -d " " -f2-$NF | sed -e 's/ //g')
        else
            restOfTheWords=""
        fi
        if [[ "$combinedValue" = "" ]];
        then
            combinedValue=$(echo $firstWord$restOfTheWords)
        else
            combinedValue=$(echo $combinedValue,$firstWord$restOfTheWords)
        fi
    done
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
export columnHeader="$2"
export inputFile="$3"
export rightslineItemId=$(filterVidispineItemMetadata "$cantemoItemId" "metadata" "oly_rightslineItemId")
export cantemoItemTitle=$(filterVidispineItemMetadata "$cantemoItemId" "metadata" "title")
# --------------------------------------------------

# --------------------------------------------------
# Sanitize rightslineItemId to remove any empty spaces
rightslineItemId=$(echo $rightslineItemId | tr -d ' ')

# --------------------------------------------------
# Check to see if import has already ran on item
#urlGetItemInfo="http://10.1.1.34:8080/API/item/$cantemoItemId/metadata?field=oly_contractCode&terse=yes"
#httpResponse=$(curl --location --request GET $urlGetItemInfo --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=Tkb9vkSC8v4SceB8CHUyB3iaMPjvgoHrzhLrvo36agG3wqv0jHc7nsOtdTo9JEyM')
export contractCode=$(filterVidispineItemMetadata "$cantemoItemId" "metadata" "oly_contractCode")

if [ -z "$contractCode" ];
then
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

        #fileDestination="/opt/olympusat/xmlsForMetadataImport/${fieldValue[3]}.xml"
        fileDestination="/opt/olympusat/xmlsForMetadataImport/"$cantemoItemId"-CONTRACT.xml"

        # --------------------------------------------------
        # Print XML header
        echo "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>
<MetadataDocument xmlns=\"http://xml.vidispine.com/schema/vidispine\">
  <group>Olympusat</group>
    <timespan end=\"+INF\" start=\"-INF\">
      <field>
         <name>title</name>
         <value>$cantemoItemTitle</value>
      </field>" > "$fileDestination"
        # --------------------------------------------------

        # --------------------------------------------------
        # Choose what information from the CSV export file needed to be printed
        columnCounter=1
        while [ $columnCounter -le $columnCounts ];
        do
            case "${fieldName[$columnCounter]}" in

                "oly_licensor")
                    fieldValue[$columnCounter]=$(convertToCamelCase ${fieldValue[$columnCounter]})
                    echo "      <field>
         <name>${fieldName[$columnCounter]}</name>
         <value>${fieldValue[$columnCounter]}</value>
      </field>" >> "$fileDestination"
                    columnCounter=$(($columnCounter + 1))
                ;;

                "oly_rightslineItemId")
                    columnCounter=$(($columnCounter + 1))
                ;;

                *)
                    echo "      <field>
         <name>${fieldName[$columnCounter]}</name>
         <value>${fieldValue[$columnCounter]}</value>
      </field>" >> "$fileDestination"
                    columnCounter=$(($columnCounter + 1))
                ;;

            esac
        done
        # --------------------------------------------------

        # --------------------------------------------------
        # Print XML footer
        echo "    </timespan>
</MetadataDocument>" >> "$fileDestination"
        # --------------------------------------------------

        sleep 5

        # ----------------------------------------------------
        # API Call to Update Metadata

        url="http://10.1.1.34:8080/API/import/sidecar/$cantemoItemId?sidecar=/opt/olympusat/xmlsForMetadataImport/$cantemoItemId-CONTRACT.xml"
        #echo "Item ID - $cantemoItemId"
        #echo "Item Title - $cantemoItemTitle"
        #echo "URL - $url"

        curl --location --request POST $url --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0'

        sleep 2
        
        updateVidispineMetadata $cantemoItemId "oly_rightslineInfo" "contractmetadataimported"
        
        sleep 2

        echo "Moving xml to zCompleted folder"
        mv "$fileDestination" "/opt/olympusat/xmlsForMetadataImport/zCompleted/"

    fi
fi

IFS=$saveIFS

exit 0