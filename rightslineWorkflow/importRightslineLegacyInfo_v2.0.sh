#!/bin/bash

# This script gathers Metadata from Rightsline (for legacy contents) and apply them to Cantemo
# PREREQUISITE: This script must receive Cantemo item ID as an argument, column header and file location of Rightsline CSV export.
# It requests oly_rightslineItemId from Vidispine and updates metadata fields
#   Usage: importRightslineLegacyInfo_vX.X.sh [Cantemo item ID] [column header which contains Rightsline ID]
#          [file which contains csv export from Rightsline]

# System requirements: This script can run on LINUX and MacOS

saveIFS=$IFS
IFS=$(echo -e "\n\b\015")

# --------------------------------------------------
# External funtions to include
. /opt/olympusat/scriptsLibrary/olympusatCantemo.lib
# --------------------------------------------------
# WHHHAAAATTTTSSSS UPPPPP TAAANNNNGGGGYYYYYY
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
            restOfTheWords=$(echo $currentValue | cut -d " " -f2-$NF | sed -e 's/ //g')
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
# --------------------------------------------------

# --------------------------------------------------
# Set some parameters
export cantemoItemId="$1"
export columnHeader="$2"
export inputFile="$3"
export rightslineItemId=$(filterVidispineItemMetadata "$cantemoItemId" "metadata" "oly_rightslineItemId")
export cantemoItemTitle=$(filterVidispineItemMetadata "$cantemoItemId" "metadata" "title")
# --------------------------------------------------

partialRow="false"
lineReadComplete="false"

# --------------------------------------------------
# Read Header Row Values
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
    if [[ "${fieldName[$columnCounter]}" = "" ]];
    then
        noMoreColumns="true"
        columnCounts=$(($columnCounter - 1))
    fi
    if [[ "${fieldName[$columnCounter]}" == *"$columnHeader" ]];
    then
        rightslineIdColumn=$columnCounter
    fi
    columnCounter=$(($columnCounter + 1))
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
while [[ "$lineReadComplete" = "false" ]];
do
    line=$(sed -n ''$matchedRowNumber'p' "$inputFile")
    cleanLine=$(echo $line | sed -e 's/\"\"/-/g')
    # --------------------------------------------------
    # Determine if we are dealing with a line with partial data
    if [[ "$partialRow" = "true" ]];
    then
        lastColumnNumber=$(echo "$cleanLine" | awk 'BEGIN { FPAT = "([^,]*)|(\"[^\"]+\")" } {print NF+1}' )
        firstColumnNumber=$previousColumnCount
        columnsForThisRow=$(($lastColumnNumber + $previousColumnCount -1))
    else
        columnsForThisRow=$(echo "$cleanLine" | awk 'BEGIN { FPAT = "([^,]*)|(\"[^\"]+\")" } {print NF+1}' )
        firstColumnNumber=1
        lastColumnNumber=$columnsForThisRow
    fi
    if [[ $columnsForThisRow -lt $columnCounts ]];
    then
        partialRow="true"
        # echo "Partial Row is True"
    else
        partialRow="false"
        # echo "Partial Row is False"
    fi
    # --------------------------------------------------

    # --------------------------------------------------
    # Making sure data in each and all column is read correctly
    if [[ "$partialRow" = "true" ]];
    then
        columnCounter=1
        while [ $columnCounter -lt $lastColumnNumber ];
        do
            adjustedColumnNumber=$(($firstColumnNumber + $columnCounter -1))
            if [[ "$previousPartialMetadata" != "" ]];
            then
                fieldValue[$adjustedColumnNumber]=$(echo $cleanLine | awk 'BEGIN { FPAT = "([^,]*)|(\"[^\"]+\")" } {print $'$columnCounter'}' | sed -e 's/\"//g')
                fieldValue[$adjustedColumnNumber]="$previousPartialMetadata ${fieldValue[$adjustedColumnNumber]}"
                previousPartialMetadata=""
            else
                fieldValue[$adjustedColumnNumber]=$(echo $cleanLine | awk 'BEGIN { FPAT = "([^,]*)|(\"[^\"]+\")" } {print $'$columnCounter'}' | sed -e 's/\"//g')
            fi
            columnCounter=$(($columnCounter + 1))
        done
        previousColumnCount=$(($adjustedColumnNumber))
        previousPartialMetadata="${fieldValue[$adjustedColumnNumber]}"
        matchedRowNumber=$(($matchedRowNumber + 1))
    else
        columnCounter=1
        while [ $columnCounter -lt $lastColumnNumber ];
        do
            adjustedColumnNumber=$(($firstColumnNumber + $columnCounter -1))
            if [[ "$previousPartialMetadata" != "" ]];
            then
                fieldValue[$adjustedColumnNumber]=$(echo $cleanLine | awk 'BEGIN { FPAT = "([^,]*)|(\"[^\"]+\")" } {print $'$columnCounter'}' | sed -e 's/\"//g')
                fieldValue[$adjustedColumnNumber]="$previousPartialMetadata ${fieldValue[$adjustedColumnNumber]}"
                previousPartialMetadata=""
            else
                fieldValue[$adjustedColumnNumber]=$(echo $cleanLine | awk 'BEGIN { FPAT = "([^,]*)|(\"[^\"]+\")" } {print $'$columnCounter'}' | sed -e 's/\"//g')
            fi
            columnCounter=$(($columnCounter + 1))
        done
        lineReadComplete="true"
    fi
    # --------------------------------------------------
done

# --------------------------------------------------
# Writing XML File

#fileDestination="/opt/olympusat/xmlsForMetadataImport/${fieldValue[3]}.xml"
fileDestination="/opt/olympusat/xmlsForMetadataImport/$cantemoItemTitle.xml"
#fileDestinationSpanish="/opt/olympusat/xmlsForMetadataImport/${fieldValue[3]}_ES.xml"
fileDestinationSpanish=$(echo "/opt/olympusat/xmlsForMetadataImport/"$cantemoItemTitle"_ES.xml")
#fileDestinationEnglish="/opt/olympusat/xmlsForMetadataImport/${fieldValue[3]}_EN.xml"
fileDestinationEnglish=$(echo "/opt/olympusat/xmlsForMetadataImport/"$cantemoItemTitle"_EN.xml")
#fileDestinationExternal="/opt/olympusat/xmlsForMetadataImport/${fieldValue[3]}_EN.xml"
fileDestinationExternal=$(echo "/opt/olympusat/xmlsForMetadataImport/"$cantemoItemTitle"_External.xml")

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
    if [ "${fieldName[$columnCounter]}" == "Genres" ];
    then
        fieldValue[$columnCounter]=$(convertToCamelCase ${fieldValue[$columnCounter]})
        primaryGenre=$(echo "${fieldValue[$columnCounter]}" | awk -F "," '{print $1}')
        secondaryGenres=$(echo "${fieldValue[$columnCounter]}" | cut -d "," -f2-$NF)
        echo "      <field>
         <name>oly_primaryGenre</name>
         <value>$primaryGenre</value>
      </field>" >> "$fileDestination"
        columnCounter=$(($columnCounter + 1))
        if [ "$secondaryGenres" != "" ];
        then
            createTags "$secondaryGenres" "oly_secondaryGenres" "$fileDestination"
        fi
    else
        # if [[ ("${fieldName[$columnCounter]}" = *"Es") && ("${fieldName[$columnCounter]}" != "oly_title"*) ]];
        if [[ ("${fieldName[$columnCounter]}" = "oly_descriptionEs") || ("${fieldName[$columnCounter]}" = "oly_shortDescriptionEs") || ("${fieldName[$columnCounter]}" = "oly_socialDescriptionEs") || ("${fieldName[$columnCounter]}" = "oly_logLineEs") ]];
        then
            echo "        <field>
          <name>${fieldName[$columnCounter]}</name>
          <value>${fieldValue[$columnCounter]}</value>
        </field>" >> "$fileDestinationSpanish"
    columnCounter=$(($columnCounter + 1))
        else
            # if [[ ("${fieldName[$columnCounter]}" = *"En") && ("${fieldName[$columnCounter]}" != "oly_title"*) ]];
            if [[ ("${fieldName[$columnCounter]}" = "oly_descriptionEn") || ("${fieldName[$columnCounter]}" = "oly_shortDescriptionEn") || ("${fieldName[$columnCounter]}" = "oly_socialDescriptionEn") || ("${fieldName[$columnCounter]}" = "oly_logLineEn") ]];
            then
                echo "        <field>
          <name>${fieldName[$columnCounter]}</name>
          <value>${fieldValue[$columnCounter]}</value>
        </field>" >> "$fileDestinationEnglish"
            columnCounter=$(($columnCounter + 1))
            else
                if [[ ("${fieldName[$columnCounter]}" = "oly_cast") || ("${fieldName[$columnCounter]}" = "oly_director") || ("${fieldName[$columnCounter]}" = "oly_producer") || ("${fieldName[$columnCounter]}" = "oly_tags") ]];
                then
                    createTags "${fieldValue[$columnCounter]}" "${fieldName[$columnCounter]}" "$fileDestination"
                    columnCounter=$(($columnCounter + 1))
                else
                    if [[ ("${fieldName[$columnCounter]}" = "oly_contentType") || ("${fieldName[$columnCounter]}" = "oly_originalMpaaRating") || ("${fieldName[$columnCounter]}" = "oly_originalRtcRating") || ("${fieldName[$columnCounter]}" = "oly_originalRating") || ("${fieldName[$columnCounter]}" = "oly_countryOfOrigin") || ("${fieldName[$columnCounter]}" = "oly_closedCaptionLanguage") || ("${fieldName[$columnCounter]}" = "oly_originalLanguage") ]];
                    then
                        fieldValue[$columnCounter]=$(convertToCamelCase ${fieldValue[$columnCounter]})
                        if [[ "${fieldName[$columnCounter]}" = "oly_countryOfOrigin" ]];
                        then
                            createTags "${fieldValue[$columnCounter]}" "${fieldName[$columnCounter]}" "$fileDestination"
                        else
                            echo "      <field>
         <name>${fieldName[$columnCounter]}</name>
         <value>${fieldValue[$columnCounter]}</value>
      </field>" >> "$fileDestination"
                        fi
                        columnCounter=$(($columnCounter + 1))
                    else
                        if [[ "${fieldName[$columnCounter]}" = "oly_closedCaptionInfo-closedcaptionavailable" ]];
                        then
                            if [[ "${fieldValue[$columnCounter]}" = "Yes" ]];
                            then
                                oly_closedCaptionInfoCC="closedcaptionavailable"
                                echo "      <field>
         <name>oly_closedCaptionInfo</name>
         <value>$oly_closedCaptionInfoCC</value>
      </field>" >> "$fileDestination"
                                columnCounter=$(($columnCounter + 1))
                            else
                                oly_closedCaptionInfoCC=""
                                echo "      <field>
         <name>oly_closedCaptionInfo</name>
         <value>$oly_closedCaptionInfoCC</value>
      </field>" >> "$fileDestination"
                                columnCounter=$(($columnCounter + 1))
                            fi
                        else
                            if [[ "${fieldName[$columnCounter]}" = "oly_closedCaptionInfo-broadcastedontvwithcc" ]];
                            then
                                if [[ "${fieldValue[$columnCounter]}" = "Yes" ]];
                                then
                                    oly_closedCaptionInfoBC="broadcastedontvwithcc"
                                    echo "      <field>
         <name>oly_closedCaptionInfo</name>
         <value>$oly_closedCaptionInfoBC</value>
      </field>" >> "$fileDestination"
                                    columnCounter=$(($columnCounter + 1))
                                else
                                    oly_closedCaptionInfoBC=""
                                    echo "      <field>
         <name>oly_closedCaptionInfo</name>
         <value>$oly_closedCaptionInfoBC</value>
      </field>" >> "$fileDestination"
                                    columnCounter=$(($columnCounter + 1))
                                fi
                            else
                                if [[ ("${fieldName[$columnCounter]}" = "oly_clipLink") || ("${fieldName[$columnCounter]}" = "oly_promoLink") || ("${fieldName[$columnCounter]}" = "oly_trailerLink") ]];
                                then
                                    echo "        <field>
          <name>${fieldName[$columnCounter]}</name>
          <value>${fieldValue[$columnCounter]}</value>
        </field>" >> "$fileDestinationExternal"
                                    columnCounter=$(($columnCounter + 1))
                                else
                                    if [[ "${fieldName[$columnCounter]}" = "oly_rightslineContractId" ]];
                                    then
                                        numberOfCharacters=$(echo "${fieldValue[$columnCounter]}" | wc -c)
                                        if [[ $numberOfCharacters != 1 ]];
                                        then
                                            contractString="CA_"
                                            missingCharacters=$((7 - $numberOfCharacters))
                                            for (( k=1 ; k<=$missingCharacters ; k++ ));
                                            do
                                                contractString="$contractString""0"
                                            done
                                            contractString="$contractString""${fieldValue[$columnCounter]}"
                                            echo "      <field>
         <name>${fieldName[$columnCounter]}</name>
         <value>$contractString</value>
      </field>" >> "$fileDestination"
                                            columnCounter=$(($columnCounter + 1))
                                        else
                                            echo "      <field>
         <name>${fieldName[$columnCounter]}</name>
         <value>$contractString</value>
      </field>" >> "$fileDestination"
                                            columnCounter=$(($columnCounter + 1))
                                        fi
                                    else
                                        echo "      <field>
         <name>${fieldName[$columnCounter]}</name>
         <value>${fieldValue[$columnCounter]}</value>
      </field>" >> "$fileDestination"
                                        columnCounter=$(($columnCounter + 1))
                                    fi
                                fi
                            fi
                        fi
                    fi
                fi
            fi
        fi
    fi
done
if [ -e "$fileDestinationExternal" ];
then
    echo "      <group>
        <name>External Resources</name>" >> "$fileDestination"
    cat "$fileDestinationExternal" >> "$fileDestination"
    echo "      </group>" >> "$fileDestination"
    rm -f "$fileDestinationExternal"
fi
if [ -e "$fileDestinationSpanish" ];
then
    echo "      <group>
        <name>Spanish Synopsis</name>" >> "$fileDestination"
    cat "$fileDestinationSpanish" >> "$fileDestination"
    echo "      </group>" >> "$fileDestination"
    rm -f "$fileDestinationSpanish"
fi
if [ -e "$fileDestinationEnglish" ];
then
    echo "      <group>
        <name>English Synopsis</name>" >> "$fileDestination"
    cat "$fileDestinationEnglish" >> "$fileDestination"
    echo "      </group>" >> "$fileDestination"
    rm -f "$fileDestinationEnglish"
fi
# --------------------------------------------------

# --------------------------------------------------
# Print XML footer
echo "    </timespan>
</MetadataDocument>" >> "$fileDestination"
# --------------------------------------------------

sleep 5

# ----------------------------------------------------
# API Call to Update Metadata

url="http://10.1.1.34:8080/API/import/sidecar/$cantemoItemId?sidecar=/opt/olympusat/xmlsForMetadataImport/$cantemoItemTitle.xml"
#echo "Item ID - $cantemoItemId"
#echo "Item Title - $cantemoItemTitle"
#echo "URL - $url"

curl --location --request POST $url --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0'

IFS=$saveIFS

exit 0