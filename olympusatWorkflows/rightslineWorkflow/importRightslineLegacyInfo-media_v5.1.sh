#!/bin/bash

# This script gathers Metadata from Rightsline (for legacy contents) and apply them to Cantemo
# PREREQUISITE: This script must receive Cantemo item ID as an argument, column header and file location of Rightsline CSV export.
# It requests oly_rightslineItemId from Vidispine and updates metadata fields
#   Usage: importRightslineLegacyInfo-media_vX.X.sh [Cantemo item ID] [column header which contains Rightsline ID]
#          [file which contains csv export from Rightsline] [Username for who triggered script]

# System requirements: This script can run on LINUX and MacOS

saveIFS=$IFS
IFS=$(echo -e "\n\b\015")

# --------------------------------------------------
# External funtions to include
. /opt/olympusat/scriptsLibrary/olympusatCantemo.lib
# --------------------------------------------------

# --------------------------------------------------
# Internal funtions
releaseLock ()
{
    rm -f "$lockFile"
}

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
        currentValue=$(echo "$currentFieldValue" | awk -F'[|,]' '{print $'$j'}' | sed -e 's/^[ ]*//' )
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
export mydate=$(date +%Y-%m-%d)
#logfile="/opt/olympusat/logs/importRightslineLegacyInfo-$mydate.log"
logfile="/opt/olympusat/logs/ingestMetadataWorkflow-$mydate.log"
# --------------------------------------------------
# Lock file to ensure only one job runs at a time
lockFile="/opt/olympusat/workflowQueues/importRightslineLegacyInfo/jobQueue.lock"
# Acquire the lock by waiting if another job is running
while [ -f "$lockFile" ];
do
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadata) - [$cantemoItemId] - Waiting for the previous job to finish..." >> "$logfile"    
    sleep 2
done
# Acquire the lock for this job
touch "$lockFile"
# Ensure that the lock is released when the job finishes
trap releaseLock EXIT
# --------------------------------------------------
export cantemoItemTitleCode=$(filterVidispineItemMetadata "$cantemoItemId" "metadata" "oly_titleCode")
export cantemoItemTitle=$(filterVidispineItemMetadata "$cantemoItemId" "metadata" "title")
# --------------------------------------------------

# --------------------------------------------------
# Sanitize cantemoItemTitleCode to remove any empty spaces
echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadata) - [$cantemoItemId] - Import Metadata Job Initiated by {$userName}" >> "$logfile"
cantemoItemTitleCodeCleaned=$(echo $cantemoItemTitleCode | tr -d ' ')
if [[ "$cantemoItemTitleCodeCleaned" != "$cantemoItemTitleCode" ]];
then
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadata) - [$cantemoItemId] - Updating Cantemo with Sanitized Title Code - [$cantemoItemTitleCode] - {$rightslineItemIdCleaned}" >> "$logfile"
    updateVidispineMetadata $cantemoItemId "oly_titleCode" "$cantemoItemTitleCodeCleaned"
    sleep 5
    export cantemoItemTitleCode=$(filterVidispineItemMetadata "$cantemoItemId" "metadata" "oly_titleCode")
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadata) - [$cantemoItemId] - Newly Updated Title Code from Cantemo - [$cantemoItemTitleCode]" >> "$logfile"
else
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadata) - [$cantemoItemId] - Title Code from Cantemo - [$cantemoItemTitleCode]" >> "$logfile"
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadata) - [$cantemoItemId] - Title from Cantemo - [$cantemoItemTitle]" >> "$logfile"
fi
# --------------------------------------------------
#echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadata) - [$cantemoItemId] - Reading Information in CSV" >> "$logfile"
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
        cantemoItemTitleCodeColumn=$columnCounter
        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadata) - [$cantemoItemId] - cantemoItemTitleCodeColumn - [$cantemoItemTitleCodeColumn]" >> "$logfile"
    fi
    if [[ "${fieldName[$columnCounter]}" = "" ]];
    then
        noMoreColumns="true"
        columnCounts=$(($columnCounter -1))
    else
        columnCounter=$(($columnCounter + 1))
    fi
done
#echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadata) - [$cantemoItemId] - inputFile - [$inputFile]" >> "$logfile"
#echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadata) - [$cantemoItemId] - cantemoItemTitleCode - [$cantemoItemTitleCode]" >> "$logfile"
#echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadata) - [$cantemoItemId] - cantemoItemTitleCodeColumn - [$cantemoItemTitleCodeColumn]" >> "$logfile"
for matchedRow in $(grep -n "$inputFile" -e "\<$cantemoItemTitleCode\>" | awk -F ',' '{print $'1'}')
do
    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadata) - [$cantemoItemId] - matchedRow - [$matchedRow]" >> "$logfile"
    matchedValue=$(echo $matchedRow | awk -F ':' '{print $2}')
    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadata) - [$cantemoItemId] - matchedValue - [$matchedValue]" >> "$logfile"
    matchedRowNumber=$(echo $matchedRow | awk -F ':' '{print $1}')
    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadata) - [$cantemoItemId] - matchedRowNumber - [$matchedRowNumber]" >> "$logfile"
done
# --------------------------------------------------

# --------------------------------------------------
# Read Specific Line
if [ ! -z "$matchedRowNumber" ];
then
    line=$(sed -n ''$matchedRowNumber'p' "$inputFile")
    cleanLine=$(echo $line | sed -e 's/\"\"/-/g')
    cleanLine=$(echo "$cleanLine" | sed -e 's/&/\&amp;/g')
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
    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadata) - [$cantemoItemId] - Creating XML File with Information" >> "$logfile"
    fileDestination="/opt/olympusat/xmlsForMetadataImport/$cantemoItemId.xml"
    fileDestinationSpanish=$(echo "/opt/olympusat/xmlsForMetadataImport/"$cantemoItemId"_ES.xml")
    fileDestinationEnglish=$(echo "/opt/olympusat/xmlsForMetadataImport/"$cantemoItemId"_EN.xml")
    fileDestinationExternal=$(echo "/opt/olympusat/xmlsForMetadataImport/"$cantemoItemId"_External.xml")
    fileDestinationClosedCaptionInfo=$(echo "/opt/olympusat/xmlsForMetadataImport/"$cantemoItemId"_ClosedCaptionInfo.xml")
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
    # Checking Cantemo Item for existing metadata
    urlGetItemBulkMetadata="http://10.1.1.34:8080/API/item/$cantemoItemId/metadata?field=oly_rightslineEntityTitle%2Coly_titleCode%2Coly_rightslineContractId%2Coly_contentType%2Coly_originalLanguage%2Coly_cast%2Coly_director%2Coly_episodeNumber%2Coly_firstUseDate%2Coly_producer%2Coly_originalMpaaRating%2Coly_originalRtcRating%2Coly_originalRating%2Coly_readyForAirDate%2Coly_seasonNumber%2Coly_titleEn%2Coly_titleEs%2Coly_closedCaptionInfo%2Coly_countryOfOrigin%2Coly_primaryGenre%2Coly_secondaryGenres%2Coly_closedCaptionLanguage%2Coly_originalTitle%2Coly_productionCompany%2Coly_tags%2Coly_productionYear%2Coly_numberOfEpisodes%2Coly_totalSeasonsBySeries%2Coly_totalEpisodesBySeries%2Coly_totalEpisodesBySeason%2Coly_editorNotes%2Coly_format%2Coly_timecode&terse=yes&includeConstraintValue=all"
    bulkMetadataHttpResponse=$(curl --location --request GET $urlGetItemBulkMetadata --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=Tkb9vkSC8v4SceB8CHUyB3iaMPjvgoHrzhLrvo36agG3wqv0jHc7nsOtdTo9JEyM')
    sleep 1
    urlGetItemSpaSynopMetadata="http://10.1.1.34:8080/API/item/$cantemoItemId/metadata?field=oly_descriptionEs%2Coly_shortDescriptionEs%2Coly_socialDescriptionEs%2Coly_logLineEs&group=Spanish%20Synopsis&terse=yes"
    spaSynopMetadataHttpResponse=$(curl --location --request GET $urlGetItemSpaSynopMetadata --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=Tkb9vkSC8v4SceB8CHUyB3iaMPjvgoHrzhLrvo36agG3wqv0jHc7nsOtdTo9JEyM')
    sleep 1
    urlGetItemEngSynopMetadata="http://10.1.1.34:8080/API/item/$cantemoItemId/metadata?field=oly_descriptionEn%2Coly_shortDescriptionEn%2Coly_socialDescriptionEn%2Coly_logLineEn&group=English%20Synopsis&terse=yes"
    engSynopMetadataHttpResponse=$(curl --location --request GET $urlGetItemEngSynopMetadata --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=Tkb9vkSC8v4SceB8CHUyB3iaMPjvgoHrzhLrvo36agG3wqv0jHc7nsOtdTo9JEyM')
    sleep 1
    urlGetItemExtResourcesMetadata="http://10.1.1.34:8080/API/item/$cantemoItemId/metadata?field=oly_trailerLink%2Coly_clipLink%2Coly_promoLink%2Coly_screenerLink&group=External%20Resources&terse=yes"
    extResourcesMetadataHttpResponse=$(curl --location --request GET $urlGetItemExtResourcesMetadata --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=Tkb9vkSC8v4SceB8CHUyB3iaMPjvgoHrzhLrvo36agG3wqv0jHc7nsOtdTo9JEyM')
    sleep 1
    # --------------------------------------------------

    # --------------------------------------------------
    # Choose what information from the CSV export file needed to be printed
    columnCounter=1
    while [ $columnCounter -le $columnCounts ];
    do
        case "${fieldName[$columnCounter]}" in
            "Genres")
                if [[ ! -z "${fieldValue[$columnCounter]}" && "$bulkMetadataHttpResponse" != *"</oly_primaryGenre>"* ]];
                then
                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadata) - [$cantemoItemId] - [${fieldValue[$columnCounter]}] Column NOT empty" >> "$logfile"
                    fieldValue[$columnCounter]=$(convertToCamelCase ${fieldValue[$columnCounter]})
                    primaryGenre=$(echo "${fieldValue[$columnCounter]}" | awk -F "," '{print $1}')
                    secondaryGenres=$(echo "${fieldValue[$columnCounter]}" | cut -d "," -f2-$NF)
                    if [[ "$primaryGenre" = "$secondaryGenres" || -z "$secondaryGenres" ]];
                    then
                        secondaryGenres=""
                    fi
                    echo "      <field>
         <name>oly_primaryGenre</name>
         <value>$primaryGenre</value>
      </field>" >> "$fileDestination"
                    columnCounter=$(($columnCounter + 1))
                    createTags "$secondaryGenres" "oly_secondaryGenres" "$fileDestination"
                else
                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadata) - [$cantemoItemId] - [${fieldValue[$columnCounter]}] Column is EMPTY" >> "$logfile"
                    columnCounter=$(($columnCounter + 1))
                fi
            ;;
            "oly_descriptionEs"|"oly_shortDescriptionEs"|"oly_socialDescriptionEs"|"oly_logLineEs")
                if [[ ! -z "${fieldValue[$columnCounter]}" && "$spaSynopMetadataHttpResponse" != *"</${fieldName[$columnCounter]}>"* ]];
                then
                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadata) - [$cantemoItemId] - [${fieldValue[$columnCounter]}] Column NOT empty" >> "$logfile"
                    echo "        <field>
          <name>${fieldName[$columnCounter]}</name>
          <value>${fieldValue[$columnCounter]}</value>
        </field>" >> "$fileDestinationSpanish"
                    columnCounter=$(($columnCounter + 1))
                else
                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadata) - [$cantemoItemId] - [${fieldValue[$columnCounter]}] Column is EMPTY" >> "$logfile"
                    columnCounter=$(($columnCounter + 1))
                fi
            ;;
            "oly_descriptionEn"|"oly_shortDescriptionEn"|"oly_socialDescriptionEn"|"oly_logLineEn")
                if [[ ! -z "${fieldValue[$columnCounter]}" && "$engSynopMetadataHttpResponse" != *"</${fieldName[$columnCounter]}>"* ]];
                then
                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadata) - [$cantemoItemId] - [${fieldValue[$columnCounter]}] Column NOT empty" >> "$logfile"
                    echo "        <field>
          <name>${fieldName[$columnCounter]}</name>
          <value>${fieldValue[$columnCounter]}</value>
        </field>" >> "$fileDestinationEnglish"
                    columnCounter=$(($columnCounter + 1))
                else
                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadata) - [$cantemoItemId] - [${fieldValue[$columnCounter]}] Column is EMPTY" >> "$logfile"
                    columnCounter=$(($columnCounter + 1))
                fi
            ;;
            "oly_cast"|"oly_director"|"oly_producer"|"oly_tags"|"oly_productionCompany")
                if [[ ! -z "${fieldValue[$columnCounter]}" && "$bulkMetadataHttpResponse" != *"</${fieldName[$columnCounter]}>"* ]];
                then
                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadata) - [$cantemoItemId] - [${fieldValue[$columnCounter]}] Column NOT empty" >> "$logfile"
                    createTags "${fieldValue[$columnCounter]}" "${fieldName[$columnCounter]}" "$fileDestination"
                    columnCounter=$(($columnCounter + 1))
                else
                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadata) - [$cantemoItemId] - [${fieldValue[$columnCounter]}] Column is EMPTY" >> "$logfile"
                    columnCounter=$(($columnCounter + 1))
                fi
            ;;
            "oly_contentType"|"oly_originalMpaaRating"|"oly_originalRtcRating"|"oly_originalRating"|"oly_countryOfOrigin"|"oly_closedCaptionLanguage"|"oly_originalLanguage")
                if [[ ! -z "${fieldValue[$columnCounter]}" && "$bulkMetadataHttpResponse" != *"</${fieldName[$columnCounter]}>"* ]];
                then
                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadata) - [$cantemoItemId] - [${fieldValue[$columnCounter]}] Column NOT empty" >> "$logfile"
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
                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadata) - [$cantemoItemId] - [${fieldValue[$columnCounter]}] Column is EMPTY" >> "$logfile"
                    columnCounter=$(($columnCounter + 1))
                fi
            ;;
            "oly_closedCaptionInfo-closedcaptionavailable")
                if [[ "${fieldValue[$columnCounter]}" == "Yes" ]];
                then
                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadata) - [$cantemoItemId] - [${fieldValue[$columnCounter]}] Column NOT empty" >> "$logfile"
                    echo "          <value>closedcaptionavailable</value>" >> "$fileDestinationClosedCaptionInfo"
                    columnCounter=$(($columnCounter + 1))
                else
                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadata) - [$cantemoItemId] - [${fieldValue[$columnCounter]}] Column is EMPTY" >> "$logfile"
                    columnCounter=$(($columnCounter + 1))
                fi
            ;;
            "oly_closedCaptionInfo-broadcastedontvwithcc")
                if [[ "${fieldValue[$columnCounter]}" == "Yes" ]];
                then
                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadata) - [$cantemoItemId] - [${fieldValue[$columnCounter]}] Column NOT empty" >> "$logfile"
                    echo "          <value>broadcastedontvwithcc</value>" >> "$fileDestinationClosedCaptionInfo"
                    columnCounter=$(($columnCounter + 1))
                else
                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadata) - [$cantemoItemId] - [${fieldValue[$columnCounter]}] Column is EMPTY" >> "$logfile"
                    columnCounter=$(($columnCounter + 1))
                fi
            ;;
            "oly_clipLink"|"oly_promoLink"|"oly_trailerLink")
                if [[ ! -z "${fieldValue[$columnCounter]}" && "$extResourcesMetadataHttpResponse" != *"</${fieldName[$columnCounter]}>"* ]];
                then
                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadata) - [$cantemoItemId] - [${fieldValue[$columnCounter]}] Column NOT empty" >> "$logfile"
                    echo "        <field>
          <name>${fieldName[$columnCounter]}</name>
          <value>${fieldValue[$columnCounter]}</value>
        </field>" >> "$fileDestinationExternal"
                    columnCounter=$(($columnCounter + 1))
                else
                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadata) - [$cantemoItemId] - [${fieldValue[$columnCounter]}] Column is EMPTY" >> "$logfile"
                    columnCounter=$(($columnCounter + 1))
                fi
            ;;
            "oly_rightslineContractId")
                if [[ ! -z "${fieldValue[$columnCounter]}" && "$bulkMetadataHttpResponse" != *"</${fieldName[$columnCounter]}>"* ]];
                then
                    if [[ "${fieldValue[$columnCounter]}" == *"|"* ]];
                    then
                        firstContractId=$(echo "${fieldValue[$columnCounter]}" | awk -F '|' '{print $1}')
                        secondContractId=$(echo "${fieldValue[$columnCounter]}" | awk -F '|' '{print $2}')

                        firstIdNumberOfCharacters=$(echo "$firstContractId" | wc -c)
                        if [[ $firstIdNumberOfCharacters != 1 ]];
                        then
                            firstContractString="CA_"
                            missingCharacters=$((7 - $firstIdNumberOfCharacters))
                            for (( k=1 ; k<=$missingCharacters ; k++ ));
                            do
                                firstContractString="$firstContractString""0"
                            done
                            firstContractString="$firstContractString""$firstContractId"
                            echo "      <field>
         <name>${fieldName[$columnCounter]}</name>
         <value>$firstContractString</value>
      </field>" >> "$fileDestination"
                            columnCounter=$(($columnCounter + 1))
                        else
                            echo "      <field>
         <name>${fieldName[$columnCounter]}</name>
         <value>$firstContractString</value>
      </field>" >> "$fileDestination"
                            columnCounter=$(($columnCounter + 1))
                        fi
                        secondIdNumberOfCharacters=$(echo "$secondContractId" | wc -c)
                        if [[ $secondIdNumberOfCharacters != 1 ]];
                        then
                            secondContractString="CA_"
                            missingCharacters=$((7 - $secondIdNumberOfCharacters))
                            for (( k=1 ; k<=$missingCharacters ; k++ ));
                            do
                                secondContractString="$secondContractString""0"
                            done
                            secondContractString="$secondContractString""$secondContractId"
                            echo "      <field>
         <name>oly_alternateContractIds</name>
         <value>$secondContractString</value>
      </field>" >> "$fileDestination"
                            columnCounter=$(($columnCounter + 1))
                        else
                            echo "      <field>
         <name>oly_alternateContractIds</name>
         <value>$secondContractString</value>
      </field>" >> "$fileDestination"
                            columnCounter=$(($columnCounter + 1))
                        fi
                    else
                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadata) - [$cantemoItemId] - [${fieldValue[$columnCounter]}] Column NOT empty" >> "$logfile"
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
                    fi
                else
                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadata) - [$cantemoItemId] - [${fieldValue[$columnCounter]}] Column is EMPTY" >> "$logfile"
                    columnCounter=$(($columnCounter + 1))
                fi
            ;;
            "oly_rightslineItemId")
                if [[ ! -z "${fieldValue[$columnCounter]}" && "$bulkMetadataHttpResponse" != *"</${fieldName[$columnCounter]}>"* ]];
                then
                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadata) - [$cantemoItemId] - [${fieldValue[$columnCounter]}] Column NOT empty" >> "$logfile"
                    export rightslineItemId="${fieldValue[$columnCounter]}"
                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadata) - [$cantemoItemId] - oly_rightslineItemId - [$rightslineItemId]" >> "$logfile"
                    echo "      <field>
         <name>${fieldName[$columnCounter]}</name>
         <value>${fieldValue[$columnCounter]}</value>
      </field>" >> "$fileDestination"
                    columnCounter=$(($columnCounter + 1))
                else
                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadata) - [$cantemoItemId] - [${fieldValue[$columnCounter]}] Column is EMPTY" >> "$logfile"
                    columnCounter=$(($columnCounter + 1))
                fi
            ;;
            "oly_numberOfEpisodes")
                if [[ ! -z "${fieldValue[$columnCounter]}" ]];
                then
                    if [[ "${fieldValue[5]}" == "Series" && "$bulkMetadataHttpResponse" != *"</oly_totalEpisodesBySeries>"* ]];
                    then
                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadata) - [$cantemoItemId] - [${fieldValue[$columnCounter]}] Column NOT empty" >> "$logfile"
                        echo "      <field>
         <name>oly_totalEpisodesBySeries</name>
         <value>${fieldValue[$columnCounter]}</value>
      </field>" >> "$fileDestination"
                        columnCounter=$(($columnCounter + 1))
                    fi
                    if [[ "${fieldValue[5]}" == "Season" && "$bulkMetadataHttpResponse" != *"</oly_totalEpisodesBySeason>"* ]];
                    then
                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadata) - [$cantemoItemId] - [${fieldValue[$columnCounter]}] Column NOT empty" >> "$logfile"
                        echo "      <field>
         <name>oly_totalEpisodesBySeason</name>
         <value>${fieldValue[$columnCounter]}</value>
      </field>" >> "$fileDestination"
                        columnCounter=$(($columnCounter + 1))
                    fi
                else
                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadata) - [$cantemoItemId] - [${fieldValue[$columnCounter]}] Column is EMPTY" >> "$logfile"
                    columnCounter=$(($columnCounter + 1))
                fi
            ;;
            *)
                if [[ ! -z "${fieldValue[$columnCounter]}" && "$bulkMetadataHttpResponse" != *"</${fieldName[$columnCounter]}>"* ]];
                then
                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadata) - [$cantemoItemId] - [${fieldValue[$columnCounter]}] Column NOT empty" >> "$logfile"
                    echo "      <field>
         <name>${fieldName[$columnCounter]}</name>
         <value>${fieldValue[$columnCounter]}</value>
      </field>" >> "$fileDestination"
                    columnCounter=$(($columnCounter + 1))
                else
                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadata) - [$cantemoItemId] - [${fieldValue[$columnCounter]}] Column is EMPTY" >> "$logfile"
                    columnCounter=$(($columnCounter + 1))
                fi
            ;;
        esac
    done
    if [ -e "$fileDestinationClosedCaptionInfo" ];
    then
        echo "      <field>
          <name>oly_closedCaptionInfo</name>" >> "$fileDestination"
        cat "$fileDestinationClosedCaptionInfo" >> "$fileDestination"
        echo "      </field>" >> "$fileDestination"
        rm -f "$fileDestinationClosedCaptionInfo"
    fi
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
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadata) - [$cantemoItemId] - XML has been created {$cantemoItemId.xml}" >> "$logfile"
    # --------------------------------------------------
    sleep 5
    # ----------------------------------------------------
    # API Call to Update Metadata
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadata) - [$cantemoItemId] - Triggering API Call to Import XML into Cantemo" >> "$logfile"
    url="http://10.1.1.34:8080/API/import/sidecar/$cantemoItemId?sidecar=/opt/olympusat/xmlsForMetadataImport/$cantemoItemId.xml"
    importXmlHttpResponse=$(curl --location --request POST $url --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0')
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadata) - [$cantemoItemId] - url [$url]" >> "$logfile"
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadata) - [$cantemoItemId] - importXmlHttpResponse [$importXmlHttpResponse]" >> "$logfile"
    sleep 2
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadata) - [$cantemoItemId] - Moving XML to zCompleted Folder" >> "$logfile"
    sleep 2
    mv "$fileDestination" "/opt/olympusat/xmlsForMetadataImport/zCompleted/"
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadata) - [$cantemoItemId] - Triggering Shell Script to Import Contract Information" >> "$logfile"
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadata) - [$cantemoItemId] - UserName {$userName} - Rightsline Item ID ($rightslineItemId)" >> "$logfile"
    bash -c "sudo /opt/olympusat/scriptsActive/importRightslineLegacyInfo-contract_v5.1.sh $cantemoItemId $userName oly_rightslineItemId /opt/olympusat/resources/rightslineData/RIGHTSLINE_CONTRACT_CODE_INFO_DATABASE_2024-07-31.csv $rightslineItemId > /dev/null 2>&1"
else
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadata) - [$cantemoItemId] - Import Metadata Job Skipped - No Matching Rightsline Item Id Found in CSV - {$rightslineItemId}" >> "$logfile"
fi

IFS=$saveIFS

exit 0