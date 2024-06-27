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

echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - Deconstructing Title - $title" >> "$logfile"

if [[ "$title" == *_RAW ]];
then
    echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - Title ends with _RAW - {$title} - Removing _RAW" >> "$logfile"
    title=$(echo $title | sed 's/.\{4\}$//')
    echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - New Title - {$title}" >> "$logfile"
fi

numberOfUnderscores=$(echo $title | awk -F"_" '{print NF-1}')

echo $numberOfUnderscores
echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - Number of Underscores - $numberOfUnderscores" >> "$logfile"

if [[ $numberOfUnderscores == 4 ]];
    then
        blockOne=$(echo $title | awk -F "_" '{print $1}')
        blockTwo=$(echo $title | awk -F "_" '{print $2}')
        blockThree=$(echo $title | awk -F "_" '{print $3}')
        blockFour=$(echo $title | awk -F "_" '{print $4}')
        blockFive=$(echo $title | awk -F "_" '{print $5}')

        blockOneCharCount=$(echo -n $blockOne | wc -c)
        blockTwoCharCount=$(echo -n $blockTwo | wc -c)
        blockThreeCharCount=$(echo -n $blockThree | wc -c)
        blockFourCharCount=$(echo -n $blockFour | wc -c)
        blockFiveCharCount=$(echo -n $blockFive | wc -c)

        echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - Check Block One for Info - {$blockOne} - {$blockOneCharCount}" >> "$logfile"
        if [[ "$blockOne" =~ ^(M|S).*[0-9]$ ]];
        then
            case $blockOneCharCount in
                "7")
                    titleCode=$(echo $blockOne)
                ;;
                "9")
                    titleCode=$(echo $blockOne)
                ;;
                "10")
                    titleCode=$(echo $blockOne)
                ;;
                "11")
                    titleCode=$(echo $blockOne)
                ;;
                "12")
                    titleCode=$(echo $blockOne)
                ;;
                "13")
                    titleCode=$(echo $blockOne)
                ;;
                *)
                    titleByLanguage=$(echo $blockOne)
                ;;
            esac
        else
            titleByLanguage=$(echo $blockOne)
        fi

        echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - Title Code - {$titleCode}" >> "$logfile"
        echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - Title By Language - {$titleByLanguage}" >> "$logfile"

        echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - Check Block Two for Info - {$blockTwo} - {$blockTwoCharCount}" >> "$logfile"
        if [[ ("$blockTwo" == "EN") || ("$blockTwo" == "ES") || ("$blockTwo" == "FR") || ("$blockTwo" == "OG") ]];
        then
            language=$(echo $blockTwo)
        else
            blockTwo=$(echo $blockTwo | tr '[:upper:]' '[:lower:]')
            if [[ ("$blockTwo" == "cover") || ("$blockTwo" == "feature") || ("$blockTwo" == "keyart") || ("$blockTwo" == "still") || ("$blockTwo" == "blank") ]];
            then
                imageType=$(echo $blockTwo)
            fi
        fi

        echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - Language - {$language}" >> "$logfile"
        echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - Image Type - {$imageType}" >> "$logfile"

        if [[ "$blockThree" =~ ^(M|S).*[0-9]$ ]];
        then
            case $blockThreeCharCount in
                "7")
                    titleCode=$(echo $blockThree)
                ;;
                "9")
                    titleCode=$(echo $blockThree)
                ;;
                "10")
                    titleCode=$(echo $blockThree)
                ;;
                "11")
                    titleCode=$(echo $blockThree)
                ;;
                "12")
                    titleCode=$(echo $blockThree)
                ;;
                "13")
                    titleCode=$(echo $blockThree)
                ;;
                *)
                    imageMisc=$(echo $blockThree)
                ;;
            esac
        else
            if [[ "$blockThree" =~ ^[0-9][0-9][0-9][0-9]x[0-9][0-9][0-9][0-9] || "$blockThree" =~ ^[0-9][0-9][0-9][0-9]x[0-9][0-9][0-9] || "$blockThree" =~ ^[0-9][0-9][0-9]x[0-9][0-9][0-9][0-9] || "$blockThree" =~ ^[0-9][0-9][0-9]x[0-9][0-9][0-9] ]];
            then
                imageSize=$(echo $blockThree)
            else
                if [[ "$blockThree" == *" "* ]];
                then
                    titleByLanguage=$(echo $blockThree)
                else
                    titleByLanguage=$(echo $blockThree | sed -r -e "s/([^A-Z])([A-Z])/\1 \2/g" -e "s/([A-Z]+)([A-Z])/\1 \2/g")
                fi
            fi
        fi
        
        if [[ "$blockFour" =~ ^[0-9][0-9][0-9][0-9]x[0-9][0-9][0-9][0-9] || "$blockFour" =~ ^[0-9][0-9][0-9][0-9]x[0-9][0-9][0-9] || "$blockFour" =~ ^[0-9][0-9][0-9]x[0-9][0-9][0-9][0-9] || "$blockFour" =~ ^[0-9][0-9][0-9]x[0-9][0-9][0-9] ]];
        then
            imageSize=$(echo $blockFour)
        else
            if [[ "$blockFour" =~ ^(M|S).*[0-9]$ || "$blockFour" =~ ^(M|S)[0-9].*E[0-9]$ || "$blockFour" =~ ^(M|S)[0-9].*E[0-9][0-9]$ || "$blockFour" =~ ^(M|S)[0-9][0-9].*E[0-9]$ || "$blockFour" =~ ^(M|S)[0-9][0-9].*E[0-9][0-9]$ ]];
            then
                seasonNumberCheck=$(echo $blockFour | awk 'BEGIN { FPAT = "[0-9]+" } {print $1}')
                episodeNumberCheck=$(echo $blockFour | awk 'BEGIN { FPAT = "[0-9]+" } {print $2}')
                imageDesc=$(echo $blockFour)
            else
                blockFour=$(echo $blockFour | tr '[:upper:]' '[:lower:]')
                if [[ ("$blockFour" == "cover") || ("$blockFour" == "feature") || ("$blockFour" == "keyart") || ("$blockFour" == *"still"*) || ("$blockFour" == "blank") ]];
                then
                    imageType=$(echo $blockFour)
                else
                    if [[ "$blockFour" == *" "* ]];
                    then
                        imageDesc=$(echo $blockFour)
                    else
                        imageDesc=$(echo $blockFour | sed -r -e "s/([^A-Z])([A-Z])/\1 \2/g" -e "s/([A-Z]+)([A-Z])/\1 \2/g")
                    fi
                fi
            fi
        fi

        if [[ "$blockFive" =~ ^[0-9][0-9][0-9][0-9]x[0-9][0-9][0-9][0-9] || "$blockFive" =~ ^[0-9][0-9][0-9][0-9]x[0-9][0-9][0-9] || "$blockFive" =~ ^[0-9][0-9][0-9]x[0-9][0-9][0-9][0-9] || "$blockFive" =~ ^[0-9][0-9][0-9]x[0-9][0-9][0-9] ]];
        then
            imageSize=$(echo $blockFive)
        else
            if [[ "$blockFive" =~ ^(M|S).*[0-9]$ || "$blockFive" =~ ^(M|S)[0-9].*E[0-9]$ || "$blockFive" =~ ^(M|S)[0-9].*E[0-9][0-9]$ || "$blockFive" =~ ^(M|S)[0-9][0-9].*E[0-9]$ || "$blockFive" =~ ^(M|S)[0-9][0-9].*E[0-9][0-9]$ ]];
            then
                seasonNumberCheck=$(echo $blockFive | awk 'BEGIN { FPAT = "[0-9]+" } {print $1}')
                episodeNumberCheck=$(echo $blockFive | awk 'BEGIN { FPAT = "[0-9]+" } {print $2}')
                imageDesc=$(echo $blockFive)
            else
                blockFive=$(echo $blockFive | tr '[:upper:]' '[:lower:]')
                if [[ ("$blockFive" == "cover") || ("$blockFive" == "feature") || ("$blockFive" == "keyart") || ("$blockFive" == *"still"*) || ("$blockFive" == "blank") ]];
                then
                    imageType=$(echo $blockFive)
                else
                    if [[ "$blockFive" == *" "* ]];
                    then
                        imageDesc=$(echo $blockFive)
                    else
                        imageDesc=$(echo $blockFive | sed -r -e "s/([^A-Z])([A-Z])/\1 \2/g" -e "s/([A-Z]+)([A-Z])/\1 \2/g")
                    fi
                fi
            fi
        fi

        if [[ $titleCode == "S"* ]];
        then 
            graphicsTags="<field><name>oly_graphicsTags</name><value>$blockOne</value><value>$blockTwo</value><value>$blockThree</value><value>$blockFour</value></field><field><name>oly_seasonNumber</name><value>$seasonNumberCheck</value></field><field><name>oly_episodeNumber</name><value>$episodeNumberCheck</value></field>"
        else
            graphicsTags="<field><name>oly_graphicsTags</name><value>$blockOne</value><value>$blockTwo</value><value>$blockThree</value><value>$blockFour</value></field>"
        fi
        
        echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - +++++++++++++++++++++++++++++++++" >> "$logfile"
        echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - titleCode - $titleCode" >> "$logfile"
        echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - imageType - $imageType" >> "$logfile"
        echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - titleByLanguage - $titleByLanguage" >> "$logfile"
        echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - language - $language" >> "$logfile"
        echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - imageSize - $imageSize" >> "$logfile"
        echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - imageDesc - $imageDesc" >> "$logfile"
        echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - seasonNumber - $seasonNumberCheck" >> "$logfile"
        echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - episodeNumber - $episodeNumberCheck" >> "$logfile"
        echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - graphicsTags - $graphicsTags" >> "$logfile"
        
        : '
        namingConventionCheck=$(echo $title | awk -F "_" '{print $2}')
        if [[ ("$namingConventionCheck" == "EN") || ("$namingConventionCheck" == "ES") || ("$namingConventionCheck" == "FR") || ("$namingConventionCheck" == "OG") ]];
            then
                titleByLanguage=$(echo $title | awk -F "_" '{print $1}')
                #titleByLanguage=$(echo $titleByLanguage | sed -r -e "s/([^A-Z])([A-Z])/\1 \2/g" -e "s/([A-Z]+)([A-Z])/\1 \2/g")
                language=$(echo $title | awk -F "_" '{print $2}')
                blockThree=$(echo $title | awk -F "_" '{print $3}')
                blockThreeCharCount=$(echo -n $blockThree | wc -c)
                blockFour=$(echo $title | awk -F "_" '{print $4}')
                blockFive=$(echo $title | awk -F "_" '{print $5}')
                #titleCode=$(echo $title | awk -F "_" '{print $3}')
                #imageType=$(echo $title | awk -F "_" '{print $4}')
                #imageSize=$(echo $title | awk -F "_" '{print $5}')

                if [[ "$blockThree" =~ ^(M|S).*[0-9]$ ]];
                then
                    echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - Check Block Three for Title Code PASSED - {$blockThree} - {$blockThreeCharCount}" >> "$logfile"
                    case $blockThreeCharCount in
                        "7")
                            titleCode=$(echo $blockThree)
                            echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - Title Code is {$titleCode} - {7}" >> "$logfile"
                        ;;
                        "9")
                            titleCode=$(echo $blockThree)
                            echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - Title Code is {$titleCode} - {9}" >> "$logfile"
                        ;;
                        "10")
                            titleCode=$(echo $blockThree)
                            echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - Title Code is {$titleCode} - {10}" >> "$logfile"
                        ;;
                        "11")
                            titleCode=$(echo $blockThree)
                            echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - Title Code is {$titleCode} - {11}" >> "$logfile"
                        ;;
                        "12")
                            titleCode=$(echo $blockThree)
                            echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - Title Code is {$titleCode} - {12}" >> "$logfile"
                        ;;
                        "13")
                            titleCode=$(echo $blockThree)
                            echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - Title Code is {$titleCode} - {13}" >> "$logfile"
                        ;;
                        *)
                            imageMisc=$(echo $blockThree)
                            echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - Title Code Check FAILED - Setting as imageMisc {$blockThree} - {$blockThreeCharCount}" >> "$logfile"
                        ;;
                    esac
                else
                    imageMisc=$(echo $blockThree)
                    echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - Check Block Three for Title Code Check FAILED - Setting as imageMisc {$blockThree} - {$blockThreeCharCount}" >> "$logfile"
                fi

                if [[ "$blockFour" =~ ^(M|S).*[0-9]$ ]];
                then
                    if [[ "$blockFour" =~ ^(M|S).*[0-9]$ || "$blockFour" =~ ^(M|S)[0-9].*E[0-9]$ || "$blockFour" =~ ^(M|S)[0-9].*E[0-9][0-9]$ || "$blockFour" =~ ^(M|S)[0-9][0-9].*E[0-9]$ || "$blockFour" =~ ^(M|S)[0-9][0-9].*E[0-9][0-9]$ ]];
                    then
                        echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - Check Block Four for Season-Episode PASSED - {$blockFour}" >> "$logfile"
                        seasonNumberCheck=$(echo $blockFour | awk 'BEGIN { FPAT = "[0-9]+" } {print $1}')
                        episodeNumberCheck=$(echo $blockFour | awk 'BEGIN { FPAT = "[0-9]+" } {print $2}')
                        imageDesc=$(echo $blockFour)
                    else
                        echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - Check Block Four for Title Code PASSED - {$blockFour} - {$blockFourCharCount}" >> "$logfile"
                        case $blockFourCharCount in
                            "7")
                                titleCode=$(echo $blockFour)
                                echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - Title Code is {$titleCode} - {7}" >> "$logfile"
                            ;;
                            "9")
                                titleCode=$(echo $blockFour)
                                echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - Title Code is {$titleCode} - {9}" >> "$logfile"
                            ;;
                            "10")
                                titleCode=$(echo $blockFour)
                                echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - Title Code is {$titleCode} - {10}" >> "$logfile"
                            ;;
                            "11")
                                titleCode=$(echo $blockFour)
                                echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - Title Code is {$titleCode} - {11}" >> "$logfile"
                            ;;
                            "12")
                                titleCode=$(echo $blockFour)
                                echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - Title Code is {$titleCode} - {12}" >> "$logfile"
                            ;;
                            "13")
                                titleCode=$(echo $blockFour)
                                echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - Title Code is {$titleCode} - {13}" >> "$logfile"
                            ;;
                            *)
                                imageDesc=$(echo $blockFour)
                                echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - Title Code Check FAILED - Setting as imageDesc {$blockFour} - {$blockFourCharCount}" >> "$logfile"
                            ;;
                        esac
                    fi
                else
                    imageDesc=$(echo $blockFour)
                    echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - Check Block Four - Setting as imageDesc {$blockFour}" >> "$logfile"
                fi

                if [[ "$blockFive" =~ ^(M|S).*[0-9]$ ]];
                then
                    echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - Check Block Five for Title Code PASSED - {$blockFive} - {$blockFiveCharCount}" >> "$logfile"
                    case $blockFiveCharCount in
                        "7")
                            titleCode=$(echo $blockFive)
                            echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - Title Code is {$titleCode} - 7" >> "$logfile"
                        ;;
                        "9")
                            titleCode=$(echo $blockFive)
                            echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - Title Code is {$titleCode} - 9" >> "$logfile"
                        ;;
                        "10")
                            titleCode=$(echo $blockFive)
                            echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - Title Code is {$titleCode} - 10" >> "$logfile"
                        ;;
                        "11")
                            titleCode=$(echo $blockFive)
                            echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - Title Code is {$titleCode} - 11" >> "$logfile"
                        ;;
                        "12")
                            titleCode=$(echo $blockFive)
                            echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - Title Code is {$titleCode} - 12" >> "$logfile"
                        ;;
                        "13")
                            titleCode=$(echo $blockFive)
                            echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - Title Code is {$titleCode} - 13" >> "$logfile"
                        ;;
                        *)
                            imageType=$(echo $blockFive)
                            echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - Title Code Check FAILED - Setting as imageType {$blockFive} - {$blockFiveCharCount}" >> "$logfile"
                        ;;
                    esac
                else
                    imageType=$(echo $blockFive)
                    echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - Check Block Five - Setting as imageType {$blockFive}" >> "$logfile"
                fi

                echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - +++++++++++++++++++++++++++++++++" >> "$logfile"
                echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - titleCode - $titleCode" >> "$logfile"
                echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - titleByLanguage - $titleByLanguage" >> "$logfile"
                echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - language - $language" >> "$logfile"
                echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - imageType - $imageType" >> "$logfile"
                echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - imageSize - $imageSize" >> "$logfile"
                echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - imageDesc - $imageDesc" >> "$logfile"
                echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - imageMisc - $imageMisc" >> "$logfile"
                echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - seasonNumber - $seasonNumberCheck" >> "$logfile"
                echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - episodeNumber - $episodeNumberCheck" >> "$logfile"
            else
                namingConventionCheck=$(echo $title | awk -F "_" '{print $2}' | tr '[:upper:]' '[:lower:]')
                if [[ ("$namingConventionCheck" == "cover") || ("$namingConventionCheck" == "feature") || ("$namingConventionCheck" == "keyart") || ("$namingConventionCheck" == "still") || ("$namingConventionCheck" == "poster") || ("$namingConventionCheck" == "blank") ]];
                then
                    titleCode=$(echo $title | awk -F "_" '{print $1}')
                    imageType=$(echo $title | awk -F "_" '{print $2}' | tr '[:upper:]' '[:lower:]')
                    titleByLanguage=$(echo $title | awk -F "_" '{print $3}')
                    titleByLanguage=$(echo $titleByLanguage | sed -r -e "s/([^A-Z])([A-Z])/\1 \2/g" -e "s/([A-Z]+)([A-Z])/\1 \2/g")
                    language=$(echo $title | awk -F "_" '{print $4}')
                    imageSize=$(echo $title | awk -F "_" '{print $5}')

                    echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - +++++++++++++++++++++++++++++++++" >> "$logfile"
                    echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - titleCode - $titleCode" >> "$logfile"
                    echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - imageType - $imageType" >> "$logfile"
                    echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - titleByLanguage - $titleByLanguage" >> "$logfile"
                    echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - language - $language" >> "$logfile"
                    echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - imageSize - $imageSize" >> "$logfile"
                else
                    titleCode=$(echo $title | awk -F "_" '{print $1}')
                    imageType=$(echo $title | awk -F "_" '{print $2}' | tr '[:upper:]' '[:lower:]')
                    titleByLanguage=$(echo $title | awk -F "_" '{print $3}')
                    titleByLanguage=$(echo $titleByLanguage | sed -r -e "s/([^A-Z])([A-Z])/\1 \2/g" -e "s/([A-Z]+)([A-Z])/\1 \2/g")
                    language=$(echo $title | awk -F "_" '{print $4}')
                    imageSize=$(echo $title | awk -F "_" '{print $5}')

                    echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - +++++++++++++++++++++++++++++++++" >> "$logfile"
                    echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - titleCode - $titleCode" >> "$logfile"
                    echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - imageType - $imageType" >> "$logfile"
                    echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - titleByLanguage - $titleByLanguage" >> "$logfile"
                    echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - language - $language" >> "$logfile"
                    echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - imageSize - $imageSize" >> "$logfile"
                fi
        fi
        '
    else
        if [[ $numberOfUnderscores == 3 ]];
            then
                blockOne=$(echo $title | awk -F "_" '{print $1}')
                blockTwo=$(echo $title | awk -F "_" '{print $2}')
                blockThree=$(echo $title | awk -F "_" '{print $3}')
                blockFour=$(echo $title | awk -F "_" '{print $4}')

                blockOneCharCount=$(echo -n $blockOne | wc -c)
                blockTwoCharCount=$(echo -n $blockTwo | wc -c)
                blockThreeCharCount=$(echo -n $blockThree | wc -c)
                blockFourCharCount=$(echo -n $blockFour | wc -c)

                echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - Check Block One for Info - {$blockOne} - {$blockOneCharCount}" >> "$logfile"
                if [[ "$blockOne" =~ ^(M|S).*[0-9]$ ]];
                then
                    case $blockOneCharCount in
                        "7")
                            titleCode=$(echo $blockOne)
                        ;;
                        "9")
                            titleCode=$(echo $blockOne)
                        ;;
                        "10")
                            titleCode=$(echo $blockOne)
                        ;;
                        "11")
                            titleCode=$(echo $blockOne)
                        ;;
                        "12")
                            titleCode=$(echo $blockOne)
                        ;;
                        "13")
                            titleCode=$(echo $blockOne)
                        ;;
                        *)
                            titleByLanguage=$(echo $blockOne)
                        ;;
                    esac
                else
                    titleByLanguage=$(echo $blockOne)
                fi

                echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - Title Code - {$titleCode}" >> "$logfile"
                echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - Title By Language - {$titleByLanguage}" >> "$logfile"

                echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - Check Block Two for Info - {$blockTwo} - {$blockTwoCharCount}" >> "$logfile"
                if [[ ("$blockTwo" == "EN") || ("$blockTwo" == "ES") || ("$blockTwo" == "FR") || ("$blockTwo" == "OG") ]];
                then
                    language=$(echo $blockTwo)
                else
                    blockTwo=$(echo $blockTwo | tr '[:upper:]' '[:lower:]')
                    if [[ ("$blockTwo" == "cover") || ("$blockTwo" == "feature") || ("$blockTwo" == "keyart") || ("$blockTwo" == "still") || ("$blockTwo" == "blank") ]];
                    then
                        imageType=$(echo $blockTwo)
                    fi
                fi

                echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - Language - {$language}" >> "$logfile"
                echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - Image Type - {$imageType}" >> "$logfile"

                if [[ "$blockThree" =~ ^(M|S).*[0-9]$ ]];
                then
                    case $blockThreeCharCount in
                        "7")
                            titleCode=$(echo $blockThree)
                        ;;
                        "9")
                            titleCode=$(echo $blockThree)
                        ;;
                        "10")
                            titleCode=$(echo $blockThree)
                        ;;
                        "11")
                            titleCode=$(echo $blockThree)
                        ;;
                        "12")
                            titleCode=$(echo $blockThree)
                        ;;
                        "13")
                            titleCode=$(echo $blockThree)
                        ;;
                        *)
                            imageMisc=$(echo $blockThree)
                        ;;
                    esac
                else
                    if [[ "$blockThree" =~ ^[0-9][0-9][0-9][0-9]x[0-9][0-9][0-9][0-9] || "$blockThree" =~ ^[0-9][0-9][0-9][0-9]x[0-9][0-9][0-9] || "$blockThree" =~ ^[0-9][0-9][0-9]x[0-9][0-9][0-9][0-9] || "$blockThree" =~ ^[0-9][0-9][0-9]x[0-9][0-9][0-9] ]];
                    then
                        imageSize=$(echo $blockThree)
                    else
                        if [[ "$blockThree" == *" "* ]];
                        then
                            titleByLanguage=$(echo $blockThree)
                        else
                            titleByLanguage=$(echo $blockThree | sed -r -e "s/([^A-Z])([A-Z])/\1 \2/g" -e "s/([A-Z]+)([A-Z])/\1 \2/g")
                        fi
                    fi
                fi
                
                if [[ "$blockFour" =~ ^[0-9][0-9][0-9][0-9]x[0-9][0-9][0-9][0-9] || "$blockFour" =~ ^[0-9][0-9][0-9][0-9]x[0-9][0-9][0-9] || "$blockFour" =~ ^[0-9][0-9][0-9]x[0-9][0-9][0-9][0-9] || "$blockFour" =~ ^[0-9][0-9][0-9]x[0-9][0-9][0-9] ]];
                then
                    imageSize=$(echo $blockFour)
                else
                    if [[ "$blockFour" =~ ^(M|S).*[0-9]$ || "$blockFour" =~ ^(M|S)[0-9].*E[0-9]$ || "$blockFour" =~ ^(M|S)[0-9].*E[0-9][0-9]$ || "$blockFour" =~ ^(M|S)[0-9][0-9].*E[0-9]$ || "$blockFour" =~ ^(M|S)[0-9][0-9].*E[0-9][0-9]$ ]];
                    then
                        seasonNumberCheck=$(echo $blockFour | awk 'BEGIN { FPAT = "[0-9]+" } {print $1}')
                        episodeNumberCheck=$(echo $blockFour | awk 'BEGIN { FPAT = "[0-9]+" } {print $2}')
                        imageDesc=$(echo $blockFour)
                    else
                        blockFour=$(echo $blockFour | tr '[:upper:]' '[:lower:]')
                        if [[ ("$blockFour" == "cover") || ("$blockFour" == "feature") || ("$blockFour" == "keyart") || ("$blockFour" == *"still"*) || ("$blockFour" == "blank") ]];
                        then
                            imageType=$(echo $blockFour)
                        else
                            if [[ "$blockFour" == *" "* ]];
                            then
                                imageDesc=$(echo $blockFour)
                            else
                                imageDesc=$(echo $blockFour | sed -r -e "s/([^A-Z])([A-Z])/\1 \2/g" -e "s/([A-Z]+)([A-Z])/\1 \2/g")
                            fi
                        fi
                    fi
                fi

                if [[ $titleCode == "S"* ]];
                then 
                    graphicsTags="<field><name>oly_graphicsTags</name><value>$blockOne</value><value>$blockTwo</value><value>$blockThree</value><value>$blockFour</value></field><field><name>oly_seasonNumber</name><value>$seasonNumberCheck</value></field><field><name>oly_episodeNumber</name><value>$episodeNumberCheck</value></field>"
                else
                    graphicsTags="<field><name>oly_graphicsTags</name><value>$blockOne</value><value>$blockTwo</value><value>$blockThree</value><value>$blockFour</value></field>"
                fi
                
                echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - +++++++++++++++++++++++++++++++++" >> "$logfile"
                echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - titleCode - $titleCode" >> "$logfile"
                echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - imageType - $imageType" >> "$logfile"
                echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - titleByLanguage - $titleByLanguage" >> "$logfile"
                echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - language - $language" >> "$logfile"
                echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - imageSize - $imageSize" >> "$logfile"
                echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - imageDesc - $imageDesc" >> "$logfile"
                echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - seasonNumber - $seasonNumberCheck" >> "$logfile"
                echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - episodeNumber - $episodeNumberCheck" >> "$logfile"
                echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - graphicsTags - $graphicsTags" >> "$logfile"
                
                : '
                namingConventionCheck=$(echo $title | awk -F "_" '{print $2}')
                if [[ ("$namingConventionCheck" == "EN") || ("$namingConventionCheck" == "ES") || ("$namingConventionCheck" == "FR") || ("$namingConventionCheck" == "OG") ]];
                    then
                        titleByLanguage=$(echo $title | awk -F "_" '{print $1}')
                        #titleByLanguage=$(echo $titleByLanguage | sed -r -e "s/([^A-Z])([A-Z])/\1 \2/g" -e "s/([A-Z]+)([A-Z])/\1 \2/g")
                        language=$(echo $title | awk -F "_" '{print $2}')
                        titleCode=$(echo $title | awk -F "_" '{print $3}')
                        imageType=$(echo $title | awk -F "_" '{print $4}')

                        seasonNumberCheck=$(echo $imageType | awk 'BEGIN { FPAT = "[0-9]+" } {print $1}')
                        episodeNumberCheck=$(echo $imageType | awk 'BEGIN { FPAT = "[0-9]+" } {print $2}')

                        echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - titleCode - $titleCode" >> "$logfile"
                        echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - imageType - $imageType" >> "$logfile"
                        echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - titleByLanguage - $titleByLanguage" >> "$logfile"
                        echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - language - $language" >> "$logfile"
                        echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - seasonNumber - $seasonNumberCheck" >> "$logfile"
                        echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - episodeNumber - $episodeNumberCheck" >> "$logfile"
                    else
                        namingConventionCheck=$(echo $title | awk -F "_" '{print $2}' | tr '[:upper:]' '[:lower:]')
                        if [[ ("$namingConventionCheck" == "cover") || ("$namingConventionCheck" == "feature") || ("$namingConventionCheck" == "keyart") || ("$namingConventionCheck" == "still") || ("$namingConventionCheck" == "blank") ]];
                        then
                            titleCode=$(echo $title | awk -F "_" '{print $1}')
                            imageType=$(echo $title | awk -F "_" '{print $2}')
                            titleByLanguage=$(echo $title | awk -F "_" '{print $3}')
                            titleByLanguage=$(echo $titleByLanguage | sed -r -e "s/([^A-Z])([A-Z])/\1 \2/g" -e "s/([A-Z]+)([A-Z])/\1 \2/g")
                            imageSize=$(echo $title | awk -F "_" '{print $4}')

                            echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - titleCode - $titleCode" >> "$logfile"
                            echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - imageType - $imageType" >> "$logfile"
                            echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - titleByLanguage - $titleByLanguage" >> "$logfile"
                            echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - imageSize - $imageSize" >> "$logfile"
                        else
                            titleCode=$(echo $title | awk -F "_" '{print $1}')
                            imageType=$(echo $title | awk -F "_" '{print $2}')
                            titleByLanguage=$(echo $title | awk -F "_" '{print $3}')
                            titleByLanguage=$(echo $titleByLanguage | sed -r -e "s/([^A-Z])([A-Z])/\1 \2/g" -e "s/([A-Z]+)([A-Z])/\1 \2/g")
                            imageSize=$(echo $title | awk -F "_" '{print $4}')

                            echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - titleCode - $titleCode" >> "$logfile"
                            echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - imageType - $imageType" >> "$logfile"
                            echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - titleByLanguage - $titleByLanguage" >> "$logfile"
                            echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - imageSize - $imageSize" >> "$logfile"
                        fi
                    fi
                    '
            else
                if [[ $numberOfUnderscores == 2 ]];
                    then
                        namingConventionCheck=$(echo $title | awk -F "_" '{print $2}')
                        if [[ ("$namingConventionCheck" == "EN") || ("$namingConventionCheck" == "ES") || ("$namingConventionCheck" == "FR") || ("$namingConventionCheck" == "OG") ]];
                            then
                                titleByLanguage=$(echo $title | awk -F "_" '{print $1}')
                                #titleByLanguage=$(echo $titleByLanguage | sed -r -e "s/([^A-Z])([A-Z])/\1 \2/g" -e "s/([A-Z]+)([A-Z])/\1 \2/g")
                                language=$(echo $title | awk -F "_" '{print $2}')
                                titleCode=$(echo $title | awk -F "_" '{print $3}')
                                imageType=$(echo $title | awk -F "_" '{print $4}')

                                seasonNumberCheck=$(echo $imageType | awk 'BEGIN { FPAT = "[0-9]+" } {print $1}')
                                episodeNumberCheck=$(echo $imageType | awk 'BEGIN { FPAT = "[0-9]+" } {print $2}')

                                echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - titleCode - $titleCode" >> "$logfile"
                                echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - imageType - $imageType" >> "$logfile"
                                echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - titleByLanguage - $titleByLanguage" >> "$logfile"
                                echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - language - $language" >> "$logfile"
                                echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - seasonNumber - $seasonNumberCheck" >> "$logfile"
                                echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - episodeNumber - $episodeNumberCheck" >> "$logfile"
                            else
                                titleCode=$(echo $title | awk -F "_" '{print $1}')
                                imageType=$(echo $title | awk -F "_" '{print $2}')
                                titleByLanguage=$(echo $title | awk -F "_" '{print $3}')
                                titleByLanguage=$(echo $titleByLanguage | sed -r -e "s/([^A-Z])([A-Z])/\1 \2/g" -e "s/([A-Z]+)([A-Z])/\1 \2/g")

                                echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - titleCode - $titleCode" >> "$logfile"
                                echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - imageType - $imageType" >> "$logfile"
                                echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - titleByLanguage - $titleByLanguage" >> "$logfile"
                            fi
                    else
                        if [[ $numberOfUnderscores == 5 ]];
                            then
                                namingConventionCheck=$(echo $title | awk -F "_" '{print $2}')
                                if [[ ("$namingConventionCheck" == "EN") || ("$namingConventionCheck" == "ES") || ("$namingConventionCheck" == "FR") || ("$namingConventionCheck" == "OG") ]];
                                    then
                                        titleByLanguage=$(echo $title | awk -F "_" '{print $1}')
                                        #titleByLanguage=$(echo $titleByLanguage | sed -r -e "s/([^A-Z])([A-Z])/\1 \2/g" -e "s/([A-Z]+)([A-Z])/\1 \2/g")
                                        language=$(echo $title | awk -F "_" '{print $2}')
                                        titleCode=$(echo $title | awk -F "_" '{print $3}')
                                        imageType=$(echo $title | awk -F "_" '{print $4}')
                                        cast=$(echo $title | awk -F "_" '{print $5}')
                                        imageSize=$(echo $title | awk -F "_" '{print $6}')

                                        seasonNumberCheck=$(echo $imageType | awk 'BEGIN { FPAT = "[0-9]+" } {print $1}')
                                        episodeNumberCheck=$(echo $imageType | awk 'BEGIN { FPAT = "[0-9]+" } {print $2}')

                                        echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - titleCode - $titleCode" >> "$logfile"
                                        echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - imageType - $imageType" >> "$logfile"
                                        echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - titleByLanguage - $titleByLanguage" >> "$logfile"
                                        echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - language - $language" >> "$logfile"
                                        echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - cast - $cast" >> "$logfile"
                                        echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - imageSize - $imageSize" >> "$logfile"
                                        echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - seasonNumber - $seasonNumberCheck" >> "$logfile"
                                        echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - episodeNumber - $episodeNumberCheck" >> "$logfile"
                                    else
                                        titleCode=$(echo $title | awk -F "_" '{print $1}')
                                        imageType=$(echo $title | awk -F "_" '{print $2}')
                                        titleByLanguage=$(echo $title | awk -F "_" '{print $3}')
                                        titleByLanguage=$(echo $titleByLanguage | sed -r -e "s/([^A-Z])([A-Z])/\1 \2/g" -e "s/([A-Z]+)([A-Z])/\1 \2/g")
                                        seasonNumber=$(echo $title | awk -F "_" '{print $4}')
                                        episodeNumber=$(echo $title | awk -F "_" '{print $5}')
                                        imageSize=$(echo $title | awk -F "_" '{print $6}')

                                        echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - titleCode - $titleCode" >> "$logfile"
                                        echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - imageType - $imageType" >> "$logfile"
                                        echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - titleByLanguage - $titleByLanguage" >> "$logfile"
                                        echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - seasonNumber - $seasonNumber" >> "$logfile"
                                        echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - episodeNumber - $episodeNumber" >> "$logfile"
                                        echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - imageSize - $imageSize" >> "$logfile"
                                fi
                            else
                                if [[ $numberOfUnderscores == 6 ]];
                                    then
                                        namingConventionCheck=$(echo $title | awk -F "_" '{print $2}')
                                        if [[ ("$namingConventionCheck" == "EN") || ("$namingConventionCheck" == "ES") || ("$namingConventionCheck" == "FR") || ("$namingConventionCheck" == "OG") ]];
                                            then
                                                titleByLanguage=$(echo $title | awk -F "_" '{print $1}')
                                                #titleByLanguage=$(echo $titleByLanguage | sed -r -e "s/([^A-Z])([A-Z])/\1 \2/g" -e "s/([A-Z]+)([A-Z])/\1 \2/g")
                                                language=$(echo $title | awk -F "_" '{print $2}')
                                                titleCode=$(echo $title | awk -F "_" '{print $3}')
                                                imageType=$(echo $title | awk -F "_" '{print $4}')
                                                imageSize=$(echo $title | awk -F "_" '{print $5}')
                                                imageNumber=$(echo $title | awk -F "_" '{print $6}')
                                                desc=$(echo $title | awk -F "_" '{print $7}')

                                                seasonNumberCheck=$(echo $imageType | awk 'BEGIN { FPAT = "[0-9]+" } {print $1}')
                                                episodeNumberCheck=$(echo $imageType | awk 'BEGIN { FPAT = "[0-9]+" } {print $2}')

                                                echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - titleCode - $titleCode" >> "$logfile"
                                                echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - imageType - $imageType" >> "$logfile"
                                                echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - titleByLanguage - $titleByLanguage" >> "$logfile"
                                                echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - language - $language" >> "$logfile"
                                                echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - imageSize - $imageSize" >> "$logfile"
                                                echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - imageNumber - $imageNumber" >> "$logfile"
                                                echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - desc - $desc" >> "$logfile"
                                                echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - seasonNumber - $seasonNumberCheck" >> "$logfile"
                                                echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - episodeNumber - $episodeNumberCheck" >> "$logfile"
                                            else
                                                titleCode=$(echo $title | awk -F "_" '{print $1}')
                                                imageType=$(echo $title | awk -F "_" '{print $2}')
                                                titleByLanguage=$(echo $title | awk -F "_" '{print $3}')
                                                titleByLanguage=$(echo $titleByLanguage | sed -r -e "s/([^A-Z])([A-Z])/\1 \2/g" -e "s/([A-Z]+)([A-Z])/\1 \2/g")
                                                seasonNumber=$(echo $title | awk -F "_" '{print $4}')
                                                episodeNumber=$(echo $title | awk -F "_" '{print $5}')
                                                imageSize=$(echo $title | awk -F "_" '{print $6}')

                                                echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - titleCode - $titleCode" >> "$logfile"
                                                echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - imageType - $imageType" >> "$logfile"
                                                echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - titleByLanguage - $titleByLanguage" >> "$logfile"
                                                echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - seasonNumber - $seasonNumber" >> "$logfile"
                                                echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - episodeNumber - $episodeNumber" >> "$logfile"
                                                echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - imageSize - $imageSize" >> "$logfile"
                                        fi
                                    else
                                        if [[ $numberOfUnderscores == 7 ]];
                                            then
                                                namingConventionCheck=$(echo $title | awk -F "_" '{print $2}')
                                                if [[ ("$namingConventionCheck" == "EN") || ("$namingConventionCheck" == "ES") || ("$namingConventionCheck" == "FR") || ("$namingConventionCheck" == "OG") ]];
                                                    then
                                                        titleByLanguage=$(echo $title | awk -F "_" '{print $1}')
                                                        #titleByLanguage=$(echo $titleByLanguage | sed -r -e "s/([^A-Z])([A-Z])/\1 \2/g" -e "s/([A-Z]+)([A-Z])/\1 \2/g")
                                                        language=$(echo $title | awk -F "_" '{print $2}')
                                                        titleCode=$(echo $title | awk -F "_" '{print $3}')
                                                        imageType=$(echo $title | awk -F "_" '{print $4}')
                                                        imageSize=$(echo $title | awk -F "_" '{print $5}')
                                                        imageNumber=$(echo $title | awk -F "_" '{print $6}')
                                                        desc=$(echo $title | awk -F "_" '{print $7}')
                                                        desc2=$(echo $title | awk -F "_" '{print $8}')

                                                        seasonNumberCheck=$(echo $imageType | awk 'BEGIN { FPAT = "[0-9]+" } {print $1}')
                                                        episodeNumberCheck=$(echo $imageType | awk 'BEGIN { FPAT = "[0-9]+" } {print $2}')

                                                        echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - titleCode - $titleCode" >> "$logfile"
                                                        echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - imageType - $imageType" >> "$logfile"
                                                        echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - titleByLanguage - $titleByLanguage" >> "$logfile"
                                                        echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - language - $language" >> "$logfile"
                                                        echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - imageSize - $imageSize" >> "$logfile"
                                                        echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - imageNumber - $imageNumber" >> "$logfile"
                                                        echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - desc - $desc" >> "$logfile"
                                                        echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - seasonNumber - $seasonNumberCheck" >> "$logfile"
                                                        echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - episodeNumber - $episodeNumberCheck" >> "$logfile"
                                                    else
                                                        titleCode=$(echo $title | awk -F "_" '{print $1}')
                                                        imageType=$(echo $title | awk -F "_" '{print $2}')
                                                        titleByLanguage=$(echo $title | awk -F "_" '{print $3}')
                                                        titleByLanguage=$(echo $titleByLanguage | sed -r -e "s/([^A-Z])([A-Z])/\1 \2/g" -e "s/([A-Z]+)([A-Z])/\1 \2/g")
                                                        seasonNumber=$(echo $title | awk -F "_" '{print $4}')
                                                        episodeNumber=$(echo $title | awk -F "_" '{print $5}')
                                                        imageSize=$(echo $title | awk -F "_" '{print $6}')

                                                        echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - titleCode - $titleCode" >> "$logfile"
                                                        echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - imageType - $imageType" >> "$logfile"
                                                        echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - titleByLanguage - $titleByLanguage" >> "$logfile"
                                                        echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - seasonNumber - $seasonNumber" >> "$logfile"
                                                        echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - episodeNumber - $episodeNumber" >> "$logfile"
                                                        echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - imageSize - $imageSize" >> "$logfile"
                                                fi
                                            else
                                                echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - Does NOT Have Supported Number of Underscores - $numberOfUnderscores" >> "$logfile"
                                        fi
                                fi
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
    if [[ $titleCode == "S"* ]];
    then 
        graphicsTags="<field><name>oly_graphicsTags</name><value>$blockOne</value><value>$blockTwo</value><value>$blockThree</value><value>$blockFour</value><value>$blockFive</value></field><field><name>oly_seasonNumber</name><value>$seasonNumberCheck</value></field><field><name>oly_episodeNumber</name><value>$episodeNumberCheck</value></field>"
    else
        graphicsTags="<field><name>oly_graphicsTags</name><value>$blockOne</value><value>$blockTwo</value><value>$blockThree</value><value>$blockFour</value><value>$blockFive</value></field>"
    fi
    : '
    if [[ $language == "es" || $language == "en" || $language == "ES" || $language == "EN" || $language == "FR" ]];
    then
        if [[ $titleCode == "S"* ]];
        then 
            graphicsTags="<field><name>oly_graphicsTags</name><value>$blockThree</value><value>$blockFour</value><value>$titleByLanguage</value><value>$language</value><value>$blockFive</value></field><field><name>oly_seasonNumber</name><value>$seasonNumberCheck</value></field><field><name>oly_episodeNumber</name><value>$episodeNumberCheck</value></field>"
        else
            graphicsTags="<field><name>oly_graphicsTags</name><value>$blockThree</value><value>$blockFour</value><value>$titleByLanguage</value><value>$language</value><value>$blockFive</value></field>"
        fi
    else
        if [[ $language == "OG" ]];
        then
            if [[ $titleCode == "S"* ]];
            then 
                graphicsTags="<field><name>oly_graphicsTags</name><value>$blockThree</value><value>$blockFour</value><value>$titleByLanguage</value><value>$blockFive</value></field><field><name>oly_seasonNumber</name><value>$seasonNumberCheck</value></field><field><name>oly_episodeNumber</name><value>$episodeNumberCheck</value></field>"
            else
                graphicsTags="<field><name>oly_graphicsTags</name><value>$blockThree</value><value>$blockFour</value><value>$titleByLanguage</value><value>$blockFive</value></field>"
            fi
        else
            graphicsTags="<field><name>oly_graphicsTags</name><value>$blockThree</value><value>$blockFour</value><value>$titleByLanguage</value><value>$blockFive</value></field>"
        fi
    fi
    '
else
    if [[ $numberOfUnderscores == 3 ]];
    then
        if [[ $titleCode == "S"* ]];
        then 
            graphicsTags="<field><name>oly_graphicsTags</name><value>$blockOne</value><value>$blockTwo</value><value>$blockThree</value><value>$blockFour</value></field><field><name>oly_seasonNumber</name><value>$seasonNumberCheck</value></field><field><name>oly_episodeNumber</name><value>$episodeNumberCheck</value></field>"
        else
            graphicsTags="<field><name>oly_graphicsTags</name><value>$blockOne</value><value>$blockTwo</value><value>$blockThree</value><value>$blockFour</value></field>"
        fi
        : '
        if [[ $language == "es" || $language == "en" || $language == "ES" || $language == "EN" || $language == "FR" || $language == "OG" ]];
            then
                if [[ $titleCode == "S"* ]];
                    then 
                        graphicsTags="<field><name>oly_graphicsTags</name><value>$blockOne</value><value>$blockTwo</value><value>$blockThree</value><value>$blockFour</value></field><field><name>oly_seasonNumber</name><value>$seasonNumberCheck</value></field><field><name>oly_episodeNumber</name><value>$episodeNumberCheck</value></field>"
                    else
                        graphicsTags="<field><name>oly_graphicsTags</name><value>$blockOne</value><value>$blockTwo</value><value>$blockThree</value><value>$blockFour</value></field>"
                fi
            else
                if [[ $language == "OG" ]];
                    then
                        if [[ $titleCode == "S"* ]];
                            then 
                                graphicsTags="<field><name>oly_graphicsTags</name><value>$blockOne</value><value>$blockTwo</value><value>$blockThree</value><value>$blockFour</value></field><field><name>oly_seasonNumber</name><value>$seasonNumberCheck</value></field><field><name>oly_episodeNumber</name><value>$episodeNumberCheck</value></field>"
                            else
                                graphicsTags="<field><name>oly_graphicsTags</name><value>$blockOne</value><value>$blockTwo</value><value>$blockThree</value><value>$blockFour</value></field>"
                        fi
                    else
                        graphicsTags="<field><name>oly_graphicsTags</name><value>$blockOne</value><value>$blockTwo</value><value>$blockThree</value><value>$blockFour</value></field>"
                fi
        fi
        '
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
                        graphicsTags="<field><name>oly_graphicsTags</name><value>$titleCode</value><value>$imageType</value><value>$titleByLanguage</value><value>$language</value><value>$cast</value><value>$imageSize</value></field><field><name>oly_seasonNumber</name><value>$seasonNumberCheck</value></field><field><name>oly_episodeNumber</name><value>$episodeNumberCheck</value></field>"
                    else
                        graphicsTags="<field><name>oly_graphicsTags</name><value>$titleCode</value><value>$imageType</value><value>$titleByLanguage</value><value>$language</value><value>$cast</value><value>$imageSize</value></field>"
                    fi
                else
                    if [[ $language == "OG" ]];
                    then
                        if [[ $titleCode == "S"* ]];
                        then 
                            graphicsTags="<field><name>oly_graphicsTags</name><value>$titleCode</value><value>$imageType</value><value>$titleByLanguage</value><value>$cast</value><value>$imageSize</value></field><field><name>oly_seasonNumber</name><value>$seasonNumberCheck</value></field><field><name>oly_episodeNumber</name><value>$episodeNumberCheck</value></field>"
                        else
                            graphicsTags="<field><name>oly_graphicsTags</name><value>$titleCode</value><value>$imageType</value><value>$titleByLanguage</value><value>$cast</value><value>$imageSize</value></field>"
                        fi
                    else
                        graphicsTags="<field><name>oly_graphicsTags</name><value>$titleCode</value><value>$imageType</value><value>$titleByLanguage</value><value>$seasonNumber</value><value>$episodeNumber</value><value>$imageSize</value></field><field><name>oly_seasonNumber</name><value>$seasonNumberCleaned</value></field><field><name>oly_episodeNumber</name><value>$episodeNumberCleaned</value></field>"
                        #graphicsTags="<field><name>oly_graphicsTags</name><value>$titleCode</value><value>$imageType</value><value>$titleByLanguage</value><value>$imageSize</value></field>"
                    fi
                fi
            else
                if [[ $numberOfUnderscores == 6 ]];
                then
                    if [[ $language == "es" || $language == "en" || $language == "ES" || $language == "EN" || $language == "FR" ]];
                    then
                        if [[ $titleCode == "S"* ]];
                            then 
                                graphicsTags="<field><name>oly_graphicsTags</name><value>$titleCode</value><value>$imageType</value><value>$titleByLanguage</value><value>$language</value><value>$imageNumber</value><value>$desc</value><value>$imageSize</value></field><field><name>oly_seasonNumber</name><value>$seasonNumberCheck</value></field><field><name>oly_episodeNumber</name><value>$episodeNumberCheck</value></field>"
                            else
                                graphicsTags="<field><name>oly_graphicsTags</name><value>$titleCode</value><value>$imageType</value><value>$titleByLanguage</value><value>$language</value><value>$imageNumber</value><value>$desc</value><value>$imageSize</value></field>"
                        fi
                    else
                        if [[ $language == "OG" ]];
                        then
                            if [[ $titleCode == "S"* ]];
                            then 
                                graphicsTags="<field><name>oly_graphicsTags</name><value>$titleCode</value><value>$imageType</value><value>$titleByLanguage</value><value>$imageNumber</value><value>$desc</value><value>$imageSize</value></field><field><name>oly_seasonNumber</name><value>$seasonNumberCheck</value></field><field><name>oly_episodeNumber</name><value>$episodeNumberCheck</value></field>"
                            else
                                graphicsTags="<field><name>oly_graphicsTags</name><value>$titleCode</value><value>$imageType</value><value>$titleByLanguage</value><value>$imageNumber</value><value>$desc</value><value>$imageSize</value></field>"
                            fi
                        else
                            graphicsTags="<field><name>oly_graphicsTags</name><value>$titleCode</value><value>$imageType</value><value>$titleByLanguage</value><value>$seasonNumber</value><value>$episodeNumber</value><value>$imageSize</value></field><field><name>oly_seasonNumber</name><value>$seasonNumberCleaned</value></field><field><name>oly_episodeNumber</name><value>$episodeNumberCleaned</value></field>"
                            #graphicsTags="<field><name>oly_graphicsTags</name><value>$titleCode</value><value>$imageType</value><value>$titleByLanguage</value><value>$imageSize</value></field>"
                        fi
                    fi
                else
                    if [[ $numberOfUnderscores == 7 ]];
                    then
                        if [[ $language == "es" || $language == "en" || $language == "ES" || $language == "EN" || $language == "FR" ]];
                        then
                            if [[ $titleCode == "S"* ]];
                                then 
                                    graphicsTags="<field><name>oly_graphicsTags</name><value>$titleCode</value><value>$imageType</value><value>$titleByLanguage</value><value>$language</value><value>$imageNumber</value><value>$desc</value><value>$desc2</value><value>$imageSize</value></field><field><name>oly_seasonNumber</name><value>$seasonNumberCheck</value></field><field><name>oly_episodeNumber</name><value>$episodeNumberCheck</value></field>"
                                else
                                    graphicsTags="<field><name>oly_graphicsTags</name><value>$titleCode</value><value>$imageType</value><value>$titleByLanguage</value><value>$language</value><value>$imageNumber</value><value>$desc</value><value>$desc2</value><value>$imageSize</value></field>"
                            fi
                        else
                            if [[ $language == "OG" ]];
                            then
                                if [[ $titleCode == "S"* ]];
                                then 
                                    graphicsTags="<field><name>oly_graphicsTags</name><value>$titleCode</value><value>$imageType</value><value>$titleByLanguage</value><value>$imageNumber</value><value>$desc</value><value>$desc2</value><value>$imageSize</value></field><field><name>oly_seasonNumber</name><value>$seasonNumberCheck</value></field><field><name>oly_episodeNumber</name><value>$episodeNumberCheck</value></field>"
                                else
                                    graphicsTags="<field><name>oly_graphicsTags</name><value>$titleCode</value><value>$imageType</value><value>$titleByLanguage</value><value>$imageNumber</value><value>$desc</value><value>$desc2</value><value>$imageSize</value></field>"
                                fi
                            else
                                graphicsTags="<field><name>oly_graphicsTags</name><value>$titleCode</value><value>$imageType</value><value>$titleByLanguage</value><value>$seasonNumber</value><value>$episodeNumber</value><value>$imageSize</value></field><field><name>oly_seasonNumber</name><value>$seasonNumberCleaned</value></field><field><name>oly_episodeNumber</name><value>$episodeNumberCleaned</value></field>"
                                #graphicsTags="<field><name>oly_graphicsTags</name><value>$titleCode</value><value>$imageType</value><value>$titleByLanguage</value><value>$imageSize</value></field>"
                            fi
                        fi
                    else
                        if [[ $numberOfUnderscores -lt 1 || $numberOfUnderscores -gt 8 ]];
                        then
                            echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - Does NOT Have Supported Number of Underscores - $numberOfUnderscores" >> "$logfile"
                        else
                            echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - End of the IF Statements - Last Else" >> "$logfile"
                        fi
                    fi
                fi
            fi
        fi
    fi
fi

case $language in
    "es")
        graphicsLanguage="spanish"
    ;;
    "en")
        graphicsLanguage="english"
    ;;
    "ES")
        graphicsLanguage="spanish"
    ;;
    "EN")
        graphicsLanguage="english"
    ;;
    "FR")
        graphicsLanguage=""
    ;;
    "OG")
        graphicsLanguage=""
    ;;
    *)
        graphicsLanguage=""
    ;;
esac

imageTypeCheck=$(echo $imageType | tr '[:upper:]' '[:lower:]')
case $imageTypeCheck in
    *"cover"*)
        graphicsType="cover"
    ;;
    *"feature"*)
        graphicsType="feature"
    ;;
    *"keyart"*)
        graphicsType="keyart"
    ;;
    *"still"*)
        graphicsType="still"
    ;;
    *"poster"*)
        graphicsType="poster"
    ;;
    *"blank"*)
        graphicsType="blank"
    ;;
    *)
        graphicsType=""
    ;;
esac

if [[ "$imageSize" =~ ^[0-9][0-9][0-9][0-9]x[0-9][0-9][0-9][0-9] ]];
then
    graphicsResolution=$(echo $imageSize)
    echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - Check Graphics Resolution -  PASSED - {$imageSize}" >> "$logfile"
else
    echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - Check Graphics Resolution - FAILED - {$imageSize}" >> "$logfile"
fi

echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - Graphics Type - $graphicsType" >> "$logfile"
echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - Graphics Resolution - $graphicsResolution" >> "$logfile"
echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - Graphics Language - $graphicsLanguage" >> "$logfile"
echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - Graphics Tags - $graphicsTags" >> "$logfile"

#bodyData=$(echo "<MetadataDocument xmlns=\"http://xml.vidispine.com/schema/vidispine\"><timespan start=\"-INF\" end=\"+INF\">$graphicsTags<field><name>oly_titleCode</name><value>$titleCode</value></field><field><name>oly_primaryMetadataLanguage</name><value>$graphicsLanguage</value></field><field><name>oly_graphicsLanguage</name><value>$graphicsLanguage</value></field><field><name>$fieldName</name><value>$titleByLanguage</value></field><field><name>oly_graphicsType</name><value>$graphicsType</value></field></timespan></MetadataDocument>")

echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - Body Data - $bodyData" >> "$logfile"

#curl -s -o /dev/null --location --request PUT $url --header 'Content-Type: application/xml' --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=xZqBrKBPBOUANsWFnMC3aF90S52Ip3tgXdUHwWZvhNnu9aLl9j4rdrxRhV9nSQx9' --data $bodyData

sleep 5

echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - Metadata Update Completed" >> "$logfile"

IFS=$saveIFS