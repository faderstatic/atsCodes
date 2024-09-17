#!/bin/bash

# This script gathers Metadata from Rightsline (for legacy contents) and apply them to Cantemo
# PREREQUISITE: This script must receive Cantemo item ID as an argument, column header and file location of Rightsline CSV export.
# It requests oly_rightslineItemId from Vidispine and updates metadata fields
#   Usage: importRightslineLegacyInfo-media_vX.X.sh [Cantemo item ID] [column header which contains Rightsline ID]
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
export inputFolder="$4"
export rightslineItemId="$1"
export cantemoItemTitle=$(filterVidispineItemMetadata "$cantemoItemId" "metadata" "title")

export mydate=$(date +%Y-%m-%d)
logfile="/opt/olympusat/logs/initialIngestMetadataWorkflow-$mydate.log"

# --------------------------------------------------

echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestRightslineItemId) - [$cantemoItemId] - Import Rightsline Item Id Job Initiated by {$userName}" >> "$logfile"

# --------------------------------------------------
# Check for csv with filename that starts with 'rightslineItemId_import_' & contains username

export inputFile="$inputFolder/rightslineItemId_import_$userName.csv"
echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestRightslineItemId) - [$cantemoItemId] - Input File - {$inputFile}" >> "$logfile"

if [[ -e "$inputFile" ]];
then
    # Input File for user exists - continuing with script
    
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestRightslineItemId) - [$cantemoItemId] - CSV with {$userName} in the filename exists - continuing with script" >> "$logfile"
    # --------------------------------------------------

    # --------------------------------------------------
    # Check to see if import has already ran on item
    export rightslineItemIdCheck=$(filterVidispineItemMetadata "$cantemoItemId" "metadata" "oly_rightslineItemId")

    if [[ -z "$rightslineItemIdCheck" ]];
    then
        # --------------------------------------------------
        # Check to make sure item is 'original raw master', 'series', or 'season'
        urlGetOriginalFileFlags="http://10.1.1.34:8080/API/item/$cantemoItemId/metadata?field=oly_originalFileFlags&terse=yes"
        originalFileFlagsHttpResponse=$(curl --location --request GET $urlGetOriginalFileFlags --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=Tkb9vkSC8v4SceB8CHUyB3iaMPjvgoHrzhLrvo36agG3wqv0jHc7nsOtdTo9JEyM')
        export contentTypeCheck=$(filterVidispineItemMetadata "$cantemoItemId" "metadata" "oly_contentType")
        if [[ "$originalFileFlagsHttpResponse" == *"originalrawmaster"* || "$contentTypeCheck" == "series" || "$contentTypeCheck" == "season" ]];
        then
            # Item is 'original raw master', 'series', or 'season' - continue with process
        
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
                fileDestination="/opt/olympusat/xmlsForMetadataImport/rightslineItemId_$cantemoItemId.xml"

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

                        "getThisValue")
                            echo "        <field>
          <name>oly_rightslineItemId</name>
          <value>${fieldValue[$columnCounter]}</value>
        </field>" >> "$fileDestination"
                            columnCounter=$(($columnCounter + 1))
                        ;;

                        *)
                            columnCounter=$(($columnCounter + 1))
                        ;;

                    esac
                done

                # --------------------------------------------------

                # --------------------------------------------------
                # Print XML footer
                echo "    </timespan>
</MetadataDocument>" >> "$fileDestination"

                echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestRightslineItemId) - [$cantemoItemId] - XML has been created {rightslineItemId_$cantemoItemId.xml}" >> "$logfile"
                # --------------------------------------------------

                sleep 5

                # ----------------------------------------------------
                # API Call to Update Metadata

                echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestRightslineItemId) - [$cantemoItemId] - Triggering API Call to Import XML into Cantemo" >> "$logfile"

                url="http://10.1.1.34:8080/API/import/sidecar/$cantemoItemId?sidecar=/opt/olympusat/xmlsForMetadataImport/rightslineItemId_$cantemoItemId.xml"

                curl --location --request POST $url --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0'

                sleep 2

                echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestRightslineItemId) - [$cantemoItemId] - Moving XML to zCompleted Folder" >> "$logfile"
                
                sleep 2

                mv "$fileDestination" "/opt/olympusat/xmlsForMetadataImport/zCompleted/"

                echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestRightslineItemId) - [$cantemoItemId] - Triggering importRightslineLegacyInfo-media script with [$cantemoItemId]" >> "$logfile"

                sleep 5

                bash -c "sudo /opt/olympusat/scriptsActive/importRightslineLegacyInfo-media_v4.0.sh $cantemoItemId $userName oly_rightslineItemId /opt/olympusat/resources/rightslineData/RIGHTSLINE_CATALOG-ITEM_DATABASE_2024-07-31_combined.csv > /dev/null 2>&1 &"

                echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestRightslineItemId) - [$cantemoItemId] - Import Rightsline Item Id Job Completed" >> "$logfile"

            fi
        else
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestRightslineItemId) - [$cantemoItemId] - Item is not flagged as 'Original Raw Master', 'Series', or 'Season' - SKIPPING import/update" >> "$logfile"        
        fi
    else
        echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestRightslineItemId) - [$cantemoItemId] - Item already has oly_rightslineItemId set in Cantemo - SKIPPING import/update" >> "$logfile"    
    fi
else
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestRightslineItemId) - [$cantemoItemId] - CSV with {$userName} in the filename does NOT exist - SKIPPING import/update" >> "$logfile"
fi

IFS=$saveIFS

exit 0