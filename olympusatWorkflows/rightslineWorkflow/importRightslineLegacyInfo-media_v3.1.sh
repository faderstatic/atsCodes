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
export rightslineItemId=$(filterVidispineItemMetadata "$cantemoItemId" "metadata" "oly_rightslineItemId")
export cantemoItemTitle=$(filterVidispineItemMetadata "$cantemoItemId" "metadata" "title")

export mydate=$(date +%Y-%m-%d)
logfile="/opt/olympusat/logs/importRightslineLegacyInfo-$mydate.log"

# --------------------------------------------------

# --------------------------------------------------
# Sanitize rightslineItemId to remove any empty spaces
echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadta) - [$cantemoItemId] - Import Metadata Job Initiated by {$userName}" >> "$logfile"

rightslineItemIdCleaned=$(echo $rightslineItemId | tr -d ' ')

if [[ "$rightslineItemIdCleaned" != "$rightslineItemId" ]];
then
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadta) - [$cantemoItemId] - Updating Cantemo with Sanitized Rightsline Item ID - [$rightslineItemId] - {$rightslineItemIdCleaned}" >> "$logfile"
    updateVidispineMetadata $cantemoItemId "oly_rightslineItemId" "$rightslineItemIdCleaned"

    sleep 5

    export rightslineItemId=$(filterVidispineItemMetadata "$cantemoItemId" "metadata" "oly_rightslineItemId")
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadta) - [$cantemoItemId] - Newly Updated Rightsline Item ID from Cantemo - [$rightslineItemId]" >> "$logfile"
fi

# --------------------------------------------------
# Check to see if import has already ran on item
urlGetItemInfo="http://10.1.1.34:8080/API/item/$cantemoItemId/metadata?field=oly_rightslineInfo&terse=yes"
httpResponse=$(curl --location --request GET $urlGetItemInfo --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=Tkb9vkSC8v4SceB8CHUyB3iaMPjvgoHrzhLrvo36agG3wqv0jHc7nsOtdTo9JEyM')

if [[ "$httpResponse" != *"metadataimported"* ]];
then
    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadta) - [$cantemoItemId] - Reading Information in CSV" >> "$logfile"
    
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
        
        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadta) - [$cantemoItemId] - Creating XML File with Information" >> "$logfile"

        fileDestination="/opt/olympusat/xmlsForMetadataImport/$cantemoItemId.xml"
        fileDestinationSpanish=$(echo "/opt/olympusat/xmlsForMetadataImport/"$cantemoItemId"_ES.xml")
        fileDestinationEnglish=$(echo "/opt/olympusat/xmlsForMetadataImport/"$cantemoItemId"_EN.xml")
        fileDestinationExternal=$(echo "/opt/olympusat/xmlsForMetadataImport/"$cantemoItemId"_External.xml")

        # --------------------------------------------------
        # Print XML header
        echo "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>
<MetadataDocument xmlns=\"http://xml.vidispine.com/schema/vidispine\">
  <group>Olympusat</group>
    <timespan end=\"+INF\" start=\"-INF\">
      <field>
         <name>title</name>
         <value>$cantemoItemTitle</value>
      </field>
      <field>
         <name>oly_rightslineInfo</name>
         <value>metadataimported</value>
      </field>" > "$fileDestination"
        # --------------------------------------------------

        # --------------------------------------------------
        # Checking Cantemo Item for existing metadata

        urlGetItemBulkMetadata="http://10.1.1.34:8080/API/item/$cantemoItemId/metadata?field=oly_rightslineEntityTitle%2Coly_titleCode%2Coly_rightslineContractId%2Coly_contentType%2Coly_cast%2Coly_director%2Coly_episodeNumber%2Coly_firstUseDate%2Coly_producer%2Coly_originalMpaaRating%2Coly_originalRtcRating%2Coly_originalRating%2Coly_readyForAirDate%2Coly_seasonNumber%2Coly_titleEn%2Coly_titleEs%2Coly_closedCaptionInfo%2Coly_countryOfOrigin%2Coly_primaryGenre%2Coly_secondaryGenres%2Coly_closedCaptionLanguage%2Coly_originalTitle%2Coly_productionCompany%2Coly_tags%2Coly_productionYear%2Coly_numberOfEpisodes%2Coly_totalSeasonsBySeries%2Coly_totalEpisodesBySeries%2Coly_totalEpisodesBySeason%2Coly_editorNotes%2Coly_format%2Coly_timecode&terse=yes&includeConstraintValue=all"
        bulkMetadataHttpResponse=$(curl --location --request GET $urlGetItemBulkMetadata --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=Tkb9vkSC8v4SceB8CHUyB3iaMPjvgoHrzhLrvo36agG3wqv0jHc7nsOtdTo9JEyM')

        echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadta) - [$cantemoItemId] - Bulk Metadata {$bulkMetadataHttpResponse}" >> "$logfile"

        if [[ "$bulkMetadataHttpResponse" != *"</oly_rightslineEntityTitle>"* ]];
        then
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadta) - [$cantemoItemId] - oly_rightslineEntityTitle IS EMPTY" >> "$logfile"
        else
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadta) - [$cantemoItemId] - oly_rightslineEntityTitle IS NOT EMPTY" >> "$logfile"
        fi

        if [[ "$bulkMetadataHttpResponse" != *"</oly_titleCode>"* ]];
        then
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadta) - [$cantemoItemId] - oly_titleCode IS EMPTY" >> "$logfile"
        else
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadta) - [$cantemoItemId] - oly_titleCode IS NOT EMPTY" >> "$logfile"
        fi

        if [[ "$bulkMetadataHttpResponse" != *"</oly_rightslineContractId>"* ]];
        then
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadta) - [$cantemoItemId] - oly_rightslineContractId IS EMPTY" >> "$logfile"
        else
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadta) - [$cantemoItemId] - oly_rightslineContractId IS NOT EMPTY" >> "$logfile"
        fi

        if [[ "$bulkMetadataHttpResponse" != *"</oly_contentType>"* ]];
        then
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadta) - [$cantemoItemId] - oly_contentType IS EMPTY" >> "$logfile"
        else
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadta) - [$cantemoItemId] - oly_contentType IS NOT EMPTY" >> "$logfile"
        fi

        if [[ "$bulkMetadataHttpResponse" != *"</oly_cast>"* ]];
        then
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadta) - [$cantemoItemId] - oly_cast IS EMPTY" >> "$logfile"
        else
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadta) - [$cantemoItemId] - oly_cast IS NOT EMPTY" >> "$logfile"
        fi

        if [[ "$bulkMetadataHttpResponse" != *"</oly_director>"* ]];
        then
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadta) - [$cantemoItemId] - oly_director IS EMPTY" >> "$logfile"
        else
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadta) - [$cantemoItemId] - oly_director IS NOT EMPTY" >> "$logfile"
        fi

        if [[ "$bulkMetadataHttpResponse" != *"</oly_episodeNumber>"* ]];
        then
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadta) - [$cantemoItemId] - oly_episodeNumber IS EMPTY" >> "$logfile"
        else
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadta) - [$cantemoItemId] - oly_episodeNumber IS NOT EMPTY" >> "$logfile"
        fi

        if [[ "$bulkMetadataHttpResponse" != *"</oly_firstUseDate>"* ]];
        then
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadta) - [$cantemoItemId] - oly_firstUseDate IS EMPTY" >> "$logfile"
        else
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadta) - [$cantemoItemId] - oly_firstUseDate IS NOT EMPTY" >> "$logfile"
        fi

        if [[ "$bulkMetadataHttpResponse" != *"</oly_producer>"* ]];
        then
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadta) - [$cantemoItemId] - oly_producer IS EMPTY" >> "$logfile"
        else
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadta) - [$cantemoItemId] - oly_producer IS NOT EMPTY" >> "$logfile"
        fi

        if [[ "$bulkMetadataHttpResponse" != *"</oly_originalMpaaRating>"* ]];
        then
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadta) - [$cantemoItemId] - oly_originalMpaaRating IS EMPTY" >> "$logfile"
        else
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadta) - [$cantemoItemId] - oly_originalMpaaRating IS NOT EMPTY" >> "$logfile"
        fi

        if [[ "$bulkMetadataHttpResponse" != *"</oly_originalRtcRating>"* ]];
        then
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadta) - [$cantemoItemId] - oly_originalRtcRating IS EMPTY" >> "$logfile"
        else
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadta) - [$cantemoItemId] - oly_originalRtcRating IS NOT EMPTY" >> "$logfile"
        fi

        if [[ "$bulkMetadataHttpResponse" != *"</oly_originalRating>"* ]];
        then
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadta) - [$cantemoItemId] - oly_originalRating IS EMPTY" >> "$logfile"
        else
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadta) - [$cantemoItemId] - oly_originalRating IS NOT EMPTY" >> "$logfile"
        fi

        if [[ "$bulkMetadataHttpResponse" != *"</oly_readyForAirDate>"* ]];
        then
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadta) - [$cantemoItemId] - oly_readyForAirDate IS EMPTY" >> "$logfile"
        else
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadta) - [$cantemoItemId] - oly_readyForAirDate IS NOT EMPTY" >> "$logfile"
        fi

        if [[ "$bulkMetadataHttpResponse" != *"</oly_seasonNumber>"* ]];
        then
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadta) - [$cantemoItemId] - oly_seasonNumber IS EMPTY" >> "$logfile"
        else
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadta) - [$cantemoItemId] - oly_seasonNumber IS NOT EMPTY" >> "$logfile"
        fi

        if [[ "$bulkMetadataHttpResponse" != *"</oly_titleEn>"* ]];
        then
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadta) - [$cantemoItemId] - oly_titleEn IS EMPTY" >> "$logfile"
        else
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadta) - [$cantemoItemId] - oly_titleEn IS NOT EMPTY" >> "$logfile"
        fi

        if [[ "$bulkMetadataHttpResponse" != *"</oly_titleEs>"* ]];
        then
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadta) - [$cantemoItemId] - oly_titleEs IS EMPTY" >> "$logfile"
        else
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadta) - [$cantemoItemId] - oly_titleEs IS NOT EMPTY" >> "$logfile"
        fi

        if [[ "$bulkMetadataHttpResponse" != *"</oly_closedCaptionInfo>"* ]];
        then
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadta) - [$cantemoItemId] - oly_closedCaptionInfo IS EMPTY" >> "$logfile"
        else
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadta) - [$cantemoItemId] - oly_closedCaptionInfo IS NOT EMPTY" >> "$logfile"
        fi

        if [[ "$bulkMetadataHttpResponse" != *"</oly_countryOfOrigin>"* ]];
        then
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadta) - [$cantemoItemId] - oly_countryOfOrigin IS EMPTY" >> "$logfile"
        else
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadta) - [$cantemoItemId] - oly_countryOfOrigin IS NOT EMPTY" >> "$logfile"
        fi

        if [[ "$bulkMetadataHttpResponse" != *"</oly_primaryGenre>"* ]];
        then
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadta) - [$cantemoItemId] - oly_primaryGenre IS EMPTY" >> "$logfile"
        else
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadta) - [$cantemoItemId] - oly_primaryGenre IS NOT EMPTY" >> "$logfile"
        fi

        if [[ "$bulkMetadataHttpResponse" != *"</oly_secondaryGenres>"* ]];
        then
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadta) - [$cantemoItemId] - oly_secondaryGenres IS EMPTY" >> "$logfile"
        else
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadta) - [$cantemoItemId] - oly_secondaryGenres IS NOT EMPTY" >> "$logfile"
        fi

        if [[ "$bulkMetadataHttpResponse" != *"</oly_closedCaptionLanguage>"* ]];
        then
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadta) - [$cantemoItemId] - oly_closedCaptionLanguage IS EMPTY" >> "$logfile"
        else
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadta) - [$cantemoItemId] - oly_closedCaptionLanguage IS NOT EMPTY" >> "$logfile"
        fi

        if [[ "$bulkMetadataHttpResponse" != *"</oly_originalTitle>"* ]];
        then
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadta) - [$cantemoItemId] - oly_originalTitle IS EMPTY" >> "$logfile"
        else
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadta) - [$cantemoItemId] - oly_originalTitle IS NOT EMPTY" >> "$logfile"
        fi

        if [[ "$bulkMetadataHttpResponse" != *"</oly_productionCompany>"* ]];
        then
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadta) - [$cantemoItemId] - oly_productionCompany IS EMPTY" >> "$logfile"
        else
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadta) - [$cantemoItemId] - oly_productionCompany IS NOT EMPTY" >> "$logfile"
        fi

        if [[ "$bulkMetadataHttpResponse" != *"</oly_tags>"* ]];
        then
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadta) - [$cantemoItemId] - oly_tags IS EMPTY" >> "$logfile"
        else
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadta) - [$cantemoItemId] - oly_tags IS NOT EMPTY" >> "$logfile"
        fi

        if [[ "$bulkMetadataHttpResponse" != *"</oly_productionYear>"* ]];
        then
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadta) - [$cantemoItemId] - oly_productionYear IS EMPTY" >> "$logfile"
        else
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadta) - [$cantemoItemId] - oly_productionYear IS NOT EMPTY" >> "$logfile"
        fi

        if [[ "$bulkMetadataHttpResponse" != *"</oly_numberOfEpisodes>"* ]];
        then
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadta) - [$cantemoItemId] - oly_numberOfEpisodes IS EMPTY" >> "$logfile"
        else
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadta) - [$cantemoItemId] - oly_numberOfEpisodes IS NOT EMPTY" >> "$logfile"
        fi

        if [[ "$bulkMetadataHttpResponse" != *"</oly_numberOfEpisodes>"* ]];
        then
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadta) - [$cantemoItemId] - oly_firstUseDate IS EMPTY" >> "$logfile"
        else
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadta) - [$cantemoItemId] - oly_firstUseDate IS NOT EMPTY" >> "$logfile"
        fi

        if [[ "$bulkMetadataHttpResponse" != *"</oly_totalSeasonsBySeries>"* ]];
        then
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadta) - [$cantemoItemId] - oly_totalSeasonsBySeries IS EMPTY" >> "$logfile"
        else
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadta) - [$cantemoItemId] - oly_totalSeasonsBySeries IS NOT EMPTY" >> "$logfile"
        fi

        if [[ "$bulkMetadataHttpResponse" != *"</oly_totalEpisodesBySeries>"* ]];
        then
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadta) - [$cantemoItemId] - oly_totalEpisodesBySeries IS EMPTY" >> "$logfile"
        else
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadta) - [$cantemoItemId] - oly_totalEpisodesBySeries IS NOT EMPTY" >> "$logfile"
        fi

        if [[ "$bulkMetadataHttpResponse" != *"</oly_totalEpisodesBySeason>"* ]];
        then
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadta) - [$cantemoItemId] - oly_totalEpisodesBySeason IS EMPTY" >> "$logfile"
        else
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadta) - [$cantemoItemId] - oly_totalEpisodesBySeason IS NOT EMPTY" >> "$logfile"
        fi

        if [[ "$bulkMetadataHttpResponse" != *"</oly_editorNotes>"* ]];
        then
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadta) - [$cantemoItemId] - oly_editorNotes IS EMPTY" >> "$logfile"
        else
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadta) - [$cantemoItemId] - oly_editorNotes IS NOT EMPTY" >> "$logfile"
        fi

        if [[ "$bulkMetadataHttpResponse" != *"</oly_format>"* ]];
        then
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadta) - [$cantemoItemId] - oly_format IS EMPTY" >> "$logfile"
        else
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadta) - [$cantemoItemId] - oly_format IS NOT EMPTY" >> "$logfile"
        fi

        if [[ "$bulkMetadataHttpResponse" != *"</oly_timecode>"* ]];
        then
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadta) - [$cantemoItemId] - oly_timecode IS EMPTY" >> "$logfile"
        else
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadta) - [$cantemoItemId] - oly_timecode IS NOT EMPTY" >> "$logfile"
        fi

        sleep 1

        urlGetItemSpaSynopMetadata="http://10.1.1.34:8080/API/item/$cantemoItemId/metadata?field=oly_descriptionEs%2Coly_shortDescriptionEs%2Coly_socialDescriptionEs%2Coly_logLineEs&group=Spanish%20Synopsis&terse=yes"
        spaSynopMetadataHttpResponse=$(curl --location --request GET $urlGetItemSpaSynopMetadata --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=Tkb9vkSC8v4SceB8CHUyB3iaMPjvgoHrzhLrvo36agG3wqv0jHc7nsOtdTo9JEyM')

        echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadta) - [$cantemoItemId] - Spanish Synopsis Metadata {$spaSynopMetadataHttpResponse}" >> "$logfile"

        if [[ "$spaSynopMetadataHttpResponse" != *"</oly_descriptionEs>"* ]];
        then
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadta) - [$cantemoItemId] - oly_descriptionEs IS EMPTY" >> "$logfile"
        else
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadta) - [$cantemoItemId] - oly_descriptionEs IS NOT EMPTY" >> "$logfile"
        fi

        if [[ "$spaSynopMetadataHttpResponse" != *"</oly_shortDescriptionEs>"* ]];
        then
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadta) - [$cantemoItemId] - oly_shortDescriptionEs IS EMPTY" >> "$logfile"
        else
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadta) - [$cantemoItemId] - oly_shortDescriptionEs IS NOT EMPTY" >> "$logfile"
        fi

        if [[ "$spaSynopMetadataHttpResponse" != *"</oly_socialDescriptionEs>"* ]];
        then
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadta) - [$cantemoItemId] - oly_socialDescriptionEs IS EMPTY" >> "$logfile"
        else
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadta) - [$cantemoItemId] - oly_socialDescriptionEs IS NOT EMPTY" >> "$logfile"
        fi

        if [[ "$spaSynopMetadataHttpResponse" != *"</oly_logLineEs>"* ]];
        then
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadta) - [$cantemoItemId] - oly_logLineEs IS EMPTY" >> "$logfile"
        else
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadta) - [$cantemoItemId] - oly_logLineEs IS NOT EMPTY" >> "$logfile"
        fi

        sleep 1

        urlGetItemEngSynopMetadata="http://10.1.1.34:8080/API/item/$cantemoItemId/metadata?field=oly_descriptionEn%2Coly_shortDescriptionEn%2Coly_socialDescriptionEn%2Coly_logLineEn&group=English%20Synopsis&terse=yes"
        engSynopMetadataHttpResponse=$(curl --location --request GET $urlGetItemEngSynopMetadata --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=Tkb9vkSC8v4SceB8CHUyB3iaMPjvgoHrzhLrvo36agG3wqv0jHc7nsOtdTo9JEyM')

        echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadta) - [$cantemoItemId] - English Synopsis Metadata {$engSynopMetadataHttpResponse}" >> "$logfile"

        if [[ "$engSynopMetadataHttpResponse" != *"</oly_descriptionEn>"* ]];
        then
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadta) - [$cantemoItemId] - oly_descriptionEn IS EMPTY" >> "$logfile"
        else
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadta) - [$cantemoItemId] - oly_descriptionEn IS NOT EMPTY" >> "$logfile"
        fi

        if [[ "$engSynopMetadataHttpResponse" != *"</oly_shortDescriptionEn>"* ]];
        then
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadta) - [$cantemoItemId] - oly_shortDescriptionEn IS EMPTY" >> "$logfile"
        else
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadta) - [$cantemoItemId] - oly_shortDescriptionEn IS NOT EMPTY" >> "$logfile"
        fi

        if [[ "$engSynopMetadataHttpResponse" != *"</oly_socialDescriptionEn>"* ]];
        then
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadta) - [$cantemoItemId] - oly_socialDescriptionEn IS EMPTY" >> "$logfile"
        else
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadta) - [$cantemoItemId] - oly_socialDescriptionEn IS NOT EMPTY" >> "$logfile"
        fi

        if [[ "$engSynopMetadataHttpResponse" != *"</oly_logLineEn>"* ]];
        then
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadta) - [$cantemoItemId] - oly_logLineEn IS EMPTY" >> "$logfile"
        else
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadta) - [$cantemoItemId] - oly_logLineEn IS NOT EMPTY" >> "$logfile"
        fi

        sleep 1

        urlGetItemExtResourcesMetadata="http://10.1.1.34:8080/API/item/$cantemoItemId/metadata?field=oly_trailerLink%2Coly_clipLink%2Coly_promoLink%2Coly_screenerLink&group=External%20Resources&terse=yes"
        extResourcesMetadataHttpResponse=$(curl --location --request GET $urlGetItemExtResourcesMetadata --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=Tkb9vkSC8v4SceB8CHUyB3iaMPjvgoHrzhLrvo36agG3wqv0jHc7nsOtdTo9JEyM')

        echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadta) - [$cantemoItemId] - English Synopsis Metadata {$engSynopMetadataHttpResponse}" >> "$logfile"

        if [[ "$extResourcesMetadataHttpResponse" != *"</oly_trailerLink>"* ]];
        then
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadta) - [$cantemoItemId] - oly_trailerLink IS EMPTY" >> "$logfile"
        else
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadta) - [$cantemoItemId] - oly_trailerLink IS NOT EMPTY" >> "$logfile"
        fi

        if [[ "$extResourcesMetadataHttpResponse" != *"</oly_clipLink>"* ]];
        then
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadta) - [$cantemoItemId] - oly_clipLink IS EMPTY" >> "$logfile"
        else
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadta) - [$cantemoItemId] - oly_clipLink IS NOT EMPTY" >> "$logfile"
        fi

        if [[ "$extResourcesMetadataHttpResponse" != *"</oly_promoLink>"* ]];
        then
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadta) - [$cantemoItemId] - oly_promoLink IS EMPTY" >> "$logfile"
        else
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadta) - [$cantemoItemId] - oly_promoLink IS NOT EMPTY" >> "$logfile"
        fi

        if [[ "$extResourcesMetadataHttpResponse" != *"</oly_screenerLink>"* ]];
        then
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadta) - [$cantemoItemId] - oly_screenerLink IS EMPTY" >> "$logfile"
        else
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadta) - [$cantemoItemId] - oly_screenerLink IS NOT EMPTY" >> "$logfile"
        fi

        sleep 1

        # --------------------------------------------------

        # --------------------------------------------------
        # Choose what information from the CSV export file needed to be printed
        columnCounter=1
        while [ $columnCounter -le $columnCounts ];
        do
            case "${fieldName[$columnCounter]}" in

                "Genres")
                    if [[ ! -z "${fieldValue[$columnCounter]}" ]];
                    then
                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadta) - [$cantemoItemId] - [${fieldValue[$columnCounter]}] Column NOT empty" >> "$logfile"
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
                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadta) - [$cantemoItemId] - [${fieldValue[$columnCounter]}] Column is EMPTY" >> "$logfile"
                        columnCounter=$(($columnCounter + 1))
                    fi
                ;;

                "oly_descriptionEs"|"oly_shortDescriptionEs"|"oly_socialDescriptionEs"|"oly_logLineEs")
                    if [[ ! -z "${fieldValue[$columnCounter]}" ]];
                    then
                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadta) - [$cantemoItemId] - [${fieldValue[$columnCounter]}] Column NOT empty" >> "$logfile"
                        echo "        <field>
          <name>${fieldName[$columnCounter]}</name>
          <value>${fieldValue[$columnCounter]}</value>
        </field>" >> "$fileDestinationSpanish"
                        columnCounter=$(($columnCounter + 1))
                    else
                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadta) - [$cantemoItemId] - [${fieldValue[$columnCounter]}] Column is EMPTY" >> "$logfile"
                        columnCounter=$(($columnCounter + 1))
                    fi
                ;;

                "oly_descriptionEn"|"oly_shortDescriptionEn"|"oly_socialDescriptionEn"|"oly_logLineEn")
                    if [[ ! -z "${fieldValue[$columnCounter]}" ]];
                    then
                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadta) - [$cantemoItemId] - [${fieldValue[$columnCounter]}] Column NOT empty" >> "$logfile"
                        echo "        <field>
          <name>${fieldName[$columnCounter]}</name>
          <value>${fieldValue[$columnCounter]}</value>
        </field>" >> "$fileDestinationEnglish"
                        columnCounter=$(($columnCounter + 1))
                    else
                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadta) - [$cantemoItemId] - [${fieldValue[$columnCounter]}] Column is EMPTY" >> "$logfile"
                        columnCounter=$(($columnCounter + 1))
                    fi
                ;;

                "oly_cast"|"oly_director"|"oly_producer"|"oly_tags"|"oly_productionCompany")
                    if [[ ! -z "${fieldValue[$columnCounter]}" ]];
                    then
                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadta) - [$cantemoItemId] - [${fieldValue[$columnCounter]}] Column NOT empty" >> "$logfile"
                        createTags "${fieldValue[$columnCounter]}" "${fieldName[$columnCounter]}" "$fileDestination"
                        columnCounter=$(($columnCounter + 1))
                    else
                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadta) - [$cantemoItemId] - [${fieldValue[$columnCounter]}] Column is EMPTY" >> "$logfile"
                        columnCounter=$(($columnCounter + 1))
                    fi
                ;;

                "oly_contentType"|"oly_originalMpaaRating"|"oly_originalRtcRating"|"oly_originalRating"|"oly_countryOfOrigin"|"oly_closedCaptionLanguage"|"oly_originalLanguage")
                    if [[ ! -z "${fieldValue[$columnCounter]}" ]];
                    then
                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadta) - [$cantemoItemId] - [${fieldValue[$columnCounter]}] Column NOT empty" >> "$logfile"
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
                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadta) - [$cantemoItemId] - [${fieldValue[$columnCounter]}] Column is EMPTY" >> "$logfile"
                        columnCounter=$(($columnCounter + 1))
                    fi
                ;;

                "oly_closedCaptionInfo-closedcaptionavailable")
                    columnCounter=$(($columnCounter + 1))
                ;;

                "oly_closedCaptionInfo-broadcastedontvwithcc")
                    columnCounter=$(($columnCounter + 1))
                ;;

                "oly_clipLink"|"oly_promoLink"|"oly_trailerLink")
                    if [[ ! -z "${fieldValue[$columnCounter]}" ]];
                    then
                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadta) - [$cantemoItemId] - [${fieldValue[$columnCounter]}] Column NOT empty" >> "$logfile"
                        echo "        <field>
          <name>${fieldName[$columnCounter]}</name>
          <value>${fieldValue[$columnCounter]}</value>
        </field>" >> "$fileDestinationExternal"
                        columnCounter=$(($columnCounter + 1))
                    else
                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadta) - [$cantemoItemId] - [${fieldValue[$columnCounter]}] Column is EMPTY" >> "$logfile"
                        columnCounter=$(($columnCounter + 1))
                    fi
                ;;

                "oly_rightslineContractId")
                    if [[ ! -z "${fieldValue[$columnCounter]}" ]];
                    then
                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadta) - [$cantemoItemId] - [${fieldValue[$columnCounter]}] Column NOT empty" >> "$logfile"
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
                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadta) - [$cantemoItemId] - [${fieldValue[$columnCounter]}] Column is EMPTY" >> "$logfile"
                        columnCounter=$(($columnCounter + 1))
                    fi
                ;;

                "oly_rightslineItemId")
                    columnCounter=$(($columnCounter + 1))
                ;;

                *)
                    if [[ ! -z "${fieldValue[$columnCounter]}" ]];
                    then
                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadta) - [$cantemoItemId] - [${fieldValue[$columnCounter]}] Column NOT empty" >> "$logfile"
                        echo "      <field>
         <name>${fieldName[$columnCounter]}</name>
         <value>${fieldValue[$columnCounter]}</value>
      </field>" >> "$fileDestination"
                        columnCounter=$(($columnCounter + 1))
                    else
                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadta) - [$cantemoItemId] - [${fieldValue[$columnCounter]}] Column is EMPTY" >> "$logfile"
                        columnCounter=$(($columnCounter + 1))
                    fi
                ;;

            esac
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

        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadta) - [$cantemoItemId] - XML has been created {$cantemoItemId.xml}" >> "$logfile"
        # --------------------------------------------------

        sleep 5

        # ----------------------------------------------------
        # API Call to Update Metadata

        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadta) - [$cantemoItemId] - Triggering API Call to Import XML into Cantemo" >> "$logfile"

        url="http://10.1.1.34:8080/API/import/sidecar/$cantemoItemId?sidecar=/opt/olympusat/xmlsForMetadataImport/$cantemoItemId.xml"

        curl --location --request POST $url --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0'

        #sleep 2

        #updateVidispineMetadata $cantemoItemId "oly_rightslineInfo" "metadataimported"

        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadta) - [$cantemoItemId] - Moving XML to zCompleted Folder" >> "$logfile"

        sleep 2

        echo "Moving xml to zCompleted folder"
        mv "$fileDestination" "/opt/olympusat/xmlsForMetadataImport/zCompleted/"

        echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadta) - [$cantemoItemId] - Triggering Shell Script to Import Contract Information" >> "$logfile"
        #bash -c "sudo /opt/olympusat/scriptsNonActive/importRightslineLegacyInfo-contract_v3.0.sh $cantemoItemId $userName oly_rightslineItemId /opt/olympusat/resources/RIGHTSLINE_CONTRACT_CODE_INFO_DATABASE_2024-05-07.csv > /dev/null 2>&1 &"

    else
        echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadta) - [$cantemoItemId] - Import Metadata Job Skipped - No Matching Rightsline Item Id Found in CSV" >> "$logfile"
    fi
else
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (importLegacyMetadta) - [$cantemoItemId] - Import Metadata Job Skipped - Already Imported" >> "$logfile"
fi

IFS=$saveIFS

exit 0