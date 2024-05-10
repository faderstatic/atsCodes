#!/bin/bash

#::***************************************************************************************************************************
#::This shell script will get the title of an item and deconstuct it for metadata fields
#::Engineers: Ryan Sims & Tang Kanjanapitak
#::Client: Olympusat
#::Updated: 04/02/2024
#::Rev A: 
#::***************************************************************************************************************************

#--------------------------------------------------
# External funtions to include
. /opt/olympusat/scriptsLibrary/olympusatCantemo.lib
#--------------------------------------------------

saveIFS=$IFS
IFS=$(echo -e "\n\b")

export mydate=$(date +%Y-%m-%d)
export datetime=$(date +%Y/%m/%d_%H:%M)

#Variables to be set by Metadata fields or information from Cantemo to be used in email body
export itemId=$1
export title=$(filterVidispineItemMetadata $itemId "metadata" "title")
export url="http://10.1.1.34:8080/API/item/$itemId/metadata/"

logfile="/opt/olympusat/logs/titleDeconstruct-$mydate.log"

echo "$datetime - ($itemId) - Deconstructing Title - $title" >> "$logfile"

numberOfUnderscores=$(echo $title | awk -F"_" '{print NF-1}')

echo $numberOfUnderscores
echo "$datetime - ($itemId) - Number of Underscores - $numberOfUnderscores" >> "$logfile"

if [[ $numberOfUnderscores == 4 ]];
    then
        namingConventionCheck=$(echo $title | awk -F "_" '{print $2}')
        if [[ ("$namingConventionCheck" == "EN") || ("$namingConventionCheck" == "ES") || ("$namingConventionCheck" == "FR") || ("$namingConventionCheck" == "OG") ]];
        then
            titleByLanguage=$(echo $title | awk -F "_" '{print $1}')
            titleByLanguage=$(echo $titleByLanguage | sed -r -e "s/([^A-Z])([A-Z])/\1 \2/g" -e "s/([A-Z]+)([A-Z])/\1 \2/g")
            language=$(echo $title | awk -F "_" '{print $2}')
            titleCode=$(echo $title | awk -F "_" '{print $3}')
            imageType=$(echo $title | awk -F "_" '{print $4}')
            imageSize=$(echo $title | awk -F "_" '{print $5}')

            seasonNumberCheck=$(echo $imageType | awk 'BEGIN { FPAT = "[0-9]+" } {print $1}')
            episodeNumberCheck=$(echo $imageType | awk 'BEGIN { FPAT = "[0-9]+" } {print $2}')

            echo "$datetime - ($itemId) - titleCode - $titleCode" >> "$logfile"
            echo "$datetime - ($itemId) - imageType - $imageType" >> "$logfile"
            echo "$datetime - ($itemId) - titleByLanguage - $titleByLanguage" >> "$logfile"
            echo "$datetime - ($itemId) - language - $language" >> "$logfile"
            echo "$datetime - ($itemId) - imageSize - $imageSize" >> "$logfile"
            echo "$datetime - ($itemId) - seasonNumber - $seasonNumberCheck" >> "$logfile"
            echo "$datetime - ($itemId) - episodeNumber - $episodeNumberCheck" >> "$logfile"
        else
            titleCode=$(echo $title | awk -F "_" '{print $1}')
            imageType=$(echo $title | awk -F "_" '{print $2}')
            titleByLanguage=$(echo $title | awk -F "_" '{print $3}')
            titleByLanguage=$(echo $titleByLanguage | sed -r -e "s/([^A-Z])([A-Z])/\1 \2/g" -e "s/([A-Z]+)([A-Z])/\1 \2/g")
            language=$(echo $title | awk -F "_" '{print $4}')
            imageSize=$(echo $title | awk -F "_" '{print $5}')

            echo "$datetime - ($itemId) - titleCode - $titleCode" >> "$logfile"
            echo "$datetime - ($itemId) - imageType - $imageType" >> "$logfile"
            echo "$datetime - ($itemId) - titleByLanguage - $titleByLanguage" >> "$logfile"
            echo "$datetime - ($itemId) - language - $language" >> "$logfile"
            echo "$datetime - ($itemId) - imageSize - $imageSize" >> "$logfile"
        fi
    else
        if [[ $numberOfUnderscores == 3 ]];
            then
                titleCode=$(echo $title | awk -F "_" '{print $1}')
                imageType=$(echo $title | awk -F "_" '{print $2}')
                titleByLanguage=$(echo $title | awk -F "_" '{print $3}')
                titleByLanguage=$(echo $titleByLanguage | sed -r -e "s/([^A-Z])([A-Z])/\1 \2/g" -e "s/([A-Z]+)([A-Z])/\1 \2/g")
                imageSize=$(echo $title | awk -F "_" '{print $4}')

                echo "$datetime - ($itemId) - titleCode - $titleCode" >> "$logfile"
                echo "$datetime - ($itemId) - imageType - $imageType" >> "$logfile"
                echo "$datetime - ($itemId) - titleByLanguage - $titleByLanguage" >> "$logfile"
                echo "$datetime - ($itemId) - imageSize - $imageSize" >> "$logfile"
            else
                if [[ $numberOfUnderscores == 2 ]];
                    then
                        titleCode=$(echo $title | awk -F "_" '{print $1}')
                        imageType=$(echo $title | awk -F "_" '{print $2}')
                        titleByLanguage=$(echo $title | awk -F "_" '{print $3}')
                        titleByLanguage=$(echo $titleByLanguage | sed -r -e "s/([^A-Z])([A-Z])/\1 \2/g" -e "s/([A-Z]+)([A-Z])/\1 \2/g")

                        echo "$datetime - ($itemId) - titleCode - $titleCode" >> "$logfile"
                        echo "$datetime - ($itemId) - imageType - $imageType" >> "$logfile"
                        echo "$datetime - ($itemId) - titleByLanguage - $titleByLanguage" >> "$logfile"
                    else
                        if [[ $numberOfUnderscores == 5 ]];
                            then
                                titleCode=$(echo $title | awk -F "_" '{print $1}')
                                imageType=$(echo $title | awk -F "_" '{print $2}')
                                titleByLanguage=$(echo $title | awk -F "_" '{print $3}')
                                titleByLanguage=$(echo $titleByLanguage | sed -r -e "s/([^A-Z])([A-Z])/\1 \2/g" -e "s/([A-Z]+)([A-Z])/\1 \2/g")
                                seasonNumber=$(echo $title | awk -F "_" '{print $4}')
                                episodeNumber=$(echo $title | awk -F "_" '{print $5}')
                                imageSize=$(echo $title | awk -F "_" '{print $6}')

                                echo "$datetime - ($itemId) - titleCode - $titleCode" >> "$logfile"
                                echo "$datetime - ($itemId) - imageType - $imageType" >> "$logfile"
                                echo "$datetime - ($itemId) - titleByLanguage - $titleByLanguage" >> "$logfile"
                                echo "$datetime - ($itemId) - seasonNumber - $seasonNumber" >> "$logfile"
                                echo "$datetime - ($itemId) - episodeNumber - $episodeNumber" >> "$logfile"
                                echo "$datetime - ($itemId) - imageSize - $imageSize" >> "$logfile"

                                if [[ $seasonNumber == "S"* ]];
                                    then
                                        seasonNumberCleaned=${seasonNumber:1}
                                        echo "$datetime - ($itemId) - Season Number Cleaned - $seasonNumberCleaned" >> "$logfile"
                                    else
                                        echo "$datetime - ($itemId) - Does NOT Have Supported Format for Season Number - $seasonNumber" >> "$logfile"
                                fi

                                if [[ $episodeNumber == "E"* ]];
                                    then
                                        episodeNumberCleaned=${episodeNumber:2}
                                        echo "$datetime - ($itemId) - Episode Number Cleaned - $episodeNumberCleaned" >> "$logfile"
                                    else
                                        echo "$datetime - ($itemId) - Does NOT Have Supported Format for Episode Number - $episodeNumber" >> "$logfile"
                                fi
                            else
                                echo "$datetime - ($itemId) - Does NOT Have Supported Number of Underscores - $numberOfUnderscores" >> "$logfile"
                        fi
                fi
        fi
fi

if [[ $titleCode == "M"* ]];
    then
        if [[ $language == "es" || $language == "ES" ]];
            then
                fieldName="oly_titleEs"
            else
                fieldName="oly_titleEn"
        fi
    else
        fieldName="oly_seriesName"
fi

if [[ $numberOfUnderscores == 4 ]];
    then
        if [[ $language == "es" || $language == "en" || $language == "ES" || $language == "EN" || $language == "FR" ]];
        then
            if [[ $titleCode == "S"* ]];
            then 
                graphicsTags="<field><name>oly_graphicsTags</name><value>$titleCode</value><value>$imageType</value><value>$titleByLanguage</value><value>$language</value><value>$imageSize</value></field><field><name>oly_seasonNumber</name><value>$seasonNumberCheck</value></field><field><name>oly_episodeNumber</name><value>$episodeNumberCheck</value></field>"
            else
                graphicsTags="<field><name>oly_graphicsTags</name><value>$titleCode</value><value>$imageType</value><value>$titleByLanguage</value><value>$language</value><value>$imageSize</value></field>"
            fi
        else
            graphicsTags="<field><name>oly_graphicsTags</name><value>$titleCode</value><value>$imageType</value><value>$titleByLanguage</value><value>$imageSize</value></field>"
        fi
    else
        if [[ $numberOfUnderscores == 3 ]];
            then
                graphicsTags="<field><name>oly_graphicsTags</name><value>$titleCode</value><value>$imageType</value><value>$titleByLanguage</value><value>$imageSize</value></field>"
            else
                if [[ $numberOfUnderscores == 2 ]];
                    then
                        graphicsTags="<field><name>oly_graphicsTags</name><value>$titleCode</value><value>$imageType</value><value>$titleByLanguage</value></field>"
                    else
                        if [[ $numberOfUnderscores == 5 ]];
                            then
                                if [[ $language == "es" || $language == "en" || $language == "ES" || $language == "EN" || $language == "FR" ]];
                                then
                                    if [[ $titleCode == "S"* ]];
                                    then 
                                        graphicsTags="<field><name>oly_graphicsTags</name><value>$titleCode</value><value>$imageType</value><value>$titleByLanguage</value><value>$language</value><value>$imageSize</value></field><field><name>oly_seasonNumber</name><value>$seasonNumberCheck</value></field><field><name>oly_episodeNumber</name><value>$episodeNumberCheck</value></field>"
                                    else
                                        graphicsTags="<field><name>oly_graphicsTags</name><value>$titleCode</value><value>$imageType</value><value>$titleByLanguage</value><value>$language</value><value>$imageSize</value></field>"
                                    fi
                                else
                                    graphicsTags="<field><name>oly_graphicsTags</name><value>$titleCode</value><value>$imageType</value><value>$titleByLanguage</value><value>$seasonNumber</value><value>$episodeNumber</value><value>$imageSize</value></field><field><name>oly_seasonNumber</name><value>$seasonNumberCleaned</value></field><field><name>oly_episodeNumber</name><value>$episodeNumberCleaned</value></field>"
                                    #graphicsTags="<field><name>oly_graphicsTags</name><value>$titleCode</value><value>$imageType</value><value>$titleByLanguage</value><value>$imageSize</value></field>"
                                fi
                            else
                                if [[ $numberOfUnderscores -lt 1 || $numberOfUnderscores -gt 6 ]];
                                    then
                                        echo "$datetime - ($itemId) - Does NOT Have Supported Number of Underscores - $numberOfUnderscores" >> "$logfile"
                                    else
                                        echo "$datetime - ($itemId) - End of the IF Statements - Last Else" >> "$logfile"
                                fi
                        fi
                fi
        fi
fi

case $language in
    "es")
        primaryMetadataLanguage="spanish"
    ;;
    "en")
        primaryMetadataLanguage="english"
    ;;
    "ES")
        primaryMetadataLanguage="spanish"
    ;;
    "EN")
        primaryMetadataLanguage="english"
    ;;
    "FR")
        primaryMetadataLanguage="french"
    ;;
    "OG")
        primaryMetadataLanguage=""
    ;;
esac

echo "$datetime - ($itemId) - Primary Metadata Language - $primaryMetadataLanguage" >> "$logfile"
echo "$datetime - ($itemId) - Graphics Tags - $graphicsTags" >> "$logfile"

bodyData=$(echo "<MetadataDocument xmlns=\"http://xml.vidispine.com/schema/vidispine\"><timespan start=\"-INF\" end=\"+INF\">$graphicsTags<field><name>oly_titleCode</name><value>$titleCode</value></field><field><name>oly_primaryMetadataLanguage</name><value>$primaryMetadataLanguage</value></field><field><name>$fieldName</name><value>$titleByLanguage</value></field></timespan></MetadataDocument>")

echo "$datetime - ($itemId) - Body Data - $bodyData" >> "$logfile"

curl -s -o /dev/null --location --request PUT $url --header 'Content-Type: application/xml' --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=xZqBrKBPBOUANsWFnMC3aF90S52Ip3tgXdUHwWZvhNnu9aLl9j4rdrxRhV9nSQx9' --data $bodyData

sleep 5

echo "$datetime - ($itemId) - Metadata Update Completed" >> "$logfile"

IFS=$saveIFS