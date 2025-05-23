#!/bin/bash

#::***************************************************************************************************************************
#::This shell script will create the appropriate xmls for the content type, for Amazon delivery
#::Engineers: Ryan Sims & Tang Kanjanapitak
#::Client: Olympusat
#::Updated: 07/23/2024
#::Rev A: 
#::System requirements: This script will run in LINUX & MacOS
#::***************************************************************************************************************************

saveIFS=$IFS
IFS=$(echo -e "\n\b")

#--------------------------------------------------
# External funtions to include
. /opt/olympusat/scriptsLibrary/olympusatCantemo.lib
#--------------------------------------------------

# --------------------------------------------------
# Internal funtions

# Function to calculate the greatest common divisor (GCD)
gcd() {
    local a=$1
    local b=$2
    while [ $b -ne 0 ]; do
        local temp=$b
        b=$((a % b))
        a=$temp
    done
    echo $a
}

# Function to calculate aspect ratio
calculate_aspect_ratio() {
    local resolution=$1
    IFS='x' read -r width height <<< "$resolution"
    
    local divisor
    divisor=$(gcd "$width" "$height")
    
    local aspect_width=$((width / divisor))
    local aspect_height=$((height / divisor))
    
    echo "${aspect_width}x${aspect_height}"
}
# --------------------------------------------------

export mydate=$(date +%Y-%m-%d)
export datetime=$(date +%Y/%m/%d_%H:%M)
logfile="/opt/olympusat/logs/distributionWorkflow-$mydate.log"

# Set variables to check before continuing
export itemId=$1
export distributionTo=$2

echo "$(date +%Y/%m/%d_%H:%M:%S) - (distributionWorkflow) - ($itemId) - Create XMLs for Job Initiated" >> "$logfile"

sleep 1

# Check distributionTo Variable
if [[ "$distributionTo" == "amazon" ]];
then
    # distributionTo is 'amazon'-continue with script
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (distributionWorkflow) - ($itemId) - Create Amazon XMLs - Checking contentType" >> "$logfile"

    sleep 1

    itemContentType=$(filterVidispineItemMetadata $itemId "metadata" "oly_contentType")

    # Check if contentType is movie
    if [[ "$itemContentType" == "movie" ]];
    then
        # contentType is movie-continue with script
        itemTitle=$(filterVidispineItemMetadata $itemId "metadata" "title")
        echo "$(date +%Y/%m/%d_%H:%M:%S) - (distributionWorkflow) - ($itemId) - Check if MMC & MEC XMLs exist for [$itemContentType] [$itemTitle]" >> "$logfile"

        mmcFileDestination="/opt/olympusat/xmlsForDistribution/$distributionTo/MMC-$itemTitle.xml"
        mecFileDestination="/opt/olympusat/xmlsForDistribution/$distributionTo/MEC-$itemTitle.xml"
        mecFileDestinationArt="/opt/olympusat/xmlsForDistribution/$distributionTo/_miscFiles/ArtForMEC-$itemTitle.xml"
        mecFileDestinationGenre="/opt/olympusat/xmlsForDistribution/$distributionTo/_miscFiles/GenreForMEC-$itemTitle.xml"
        mecFileDestinationRating="/opt/olympusat/xmlsForDistribution/$distributionTo/_miscFiles/RatingForMEC-$itemTitle.xml"
        mecFileDestinationActor="/opt/olympusat/xmlsForDistribution/$distributionTo/_miscFiles/ActorForMEC-$itemTitle.xml"
        mecFileDestinationDirector="/opt/olympusat/xmlsForDistribution/$distributionTo/_miscFiles/DirectorForMEC-$itemTitle.xml"
        mecFileDestinationProducer="/opt/olympusat/xmlsForDistribution/$distributionTo/_miscFiles/ProducerForMEC-$itemTitle.xml"

        # Check to see if mmcFileDestination file exists
        if [[ -e "$mmcFileDestination" ]];
        then
            # mmcFileDestination file exists-deleting file before continuing
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (distributionWorkflow) - ($itemId) - mmcFileDestination file exists - moving file to zMoved folder before continuing with script" >> "$logfile"

            mv -f "$mmcFileDestination" "/opt/olympusat/xmlsForDistribution/zMoved/"

            sleep 1
        fi

        # Check to see if mecFileDestination file exists
        if [[ -e "$mecFileDestination" ]];
        then
            # mecFileDestination file exists-deleting file before continuing
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (distributionWorkflow) - ($itemId) - mecFileDestination file exists - moving file to zMoved folder before continuing with script" >> "$logfile"

            mv -f "$mecFileDestination" "/opt/olympusat/xmlsForDistribution/zMoved/"

            sleep 1
        fi

        # Check to see if mecFileDestinationArt file exists
        if [[ -e "$mecFileDestinationArt" ]];
        then
            # mecFileDestinationArt file exists-deleting file before continuing
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (distributionWorkflow) - ($itemId) - mecFileDestinationArt file exists - moving file to zMoved folder before continuing with script" >> "$logfile"

            mv -f "$mecFileDestinationArt" "/opt/olympusat/xmlsForDistribution/zMoved/"

            sleep 1
        fi
        
        # Check to see if mecFileDestinationGenre file exists
        if [[ -e "$mecFileDestinationGenre" ]];
        then
            # mecFileDestinationGenre file exists-deleting file before continuing
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (distributionWorkflow) - ($itemId) - mecFileDestinationGenre file exists - moving file to zMoved folder before continuing with script" >> "$logfile"

            mv -f "$mecFileDestinationGenre" "/opt/olympusat/xmlsForDistribution/zMoved/"

            sleep 1
        fi

        # Check to see if mecFileDestinationRating file exists
        if [[ -e "$mecFileDestinationRating" ]];
        then
            # mecFileDestinationRating file exists-deleting file before continuing
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (distributionWorkflow) - ($itemId) - mecFileDestinationRating file exists - moving file to zMoved folder before continuing with script" >> "$logfile"

            mv -f "$mecFileDestinationRating" "/opt/olympusat/xmlsForDistribution/zMoved/"

            sleep 1
        fi

        # Check to see if mecFileDestinationActor file exists
        if [[ -e "$mecFileDestinationActor" ]];
        then
            # mecFileDestinationActor file exists-deleting file before continuing
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (distributionWorkflow) - ($itemId) - mecFileDestinationActor file exists - moving file to zMoved folder before continuing with script" >> "$logfile"

            mv -f "$mecFileDestinationActor" "/opt/olympusat/xmlsForDistribution/zMoved/"

            sleep 1
        fi

        # Check to see if mecFileDestinationDirector file exists
        if [[ -e "$mecFileDestinationDirector" ]];
        then
            # mecFileDestinationDirector file exists-deleting file before continuing
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (distributionWorkflow) - ($itemId) - mecFileDestinationDirector file exists - moving file to zMoved folder before continuing with script" >> "$logfile"

            mv -f "$mecFileDestinationDirector" "/opt/olympusat/xmlsForDistribution/zMoved/"

            sleep 1
        fi

        # Check to see if mecFileDestinationProducer file exists
        if [[ -e "$mecFileDestinationProducer" ]];
        then
            # mecFileDestinationProducer file exists-deleting file before continuing
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (distributionWorkflow) - ($itemId) - mecFileDestinationProducer file exists - moving file to zMoved folder before continuing with script" >> "$logfile"

            mv -f "$mecFileDestinationProducer" "/opt/olympusat/xmlsForDistribution/zMoved/"

            sleep 1
        fi

        itemIdXml=$(echo $itemId | sed 's/-/_/g')
        itemOriginalFilename=$(filterVidispineItemMetadata $itemId "metadata" "originalFilename")
        itemDistributionLanguage=$(filterVidispineItemSubgroupMetadata $itemId "metadata" "oly_distributionLanguage" "Distribution")

        # Check distributionLangugae to create proper languageCode for XMLs
        if [[ "$itemDistributionLanguage" == "spanish" ]];
        then
            # distributionLanguage is spanish-continue with script
            export itemLanguageCode1="es-MX"
            export itemLanguageCode2="es"
            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (distributionWorkflow) - ($itemId) - Language Code - [$itemLanguageCode]" >> "$logfile"
        else
            if [[ "$itemDistributionLanguage" == "english" ]];
            then
                # distributionLanguage is english-continue with script
                export itemLanguageCode1="en-US"
                export itemLanguageCode2="en"
                #echo "$(date +%Y/%m/%d_%H:%M:%S) - (distributionWorkflow) - ($itemId) - Language Code - [$itemLanguageCode]" >> "$logfile"
            fi
        fi

        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (distributionWorkflow) - ($itemId) - Item Id Xml - [$itemIdXml]" >> "$logfile"
        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (distributionWorkflow) - ($itemId) - Title - [$itemTitle]" >> "$logfile"
        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (distributionWorkflow) - ($itemId) - Original Filename - [$itemOriginalFilename]" >> "$logfile"
        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (distributionWorkflow) - ($itemId) - Distribution Language - [$itemDistributionLanguage]" >> "$logfile"
        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (distributionWorkflow) - ($itemId) - Language Code 1 - [$itemLanguageCode1]" >> "$logfile"
        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (distributionWorkflow) - ($itemId) - Language Code 2 - [$itemLanguageCode2]" >> "$logfile"

        # ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        # Create MMC XML
        echo "$(date +%Y/%m/%d_%H:%M:%S) - (distributionWorkflow) - ($itemId) - Create MMC XML In Progress for [$itemTitle]" >> "$logfile"

        # Adding MediaManifest Block Start
        echo "<manifest:MediaManifest xmlns:manifest=\"http://www.movielabs.com/schema/manifest/v1.8/manifest\" xmlns:md=\"http://www.movielabs.com/schema/md/v2.7/md\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xsi:schemaLocation=\"http://www.movielabs.com/schema/manifest/v1.8/manifest manifest-v1.8.1.xsd\" ManifestID=\"SofaSpud.Example\" updateNum=\"1\">" >> "$mmcFileDestination"

        # Adding Compatibility Block
        echo "    <!-- script/ -->
    <manifest:Compatibility>
        <manifest:SpecVersion>1.5</manifest:SpecVersion>
        <manifest:Profile>MMC-1</manifest:Profile>
    </manifest:Compatibility>" >> "$mmcFileDestination"

        # Adding Inventory Block Start
        echo "    <manifest:Inventory>" >> "$mmcFileDestination"

        # Adding Audio Block in Inventory Block
        echo "        <!--  Main audio file for movie  -->
        <manifest:Audio AudioTrackID=\"md:audtrackid:org:olympusat:$itemIdXml:feature.audio.$itemLanguageCode2\">
            <md:Type>primary</md:Type>
            <md:Language>$itemLanguageCode1</md:Language>
            <manifest:ContainerReference>
                <manifest:ContainerLocation>$itemOriginalFilename</manifest:ContainerLocation>
            </manifest:ContainerReference>
        </manifest:Audio>" >> "$mmcFileDestination"

        # Adding Video Block in Inventory Block
        echo "        <manifest:Video VideoTrackID=\"md:vidtrackid:org:olympusat:$itemIdXml:feature.video\">
            <md:Type>primary</md:Type>
            <md:Picture></md:Picture>
            <manifest:ContainerReference>
                <manifest:ContainerLocation>$itemOriginalFilename</manifest:ContainerLocation>
            </manifest:ContainerReference>
        </manifest:Video>" >> "$mmcFileDestination"

        # Adding Metadata Block in Inventory Block
        echo "        <manifest:Metadata ContentID=\"md:cid:org:olympusat:$itemIdXml\">
            <manifest:ContainerReference type=\"common\">
                <manifest:ContainerLocation>MEC-$itemTitle.xml</manifest:ContainerLocation>
            </manifest:ContainerReference>
        </manifest:Metadata>" >> "$mmcFileDestination"

        # Adding Inventory Block Close
        echo "    </manifest:Inventory>" >> "$mmcFileDestination"

        # Adding Presentations Block Start
        echo "    <manifest:Presentations>" >> "$mmcFileDestination"

        # Adding Presentation Block in Presentations Block
        echo "        <!--   the main feature presentation   -->
        <manifest:Presentation PresentationID=\"md:presentationid:org:olympusat:$itemIdXml:feature.presentation\">
            <manifest:TrackMetadata>
                <manifest:TrackSelectionNumber>0</manifest:TrackSelectionNumber>
                <manifest:VideoTrackReference>
                    <manifest:VideoTrackID>md:vidtrackid:org:olympusat:$itemIdXml:feature.video</manifest:VideoTrackID>
                </manifest:VideoTrackReference>
                <manifest:AudioTrackReference>
                    <manifest:AudioTrackID>md:audtrackid:org:olympusat:$itemIdXml:feature.audio.$itemLanguageCode2</manifest:AudioTrackID>
                </manifest:AudioTrackReference>
                <!-- manifest:SubtitleTrackReference>
                <manifest:SubtitleTrackID>md:subtrackid:org:olympusat:$itemIdXml:feature.caption.en</manifest:SubtitleTrackID>
                </manifest:SubtitleTrackReference -->
            </manifest:TrackMetadata>
        </manifest:Presentation>" >> "$mmcFileDestination"

        # Adding Presentations Block Close
        echo "    </manifest:Presentations>" >> "$mmcFileDestination"

        # Adding Experiences Block Start
        echo "    <manifest:Experiences>" >> "$mmcFileDestination"

        # Adding Experience Block in Experiences Block
        echo "        <manifest:Experience ExperienceID=\"md:experienceid:org:olympusat:$itemIdXml:experience\" version=\"1.0\">
            <manifest:ContentID>md:cid:org:olympusat:$itemIdXml</manifest:ContentID>
            <manifest:Audiovisual ContentID=\"md:cid:org:olympusat:$itemIdXml\">
                <manifest:Type>Main</manifest:Type>
                <manifest:SubType>Feature</manifest:SubType>
                <manifest:PresentationID>md:presentationid:org:olympusat:$itemIdXml:feature.presentation</manifest:PresentationID>
            </manifest:Audiovisual>
            <manifest:PictureGroupID>md:picturegroupid:org:olympusat:$itemIdXml:feature</manifest:PictureGroupID>
            <!-- manifest:ExperienceChild>
                <manifest:Relationship>ispromotionfor</manifest:Relationship>
                <manifest:ExperienceID>md:experienceid:org:olympusat:$itemIdXml:trailer.1.experience</manifest:ExperienceID>
            </manifest:ExperienceChild -->
        </manifest:Experience>" >> "$mmcFileDestination"

        # Adding Experiences Block Close
        echo "    </manifest:Experiences>" >> "$mmcFileDestination"

        # Adding ALIDExperienceMaps Block
        echo "    <manifest:ALIDExperienceMaps>
        <manifest:ALIDExperienceMap>
            <manifest:ALID>md:alid:org:olympusat:$itemIdXml</manifest:ALID>
            <manifest:ExperienceID>md:experienceid:org:olympusat:$itemIdXml:experience</manifest:ExperienceID>
        </manifest:ALIDExperienceMap>
    </manifest:ALIDExperienceMaps>" >> "$mmcFileDestination"

        # Adding MediaManifest Block Close
        echo "</manifest:MediaManifest>" >> "$mmcFileDestination"

        sleep 2
        
        echo "$(date +%Y/%m/%d_%H:%M:%S) - (distributionWorkflow) - ($itemId) - Create MMC XML COMPLETED" >> "$logfile"

        sleep 2
        # ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        
        # ----------------------------------------------------------------------
        # Create MEC XML
        echo "$(date +%Y/%m/%d_%H:%M:%S) - (distributionWorkflow) - ($itemId) - Create MEC XML In Progress for [$itemTitle]" >> "$logfile"

        # Gathering metadata from Cantemo
        itemTitleEn=$(filterVidispineItemMetadata $itemId "metadata" "oly_titleEn")
        itemTitleEs=$(filterVidispineItemMetadata $itemId "metadata" "oly_titleEs")
        itemLogLineEn=$(filterVidispineItemSubgroupMetadata $itemId "metadata" "oly_logLineEn" "English%20Synopsis")
        itemShortDescriptionEn=$(filterVidispineItemSubgroupMetadata $itemId "metadata" "oly_shortDescriptionEn" "English%20Synopsis")
        itemDescriptionEn=$(filterVidispineItemSubgroupMetadata $itemId "metadata" "oly_descriptionEn" "English%20Synopsis")
        itemLogLineEs=$(filterVidispineItemSubgroupMetadata $itemId "metadata" "oly_logLineEs" "Spanish%20Synopsis")
        itemShortDescriptionEs=$(filterVidispineItemSubgroupMetadata $itemId "metadata" "oly_shortDescriptionEs" "Spanish%20Synopsis")
        itemDescriptionEs=$(filterVidispineItemSubgroupMetadata $itemId "metadata" "oly_descriptionEs" "Spanish%20Synopsis")
        itemProductionYear=$(filterVidispineItemMetadata $itemId "metadata" "oly_productionYear")


        # Adding XML Header
        echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" >> "$mecFileDestination"

        # Adding CoreMetadata Block Start
        echo "<mdmec:CoreMetadata xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"
 xsi:schemaLocation=\"http://www.movielabs.com/schema/mdmec/v2.9 ../mdmec-v2.9.xsd\"
 xmlns:md=\"http://www.movielabs.com/schema/md/v2.9/md\"
 xmlns:mdmec=\"http://www.movielabs.com/schema/mdmec/v2.9\">" >> "$mecFileDestination"

        # Adding Basic Block Start
        echo "    <mdmec:Basic ContentID=\"md:cid:org:olympusat:$itemIdXml\">" >> "$mecFileDestination"

        # Adding LocalizedInfo in English Block Start
        echo "        <md:LocalizedInfo language=\"en-US\">" >> "$mecFileDestination"

        # Preparing Related Image Resolutions for LocalizedInfo in English Block
        urlGetRelatedItems="http://10.1.1.34:8080/API/item/$itemId/relation"
	    httpResponseRelatedItems=$(curl --location --request GET $urlGetRelatedItems --header 'Accept: application/xml' --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=Tkb9vkSC8v4SceB8CHUyB3iaMPjvgoHrzhLrvo36agG3wqv0jHc7nsOtdTo9JEyM')

        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (distributionWorkflow) - ($itemId) - Related Items {$httpResponseRelatedItems}" >> "$logfile"

        relatedItemsCount=$(echo $httpResponseRelatedItems | awk -F '</relation>' '{print NF}')
        relatedItemsCount=$(($relatedItemsCount - 1))
        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (distributionWorkflow) - ($itemId) - Related Items Count {$relatedItemsCount}" >> "$logfile"

        #if [[ $relatedItemsCount -lt 6 ]];
        #then
        #    occurenceCount=$relatedItemsCount
        #else
        #    occurenceCount=6
        #fi

        ## Get related items and iterate through each to check cs_type is forDistribution & get target id
        for (( r=1 ; r<=$relatedItemsCount ; r++ ));
        do
            s=2
            currentRelationValue=$(echo "$httpResponseRelatedItems" | awk -F '</relation>' '{print $'$r'}' | awk -F '<relation>' '{print $'$s'}' )
            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (distributionWorkflow) - ($itemId) - Current Relation Value {$currentRelationValue}" >> "$logfile"

            currentRelationCsTypeValue=$(echo "$currentRelationValue" | awk -F '<value key="cs_type">' '{print $2}' | awk -F '</value>' '{print $1}')
            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (distributionWorkflow) - ($itemId) - Current Relation Cs Type Value {$currentRelationCsTypeValue}" >> "$logfile"

            if [[ "$currentRelationCsTypeValue" == "forDistribution" ]];
            then
                #echo "$(date +%Y/%m/%d_%H:%M:%S) - (distributionWorkflow) - ($itemId) - Relation Type is forDistribution - Getting Target Id" >> "$logfile"
                currentTargetIdValue=$(echo "$currentRelationValue" | awk -F '<target>' '{print $2}' | awk -F '</target>' '{print $1}')
                #echo "$(date +%Y/%m/%d_%H:%M:%S) - (distributionWorkflow) - ($itemId) - Target Id {$currentTargetIdValue}" >> "$logfile"

                relatedItemType=$(filterVidispineItemMetadata $currentTargetIdValue "metadata" "oly_graphicsType")
                relatedItemResolution=$(filterVidispineItemMetadata $currentTargetIdValue "metadata" "oly_graphicsResolution")
                
                # Calculate aspect ratio
                aspectRatio=$(calculate_aspect_ratio "$relatedItemResolution")
                #echo "Aspect Ratio - $aspectRatio"
                
                #echo "$(date +%Y/%m/%d_%H:%M:%S) - (distributionWorkflow) - ($itemId) - {$currentTargetIdValue} Type [$relatedItemType]" >> "$logfile"
                #echo "$(date +%Y/%m/%d_%H:%M:%S) - (distributionWorkflow) - ($itemId) - {$currentTargetIdValue} Resolution [$relatedItemResolution]" >> "$logfile"
                #echo "$(date +%Y/%m/%d_%H:%M:%S) - (distributionWorkflow) - ($itemId) - {$currentTargetIdValue} Aspect Ratio [$aspectRatio]" >> "$logfile"

                if [[ "$relatedItemType" == "cover" && "$aspectRatio" == "16x9" ]];
                then
                    echo "            <md:ArtReference resolution=\"$relatedItemResolution\" purpose=\"cover\">$itemTitle-cover-16x9.jpg</md:ArtReference>" >> "$mecFileDestinationArt"
                elif [[ "$relatedItemType" == "cover" && "$aspectRatio" == "3x4" ]];
                then
                    echo "            <md:ArtReference resolution=\"$relatedItemResolution\" purpose=\"boxart\">$itemTitle-box-3x4.jpg</md:ArtReference>" >> "$mecFileDestinationArt"
                elif [[ "$relatedItemType" == "feature" && "$aspectRatio" == "16x9" ]];
                then
                    echo "            <md:ArtReference resolution=\"$relatedItemResolution\" purpose=\"hero\">$itemTitle-hero-16x9.jpg</md:ArtReference>" >> "$mecFileDestinationArt"
                fi
            fi
            
        done
        
        # Adding LocalizedInfo in English Block - Title
		echo "            <!-- TitleDisplayUnlimited is required by Amazon. Limited to 250 characters. -->
			<md:TitleDisplayUnlimited>$itemTitleEn</md:TitleDisplayUnlimited>
			<!-- TitleSort is required by the MEC XSD, but is not used by Amazon. Blank fields such as below are acceptable.  -->
			<md:TitleSort></md:TitleSort>" >> "$mecFileDestination"
        
        # Adding LocalizedInfo in English Block - ArtReference
        cat "$mecFileDestinationArt" >> "$mecFileDestination"

        # Adding LocalizedInfo in English Block - Summaries
		echo "            <!-- Summary190 is required by the MEC XSD, but is not required by Amazon. Blank fields such as below are acceptable.  -->
			<md:Summary190>$itemLogLineEn</md:Summary190>
			<!-- Summary400 is required by Amazon -->
			<md:Summary400>$itemShortDescriptionEn</md:Summary400>
			<md:Summary4000>$itemDescriptionEn</md:Summary4000>" >> "$mecFileDestination"

        # Preparing Genre Info for LocalizedInfo in English Block
        itemPrimaryGenre=$(filterVidispineItemMetadata $itemId "metadata" "oly_primaryGenre")

        urlGetItemSecondaryGenres="http://10.1.1.34:8080/API/item/$itemId/metadata?field=oly_secondaryGenres&terse=yes"
	    httpResponseSecondaryGenres=$(curl --location --request GET $urlGetItemSecondaryGenres  --header 'Accept: application/xml' --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=Tkb9vkSC8v4SceB8CHUyB3iaMPjvgoHrzhLrvo36agG3wqv0jHc7nsOtdTo9JEyM')

        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (distributionWorkflow) - ($itemId) - Primary Genre {$itemPrimaryGenre}" >> "$logfile"
        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (distributionWorkflow) - ($itemId) - Secondary Genres {$httpResponseSecondaryGenres}" >> "$logfile"

        subGenreItemCount=$(echo $httpResponseSecondaryGenres | awk -F '</oly_secondaryGenres>' '{print NF}')
        subGenreItemCount=$(($subGenreItemCount - 1))
        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (distributionWorkflow) - ($itemId) - SubGenre Item Count {$subGenreItemCount}" >> "$logfile"

        if [[ $subGenreItemCount -lt 2 ]];
        then
            occurenceCount=$subGenreItemCount
        else
            occurenceCount=2
        fi

        ## Get item's primary genre and add information into genre xml
        case "$itemPrimaryGenre" in
            "action")
                echo "            <md:Genre id=\"av_genre_action\"></md:Genre>" >> "$mecFileDestinationGenre"
            ;;
            "adventure")
                echo "            <md:Genre id=\"av_genre_adventure\"></md:Genre>" >> "$mecFileDestinationGenre"
            ;;
            "comedy")
                echo "            <md:Genre id=\"av_genre_comedy\"></md:Genre>" >> "$mecFileDestinationGenre"
            ;;
            *)
                # Do nothing for now - might add logging later
            ;;
        esac

        ## Get item's secondary genres and iterate through each and add information into genre xml with appropriate genre/subgenre for Amazon
        for (( j=1 ; j<=$occurenceCount ; j++ ));
        do
            if [[ $j -eq 1 ]];
            then
                k=3
            else
                k=2
            fi
            currentValue=$(echo "$httpResponseSecondaryGenres" | awk -F '</oly_secondaryGenres>' '{print $'$j'}' | awk -F '/vidispine">' '{print $'$k'}' )
            
            case "$currentValue" in
                "adventure")
                    case "$itemPrimaryGenre" in
                        "action")
                            echo "            <md:Genre id=\"av_subgenre_action_adventure\"></md:Genre>" >> "$mecFileDestinationGenre"
                        ;;
                    esac
                ;;
                "comedy")
                    case "$itemPrimaryGenre" in
                        "action")
                            echo "            <md:Genre id=\"av_subgenre_action_comedy\"></md:Genre>" >> "$mecFileDestinationGenre"
                        ;;
                    esac
                ;;
                "crime")
                    case "$itemPrimaryGenre" in
                        "action")
                            echo "            <md:Genre id=\"av_subgenre_action_crime\"></md:Genre>" >> "$mecFileDestinationGenre"
                        ;;
                    esac
                ;;
                "romance")
                    case "$itemPrimaryGenre" in
                        "action")
                            echo "            <md:Genre id=\"av_subgenre_action_romance\"></md:Genre>" >> "$mecFileDestinationGenre"
                        ;;
                    esac
                ;;
                *)
                    # Do nothing for now - might add logging later
                ;;
            esac
        done
        
        # Adding LocalizedInfo in English Block - Genre
		echo "            <!-- Genres must be submitted using the AV Genre codes, such as below. -->
			<!-- Genres may be provided in just one, or all LocalizedInfo blocks. See the spec documentation for more detail. -->
			<!-- At least 1 genre is required. Up to 3 genres are allowed. -->" >> "$mecFileDestination"
		cat "$mecFileDestinationGenre" >> "$mecFileDestination"

		# Adding LocalizedInfo in English Block Close
        echo "        </md:LocalizedInfo>" >> "$mecFileDestination"

        # Adding LocalizedInfo in Spanish Block Start
        echo "        <md:LocalizedInfo language=\"es-MX\">" >> "$mecFileDestination"

        # Adding LocalizedInfo in Spanish Block
        echo "            <md:TitleDisplayUnlimited>$itemTitleEs</md:TitleDisplayUnlimited>
			<md:TitleSort></md:TitleSort>
			<md:Summary190>$itemLogLineEs</md:Summary190>
			<md:Summary400>$itemShortDescriptionEs</md:Summary400>
			<md:Summary4000>$itemDescriptionEs</md:Summary4000>" >> "$mecFileDestination"

        # Adding LocalizedInfo in Spanish Block Close
        echo "        </md:LocalizedInfo>" >> "$mecFileDestination"

        # Adding ReleaseYear & ReleaseDate Block
        echo "        <md:ReleaseYear>$itemProductionYear</md:ReleaseYear>
		<md:ReleaseDate>$itemProductionYear-01-01</md:ReleaseDate>" >> "$mecFileDestination"

        # Adding ReleaseHistory Block Start
        echo "        <!-- Provide as much release history as possible.  -->
		<md:ReleaseHistory>" >> "$mecFileDestination"

        # Adding ReleaseType
        # Checking if itemContentType is movie or episode to set the proper ReleaseType
        if [[ "$itemContentType" == "movie" ]];
        then
            echo "            <md:ReleaseType>Theatrical</md:ReleaseType>" >> "$mecFileDestination"
        elif [[ "$itemContentType" == "episode" ]];
        then
            echo "            <md:ReleaseType>SVOD</md:ReleaseType>" >> "$mecFileDestination"
        fi

        # Adding ReleaseHistory Remaining Block
        itemCountryOfOrigin=$(filterVidispineItemMetadata $itemId "metadata" "oly_countryOfOrigin")
        case "$itemCountryOfOrigin" in
            "mexico")
                itemCountryOfOriginCode="MX"
            ;;
            "unitedStates"|"unitedStatesOfAmerica")
                itemCountryOfOriginCode="US"
            ;;
        esac
        echo "            <md:DistrTerritory>
				<md:country>$itemCountryOfOriginCode</md:country>
			</md:DistrTerritory>
			<md:Date>$itemProductionYear-01-01</md:Date>" >> "$mecFileDestination"

        # Adding ReleaseHistory Block Close
        echo "        </md:ReleaseHistory>" >> "$mecFileDestination"

        # Adding WorkType Block
        echo "        <!-- WorkType is Required -->
		<md:WorkType>$itemContentType</md:WorkType>" >> "$mecFileDestination"

        # Adding AltIdentifier Block
        echo "        <!-- The ID used in the MMC and in the Avail must also be included in the AltIdentifier section -->
		<md:AltIdentifier>
			<md:Namespace>ORG</md:Namespace>
			<md:Identifier>$itemIdXml</md:Identifier>
		</md:AltIdentifier>
		<!-- md:AltIdentifier>
			<md:Namespace>IMDB</md:Namespace>
			<md:Identifier>tt4518590</md:Identifier>
		</md:AltIdentifier -->" >> "$mecFileDestination"

        # Adding RatingSet Block Start
        echo "        <md:RatingSet>
			<!-- each rating specifies exactly one country, system and value -->
			<!-- At least one rating is required. If the work is not rated, use <md:notrated>true</md:notrated>  -->
			<!-- see http://www.movielabs.com/md/ratings/current.html for ratings -->" >> "$mecFileDestination"

        # Preparing Rating Block
        itemOriginalMpaaRating=$(filterVidispineItemMetadata $itemId "metadata" "oly_originalMpaaRating")
        case "$itemOriginalMpaaRating" in
            "g")
                echo "            <md:Rating>
				<md:Region>
					<md:country>US</md:country>
				</md:Region>
				<md:System>MPAA</md:System>
				<md:Value>G</md:Value>
			</md:Rating>" >> "$mecFileDestinationRating"
            ;;
            "nc-17")
                echo "            <md:Rating>
				<md:Region>
					<md:country>US</md:country>
				</md:Region>
				<md:System>MPAA</md:System>
				<md:Value>NC-17</md:Value>
			</md:Rating>" >> "$mecFileDestinationRating"
            ;;
            "pg")
                echo "            <md:Rating>
				<md:Region>
					<md:country>US</md:country>
				</md:Region>
				<md:System>MPAA</md:System>
				<md:Value>PG</md:Value>
			</md:Rating>" >> "$mecFileDestinationRating"
            ;;
            "pg-13")
                echo "            <md:Rating>
				<md:Region>
					<md:country>US</md:country>
				</md:Region>
				<md:System>MPAA</md:System>
				<md:Value>PG-13</md:Value>
			</md:Rating>" >> "$mecFileDestinationRating"
            ;;
            "r")
                echo "            <md:Rating>
				<md:Region>
					<md:country>US</md:country>
				</md:Region>
				<md:System>MPAA</md:System>
				<md:Value>R</md:Value>
			</md:Rating>" >> "$mecFileDestinationRating"
            ;;
            "notRated")
                echo "            <md:Rating>
				<md:Region>
					<md:country>US</md:country>
				</md:Region>
				<md:System>MPAA</md:System>
				<md:NotRated>true</md:NotRated>
			</md:Rating>" >> "$mecFileDestinationRating"

                itemOriginalRating=$(filterVidispineItemMetadata $itemId "metadata" "oly_originalRating")
                case "$itemOriginalRating" in
                    "tv-14")
                        echo "            <md:Rating>
				<md:Region>
					<md:country>US</md:country>
				</md:Region>
				<md:System>TVPG</md:System>
				<md:Value>TV-14</md:Value>
			</md:Rating>" >> "$mecFileDestinationRating"
                    ;;
                    "tv-g")
                        echo "            <md:Rating>
				<md:Region>
					<md:country>US</md:country>
				</md:Region>
				<md:System>TVPG</md:System>
				<md:Value>TV-G</md:Value>
			</md:Rating>" >> "$mecFileDestinationRating"
                    ;;
                    "tv-ma")
                        echo "            <md:Rating>
				<md:Region>
					<md:country>US</md:country>
				</md:Region>
				<md:System>TVPG</md:System>
				<md:Value>TV-MA</md:Value>
			</md:Rating>" >> "$mecFileDestinationRating"
                    ;;
                    "tv-nr")
                        echo "            <md:Rating>
				<md:Region>
					<md:country>US</md:country>
				</md:Region>
				<md:System>TVPG</md:System>
				<md:NotRated>true</md:NotRated>
			</md:Rating>" >> "$mecFileDestinationRating"
                    ;;
                    "tv-pg")
                        echo "            <md:Rating>
				<md:Region>
					<md:country>US</md:country>
				</md:Region>
				<md:System>TVPG</md:System>
				<md:Value>TV-PG</md:Value>
			</md:Rating>" >> "$mecFileDestinationRating"
                    ;;
                    "tv-y")
                        echo "            <md:Rating>
				<md:Region>
					<md:country>US</md:country>
				</md:Region>
				<md:System>TVPG</md:System>
				<md:Value>TV-Y</md:Value>
			</md:Rating>" >> "$mecFileDestinationRating"
                    ;;
                    *)
                        echo "$(date +%Y/%m/%d_%H:%M:%S) - (distributionWorkflow) - ($itemId) - Episode Does NOT have Original Rating Set in Cantemo" >> "$logfile"
                    ;;
                esac
            ;;
            *)
                echo "$(date +%Y/%m/%d_%H:%M:%S) - (distributionWorkflow) - ($itemId) - Movie Does NOT have MPAA Rating Set in Cantemo" >> "$logfile"
            ;;
        esac

        # Adding Rating Block
        cat "$mecFileDestinationRating" >> "$mecFileDestination"
        
        # Adding RatingSet Block Close
        echo "        </md:RatingSet>" >> "$mecFileDestination"

        # Adding People Block Start
        echo "        <!-- people are used for the cast and crew.  -->" >> "$mecFileDestination"
        
        # Preparing Cast Info for People - Actor Block
        urlGetItemCast="http://10.1.1.34:8080/API/item/$itemId/metadata?field=oly_cast&terse=yes"
	    httpResponseCast=$(curl --location --request GET $urlGetItemCast --header 'Accept: application/xml' --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=Tkb9vkSC8v4SceB8CHUyB3iaMPjvgoHrzhLrvo36agG3wqv0jHc7nsOtdTo9JEyM')

        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (distributionWorkflow) - ($itemId) - Cast {$httpResponseCast}" >> "$logfile"

        castItemCount=$(echo $httpResponseCast | awk -F '</oly_cast>' '{print NF}')
        castItemCount=$(($castItemCount - 1))
        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (distributionWorkflow) - ($itemId) - Cast Item Count {$castItemCount}" >> "$logfile"

        if [[ $castItemCount -lt 6 ]];
        then
            occurenceCount=$castItemCount
        else
            occurenceCount=6
        fi

        ## Get item's cast metadata and iterate through each and add information into actor xml with people-actor for Amazon
        for (( l=1 ; l<=$occurenceCount ; l++ ));
        do
            if [[ $l -eq 1 ]];
            then
                m=3
            else
                m=2
            fi
            currentValue=$(echo "$httpResponseCast" | awk -F '</oly_cast>' '{print $'$l'}' | awk -F '/vidispine">' '{print $'$m'}' )
            
            echo "        <md:People>
			<md:Job>
				<md:JobFunction>Actor</md:JobFunction>
				<md:BillingBlockOrder>$l</md:BillingBlockOrder>
			</md:Job>
			<md:Name>
				<md:DisplayName language=\"en-US\">$currentValue</md:DisplayName>
				<md:DisplayName language=\"es-MX\">$currentValue</md:DisplayName>
			</md:Name>
		</md:People>" >> "$mecFileDestinationActor"
        done

        # Preparing Director Info for People - Director Block
        urlGetItemDirector="http://10.1.1.34:8080/API/item/$itemId/metadata?field=oly_director&terse=yes"
	    httpResponseDirector=$(curl --location --request GET $urlGetItemDirector  --header 'Accept: application/xml' --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=Tkb9vkSC8v4SceB8CHUyB3iaMPjvgoHrzhLrvo36agG3wqv0jHc7nsOtdTo9JEyM')

        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (distributionWorkflow) - ($itemId) - Director {$httpResponseDirector}" >> "$logfile"

        directorItemCount=$(echo $httpResponseDirector | awk -F '</oly_director>' '{print NF}')
        directorItemCount=$(($directorItemCount - 1))
        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (distributionWorkflow) - ($itemId) - Director Item Count {$directorItemCount}" >> "$logfile"

        if [[ $directorItemCount -lt 3 ]];
        then
            occurenceCount=$directorItemCount
        else
            occurenceCount=3
        fi

        ## Get item's director metadata and iterate through each and add information into director xml with people-director for Amazon
        for (( n=1 ; n<=$occurenceCount ; n++ ));
        do
            if [[ $n -eq 1 ]];
            then
                o=3
            else
                o=2
            fi
            currentValue=$(echo "$httpResponseDirector" | awk -F '</oly_director>' '{print $'$n'}' | awk -F '/vidispine">' '{print $'$o'}' )
            #echo "$currentValue"
            
            echo "        <md:People>
			<md:Job>
				<md:JobFunction>Director</md:JobFunction>
				<md:BillingBlockOrder>$n</md:BillingBlockOrder>
			</md:Job>
			<md:Name>
				<md:DisplayName language=\"en-US\">$currentValue</md:DisplayName>
				<md:DisplayName language=\"es-MX\">$currentValue</md:DisplayName>
			</md:Name>
		</md:People>" >> "$mecFileDestinationDirector"
        done

        # Preparing Producer Info for People - Producer Block
        urlGetItemProducer="http://10.1.1.34:8080/API/item/$itemId/metadata?field=oly_producer&terse=yes"
	    httpResponseProducer=$(curl --location --request GET $urlGetItemProducer  --header 'Accept: application/xml' --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=Tkb9vkSC8v4SceB8CHUyB3iaMPjvgoHrzhLrvo36agG3wqv0jHc7nsOtdTo9JEyM')

        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (distributionWorkflow) - ($itemId) - Producer {$httpResponseProducer}" >> "$logfile"

        producerItemCount=$(echo $httpResponseProducer | awk -F '</oly_producer>' '{print NF}')
        producerItemCount=$(($producerItemCount - 1))
        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (distributionWorkflow) - ($itemId) - Producer Item Count {$producerItemCount}" >> "$logfile"

        if [[ $producerItemCount -lt 3 ]];
        then
            occurenceCount=$producerItemCount
        else
            occurenceCount=3
        fi

        ## Get item's producer metadata and iterate through each and add information into producer xml with people-producer for Amazon
        for (( p=1 ; p<=$occurenceCount ; p++ ));
        do
            if [[ $p -eq 1 ]];
            then
                q=3
            else
                q=2
            fi
            currentValue=$(echo "$httpResponseProducer" | awk -F '</oly_producer>' '{print $'$p'}' | awk -F '/vidispine">' '{print $'$q'}' )
            #echo "$currentValue"
            
            echo "        <md:People>
			<md:Job>
				<md:JobFunction>Producer</md:JobFunction>
				<md:BillingBlockOrder>$p</md:BillingBlockOrder>
			</md:Job>
			<md:Name>
				<md:DisplayName language=\"en-US\">$currentValue</md:DisplayName>
				<md:DisplayName language=\"es-MX\">$currentValue</md:DisplayName>
			</md:Name>
		</md:People>" >> "$mecFileDestinationProducer"
        done

        # Adding People Actor, Director and Producer Blocks to People Block
        cat "$mecFileDestinationActor" >> "$mecFileDestination"
        cat "$mecFileDestinationDirector" >> "$mecFileDestination"
        cat "$mecFileDestinationProducer" >> "$mecFileDestination"

        # Adding OriginalLanguage Block
        itemOriginalLanguage=$(filterVidispineItemSubgroupMetadata $itemId "metadata" "oly_originalLanguage")

        # Check originalLangugae to create proper originalLanguageCode for XMLs
        case "$itemOriginalLanguage" in
            "spanish")
                export itemOriginalLanguageCode="es-MX"
            ;;
            "english")
                export itemOriginalLanguageCode="en-US"
            ;;
        esac
        echo "        <!-- OriginalLanguage is required by Amazon -->
		<md:OriginalLanguage>$itemOriginalLanguageCode</md:OriginalLanguage>" >> "$mecFileDestination"

        # Adding AssociatedOrg Block
        echo "        <!-- AssociatedOrg is used to provide the Partner Alias and is required -->
		<!-- Include the Partner Alias value in the @organizationID attribute and the value of "licensor" in the @role attribute -->
		<md:AssociatedOrg organizationID=\"olympusat\" role=\"licensor\"></md:AssociatedOrg>" >> "$mecFileDestination"

        # Adding Basic Block Close
        echo "    </mdmec:Basic>" >> "$mecFileDestination"

        # Adding CompanyDisplayCredit Block
        echo "    <!-- CompanyDisplayCredit is used to provide customer-facing studio credits. Required. -->
	<mdmec:CompanyDisplayCredit>
		<md:DisplayString language=\"en-US\">Olympusat</md:DisplayString>
	</mdmec:CompanyDisplayCredit>" >> "$mecFileDestination"

        # Adding CoreMetadata Block Close
        echo "</mdmec:CoreMetadata>" >> "$mecFileDestination"

        sleep 2
        
        echo "$(date +%Y/%m/%d_%H:%M:%S) - (distributionWorkflow) - ($itemId) - Create MEC XML COMPLETED" >> "$logfile"

        # ----------------------------------------------------------------------

    else
        # contentType is NOT supported-exiting script
        echo "$(date +%Y/%m/%d_%H:%M:%S) - (distributionWorkflow) - ($itemId) - Content Type NOT Supported - exiting script" >> "$logfile"
    fi

else
    # distributionTo NOT supported-exiting script
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (distributionWorkflow) - ($itemId) - Distribution To NOT Supported - exiting script" >> "$logfile"
fi

IFS=$saveIFS
