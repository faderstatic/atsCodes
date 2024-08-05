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
# Start process
echo "$(date +%Y/%m/%d_%H:%M:%S) - (distributionWorkflow) - ($itemId) - Create XMLs for Job Initiated" >> "$logfile"
sleep 1
# Check distributionTo Variable
if [[ "$distributionTo" == "amazon" ]];
then
    # distributionTo is 'amazon'-continue with script
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (distributionWorkflow) - ($itemId) - Create Amazon XMLs - Checking contentType" >> "$logfile"
    sleep 1
    itemContentType=$(filterVidispineItemMetadata $itemId "metadata" "oly_contentType")
    itemContentTypeOriginal=$(echo "$itemContentType")
    # Check if contentType is movie or episode
    if [[ "$itemContentType" == "movie" || "$itemContentType" == "episode" ]];
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
        else
            if [[ "$itemDistributionLanguage" == "english" ]];
            then
                # distributionLanguage is english-continue with script
                export itemLanguageCode1="en-US"
                export itemLanguageCode2="en"
            fi
        fi

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
        # Check to see if mmcFileDestination file exists
        if [[ -e "$mmcFileDestination" ]];
        then
            # mmcFileDestination file exists-moving to volumes/creative/cs13/distribution/amazon_staging/metadata folder
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (distributionWorkflow) - ($itemId) - Moving MMC File to creative Volume" >> "$logfile"
            mv -f "$mmcFileDestination" "/Volumes/creative/CS13/Distribution/Amazon_Staging/metadata/"
            sleep 2
        fi
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
        relatedItemsCount=$(echo $httpResponseRelatedItems | awk -F '</relation>' '{print NF}')
        relatedItemsCount=$(($relatedItemsCount - 1))
        ## Get related items and iterate through each to check cs_type is forDistribution & get target id
        for (( a=1 ; a<=$relatedItemsCount ; a++ ));
        do
            b=2
            currentRelationValue=$(echo "$httpResponseRelatedItems" | awk -F '</relation>' '{print $'$a'}' | awk -F '<relation>' '{print $'$b'}' )
            currentRelationCsTypeValue=$(echo "$currentRelationValue" | awk -F '<value key="cs_type">' '{print $2}' | awk -F '</value>' '{print $1}')
            if [[ "$currentRelationCsTypeValue" == "forDistribution" ]];
            then
                currentTargetIdValue=$(echo "$currentRelationValue" | awk -F '<target>' '{print $2}' | awk -F '</target>' '{print $1}')
                relatedItemType=$(filterVidispineItemMetadata $currentTargetIdValue "metadata" "oly_graphicsType")
                relatedItemResolution=$(filterVidispineItemMetadata $currentTargetIdValue "metadata" "oly_graphicsResolution")
                # Calculate aspect ratio
                aspectRatio=$(calculate_aspect_ratio "$relatedItemResolution")
                if [[ "$itemContentType" == "movie" ]];
                then
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
                elif [[ "$itemContentType" == "episode" ]];
                then
                    if [[ "$relatedItemType" == "still" && "$aspectRatio" == "16x9" ]];
                    then
                        echo "            <md:ArtReference resolution=\"$relatedItemResolution\" purpose=\"cover\">$itemTitle-episodic-16x9.jpg</md:ArtReference>" >> "$mecFileDestinationArt"
                    fi
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
        itemAmazonPrimaryGenre=$(filterVidispineItemMetadata $itemId "metadata" "oly_amazonPrimaryGenre")
        urlGetItemAmazonSecondaryGenres="http://10.1.1.34:8080/API/item/$itemId/metadata?field=oly_amazonSecondaryGenres&terse=yes"
	    httpResponseAmazonSecondaryGenres=$(curl --location --request GET $urlGetItemAmazonSecondaryGenres  --header 'Accept: application/xml' --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=Tkb9vkSC8v4SceB8CHUyB3iaMPjvgoHrzhLrvo36agG3wqv0jHc7nsOtdTo9JEyM')
        echo "$(date +%Y/%m/%d_%H:%M:%S) - (distributionWorkflow) - ($itemId) - Secondary Genres [$httpResponseAmazonSecondaryGenres]" >> "$logfile"
        subGenreItemCount=$(echo $httpResponseAmazonSecondaryGenres | awk -F '</oly_amazonSecondaryGenres>' '{print NF}')
        subGenreItemCount=$(($subGenreItemCount - 1))
        echo "$(date +%Y/%m/%d_%H:%M:%S) - (distributionWorkflow) - ($itemId) - subGenreItemCount - [$subGenreItemCount]" >> "$logfile"
        if [[ $subGenreItemCount -lt 2 ]];
        then
            occurenceCount=$subGenreItemCount
        else
            occurenceCount=2
        fi
        ## Get item's primary genre and add information into genre xml
        echo "            <md:Genre id=\"$itemAmazonPrimaryGenre\"></md:Genre>" >> "$mecFileDestinationGenre"
        ## Get item's secondary genres and iterate through each and add information into genre xml with appropriate genre/subgenre for Amazon
        for (( c=1 ; c<=$occurenceCount ; c++ ));
        do
            if [[ $c -eq 1 ]];
            then
                d=3
            else
                d=2
            fi
            #k=2
            currentValue=$(echo "$httpResponseAmazonSecondaryGenres" | awk -F '</oly_amazonSecondaryGenres>' '{print $'$c'}' | awk -F '/vidispine">' '{print $'$d'}' )
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (distributionWorkflow) - ($itemId) - currentValue - [$currentValue]" >> "$logfile"
            echo "            <md:Genre id=\"$currentValue\"></md:Genre>" >> "$mecFileDestinationGenre"
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
            itemOriginalReleaseType=$(filterVidispineItemMetadata $itemId "metadata" "oly_originalReleaseType")
            if [[ "$itemOriginalReleaseType" == "theatrical" ]];
            then
                echo "            <md:ReleaseType>Theatrical</md:ReleaseType>" >> "$mecFileDestination"
            elif [[ "$itemOriginalReleaseType" == "svod" ]];
            then
                echo "            <md:ReleaseType>SVOD</md:ReleaseType>" >> "$mecFileDestination"
            elif [[ "$itemOriginalReleaseType" == "" ]];
            then
                itemOriginalMpaaRating=$(filterVidispineItemMetadata $itemId "metadata" "oly_originalMpaaRating")
                if [[ "$itemOriginalMpaaRating" == "notRated" || "$itemOriginalMpaaRating" == "" ]];
                then
                    echo "            <md:ReleaseType>SVOD</md:ReleaseType>" >> "$mecFileDestination"
                else
                    echo "            <md:ReleaseType>Theatrical</md:ReleaseType>" >> "$mecFileDestination"
                    itemOriginalReleaseType="theatrical"
                fi
            fi
        elif [[ "$itemContentType" == "episode" ]];
        then
            echo "            <md:ReleaseType>SVOD</md:ReleaseType>" >> "$mecFileDestination"
        fi
        # Adding ReleaseHistory Remaining Block
        echo "            <md:DistrTerritory>
				<md:country>US</md:country>
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
        if [[ "$itemContentType" == "movie" ]];
        then
            if [[ "$itemOriginalReleaseType" == "theatrical" ]];
            then
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
                        echo "            <md:NotRated>true</md:NotRated>" >> "$mecFileDestinationRating"
                    ;;
                    *)
                        echo "$(date +%Y/%m/%d_%H:%M:%S) - (distributionWorkflow) - ($itemId) - Movie Does NOT have MPAA Rating Set in Cantemo-setting as Not Rated in XML" >> "$logfile"
                        echo "            <md:NotRated>true</md:NotRated>" >> "$mecFileDestinationRating"
                    ;;
                esac
            elif [[ "$itemOriginalReleaseType" == "svod" || "$itemOriginalReleaseType" == "" ]];
            then
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
                        #echo "            <md:NotRated>true</md:NotRated>" >> "$mecFileDestinationRating"
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
                        echo "$(date +%Y/%m/%d_%H:%M:%S) - (distributionWorkflow) - ($itemId) - Episode Does NOT have Original Rating Set in Cantemo-setting as Not Rated in XML" >> "$logfile"
                        echo "            <md:NotRated>true</md:NotRated>" >> "$mecFileDestinationRating"
                    ;;
                esac
            fi
        else
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
        fi
        # Adding Rating Block
        cat "$mecFileDestinationRating" >> "$mecFileDestination"
        # Adding RatingSet Block Close
        echo "        </md:RatingSet>" >> "$mecFileDestination"
        # Adding People Block Start
        echo "        <!-- people are used for the cast and crew.  -->" >> "$mecFileDestination"        
        # Preparing Cast Info for People - Actor Block
        urlGetItemCast="http://10.1.1.34:8080/API/item/$itemId/metadata?field=oly_cast&terse=yes"
	    httpResponseCast=$(curl --location --request GET $urlGetItemCast --header 'Accept: application/xml' --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=Tkb9vkSC8v4SceB8CHUyB3iaMPjvgoHrzhLrvo36agG3wqv0jHc7nsOtdTo9JEyM')
        castItemCount=$(echo $httpResponseCast | awk -F '</oly_cast>' '{print NF}')
        castItemCount=$(($castItemCount - 1))
        if [[ $castItemCount -lt 6 ]];
        then
            occurenceCount=$castItemCount
        else
            occurenceCount=6
        fi
        ## Get item's cast metadata and iterate through each and add information into actor xml with people-actor for Amazon
        for (( e=1 ; e<=$occurenceCount ; e++ ));
        do
            if [[ $e -eq 1 ]];
            then
                f=3
            else
                f=2
            fi
            currentValue=$(echo "$httpResponseCast" | awk -F '</oly_cast>' '{print $'$e'}' | awk -F '/vidispine">' '{print $'$f'}' )
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
        directorItemCount=$(echo $httpResponseDirector | awk -F '</oly_director>' '{print NF}')
        directorItemCount=$(($directorItemCount - 1))
        if [[ $directorItemCount -lt 3 ]];
        then
            occurenceCount=$directorItemCount
        else
            occurenceCount=3
        fi
        ## Get item's director metadata and iterate through each and add information into director xml with people-director for Amazon
        for (( g=1 ; g<=$occurenceCount ; g++ ));
        do
            if [[ $g -eq 1 ]];
            then
                h=3
            else
                h=2
            fi
            currentValue=$(echo "$httpResponseDirector" | awk -F '</oly_director>' '{print $'$g'}' | awk -F '/vidispine">' '{print $'$h'}' )
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
        producerItemCount=$(echo $httpResponseProducer | awk -F '</oly_producer>' '{print NF}')
        producerItemCount=$(($producerItemCount - 1))
        if [[ $producerItemCount -lt 3 ]];
        then
            occurenceCount=$producerItemCount
        else
            occurenceCount=3
        fi
        ## Get item's producer metadata and iterate through each and add information into producer xml with people-producer for Amazon
        for (( i=1 ; i<=$occurenceCount ; i++ ));
        do
            if [[ $i -eq 1 ]];
            then
                j=3
            else
                j=2
            fi
            currentValue=$(echo "$httpResponseProducer" | awk -F '</oly_producer>' '{print $'$i'}' | awk -F '/vidispine">' '{print $'$j'}' )
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
        itemCountryOfOrigin=$(filterVidispineItemSubgroupMetadata $itemId "metadata" "oly_countryOfOrigin")
        # Translate originalLangugae to proper originalLanguageCode for XMLs
        itemOriginalLanguageCode=$(translateItemOriginalLanguageToCode "$itemOriginalLanguage" "$itemCountryOfOrigin")
        echo "        <!-- OriginalLanguage is required by Amazon -->
		<md:OriginalLanguage>$itemOriginalLanguageCode</md:OriginalLanguage>" >> "$mecFileDestination"
        # Adding AssociatedOrg Block
        echo "        <!-- AssociatedOrg is used to provide the Partner Alias and is required -->
		<!-- Include the Partner Alias value in the @organizationID attribute and the value of "licensor" in the @role attribute -->
		<md:AssociatedOrg organizationID=\"olympusat\" role=\"licensor\"></md:AssociatedOrg>" >> "$mecFileDestination"
        # If an Episode, Adding SequenceInfo Block
        if [[ "$itemContentType" == "episode" ]];
        then
            # Preparing Related Season Item Id for Sequence Info Block
            itemEpisodeNumber=$(filterVidispineItemMetadata $itemId "metadata" "oly_episodeNumber")
            urlGetRelatedItems="http://10.1.1.34:8080/API/item/$itemId/relation"
            httpResponseRelatedItems=$(curl --location --request GET $urlGetRelatedItems --header 'Accept: application/xml' --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=Tkb9vkSC8v4SceB8CHUyB3iaMPjvgoHrzhLrvo36agG3wqv0jHc7nsOtdTo9JEyM')
            relatedItemsCount=$(echo $httpResponseRelatedItems | awk -F '</relation>' '{print NF}')
            relatedItemsCount=$(($relatedItemsCount - 1))
            ## Get related items and iterate through each to check cs_type is forDistribution & get target id
            for (( k=1 ; k<=$relatedItemsCount ; k++ ));
            do
                l=2
                currentRelationValue=$(echo "$httpResponseRelatedItems" | awk -F '</relation>' '{print $'$k'}' | awk -F '<relation>' '{print $'$l'}' )
                currentRelationCsTypeValue=$(echo "$currentRelationValue" | awk -F '<value key="cs_type">' '{print $2}' | awk -F '</value>' '{print $1}')
                if [[ "$currentRelationCsTypeValue" == "season" ]];
                then
                    currentTargetIdValue=$(echo "$currentRelationValue" | awk -F '<target>' '{print $2}' | awk -F '</target>' '{print $1}')
                    seasonItemId=$(echo $currentTargetIdValue)
                    seasonItemIdXml=$(echo $currentTargetIdValue | sed 's/-/_/g')
                    echo "<!-- Sequence Info and Parent information is required for TV episodes and seasons -->
		<md:SequenceInfo>
			<md:Number>$itemEpisodeNumber</md:Number>
		</md:SequenceInfo>
		<md:Parent relationshipType=\"isepisodeof\">
			<md:ParentContentID>md:cid:org:olympusat:$seasonItemIdXml</md:ParentContentID>
		</md:Parent>" >> "$mecFileDestination"
                fi
                if [[ "$currentRelationCsTypeValue" == "series" ]];
                then
                    currentTargetIdValue=$(echo "$currentRelationValue" | awk -F '<target>' '{print $2}' | awk -F '</target>' '{print $1}')
                    seriesItemId=$(echo $currentTargetIdValue)
                    seriesItemIdXml=$(echo $currentTargetIdValue | sed 's/-/_/g')
                fi
            done
        fi
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
        # Check to see if mecFileDestination file exists
        if [[ -e "$mecFileDestination" ]];
        then
            # mecFileDestination file exists-moving to volumes/creative/cs13/distribution/amazon_staging/metadata folder
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (distributionWorkflow) - ($itemId) - Moving MEC File to creative Volume" >> "$logfile"
            mv -f "$mecFileDestination" "/Volumes/creative/CS13/Distribution/Amazon_Staging/metadata/"
            sleep 2
            if [[ -e "$mecFileDestinationArt" ]];
            then
                # mecFileDestinationArt file exists-deleting file
                rm -f "/opt/olympusat/xmlsForDistribution/amazon/_miscFiles/ArtForMEC-$itemTitle.xml"
            fi
            # Check to see if mecFileDestinationGenre file exists
            if [[ -e "$mecFileDestinationGenre" ]];
            then
                # mecFileDestinationGenre file exists-deleting file
                rm -f "/opt/olympusat/xmlsForDistribution/amazon/_miscFiles/GenreForMEC-$itemTitle.xml"
            fi
            # Check to see if mecFileDestinationRating file exists
            if [[ -e "$mecFileDestinationRating" ]];
            then
                # mecFileDestinationRating file exists-deleting file
                rm -f "/opt/olympusat/xmlsForDistribution/amazon/_miscFiles/RatingForMEC-$itemTitle.xml"
            fi
            # Check to see if mecFileDestinationActor file exists
            if [[ -e "$mecFileDestinationActor" ]];
            then
                # mecFileDestinationActor file exists-deleting file
                rm -f "/opt/olympusat/xmlsForDistribution/amazon/_miscFiles/ActorForMEC-$itemTitle.xml"
            fi
            # Check to see if mecFileDestinationDirector file exists
            if [[ -e "$mecFileDestinationDirector" ]];
            then
                # mecFileDestinationDirector file exists-deleting file
                rm -f "/opt/olympusat/xmlsForDistribution/amazon/_miscFiles/DirectorForMEC-$itemTitle.xml"
            fi
            # Check to see if mecFileDestinationProducer file exists
            if [[ -e "$mecFileDestinationProducer" ]];
            then
                # mecFileDestinationProducer file exists-deleting file
                rm -f "/opt/olympusat/xmlsForDistribution/amazon/_miscFiles/ProducerForMEC-$itemTitle.xml"
            fi
        fi
        echo "$(date +%Y/%m/%d_%H:%M:%S) - (distributionWorkflow) - ($itemId) - Create MEC XML COMPLETED" >> "$logfile"
        sleep 2
        # ----------------------------------------------------------------------
    else
        # contentType is NOT supported-exiting script
        echo "$(date +%Y/%m/%d_%H:%M:%S) - (distributionWorkflow) - ($itemId) - Content Type NOT Supported - exiting script" >> "$logfile"
    fi

    if [[ "$itemContentTypeOriginal" == "episode" ]];
    then
        # ----------------------------------------------------------------------
        # Create MEC XML for Season
        itemId=$(echo $seasonItemId)
        itemIdXml=$(echo $seasonItemIdXml)
        itemRLItemId=$(filterVidispineItemMetadata $itemId "metadata" "oly_rightslineItemId")
        seasonItemTitle=$(echo "$itemTitle" | awk -F '_' '{print $2}')
        seasonItemTitleEnd=$(echo "$itemTitle" | awk -F '_' '{print $4}')
        seasonItemTitle=$(echo CA_"$seasonItemTitle"_"$itemRLItemId"_$seasonItemTitleEnd)
        mecSeasonFileDestination="/opt/olympusat/xmlsForDistribution/$distributionTo/MEC-$seasonItemTitle.xml"
        mecSeasonFileDestinationArt="/opt/olympusat/xmlsForDistribution/$distributionTo/_miscFiles/ArtForMEC-$seasonItemTitle.xml"
        mecSeasonFileDestinationGenre="/opt/olympusat/xmlsForDistribution/$distributionTo/_miscFiles/GenreForMEC-$seasonItemTitle.xml"
        mecSeasonFileDestinationRating="/opt/olympusat/xmlsForDistribution/$distributionTo/_miscFiles/RatingForMEC-$seasonItemTitle.xml"
        mecSeasonFileDestinationActor="/opt/olympusat/xmlsForDistribution/$distributionTo/_miscFiles/ActorForMEC-$seasonItemTitle.xml"
        mecSeasonFileDestinationDirector="/opt/olympusat/xmlsForDistribution/$distributionTo/_miscFiles/DirectorForMEC-$seasonItemTitle.xml"
        mecSeasonFileDestinationProducer="/opt/olympusat/xmlsForDistribution/$distributionTo/_miscFiles/ProducerForMEC-$seasonItemTitle.xml"
        # Check to see if mecSeasonFileDestination file exists
        if [[ ! -e "$mecSeasonFileDestination" ]];
        then
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (distributionWorkflow) - ($itemId) - Create Season MEC XML In Progress for [$seasonItemTitle]" >> "$logfile"
            # Gathering metadata from Cantemo
            itemContentType=$(filterVidispineItemMetadata $itemId "metadata" "oly_contentType")
            itemTitleEn=$(filterVidispineItemMetadata $itemId "metadata" "oly_titleEn")
            itemTitleEs=$(filterVidispineItemMetadata $itemId "metadata" "oly_titleEs")
            itemLogLineEn=$(filterVidispineItemSubgroupMetadata $itemId "metadata" "oly_logLineEn" "English%20Synopsis")
            itemShortDescriptionEn=$(filterVidispineItemSubgroupMetadata $itemId "metadata" "oly_shortDescriptionEn" "English%20Synopsis")
            itemDescriptionEn=$(filterVidispineItemSubgroupMetadata $itemId "metadata" "oly_descriptionEn" "English%20Synopsis")
            itemLogLineEs=$(filterVidispineItemSubgroupMetadata $itemId "metadata" "oly_logLineEs" "Spanish%20Synopsis")
            itemShortDescriptionEs=$(filterVidispineItemSubgroupMetadata $itemId "metadata" "oly_shortDescriptionEs" "Spanish%20Synopsis")
            itemDescriptionEs=$(filterVidispineItemSubgroupMetadata $itemId "metadata" "oly_descriptionEs" "Spanish%20Synopsis")
            itemProductionYear=$(filterVidispineItemMetadata $itemId "metadata" "oly_productionYear")
            if [[ "$itemTitleEn" == "" ]];
            then
                if [[ "$itemTitleEs" != "" ]];
                then
                    itemTitleEn=$(echo "$itemTitleEs")
                fi            
            fi
            if [[ "$itemTitleEs" == "" ]];
            then
                if [[ "$itemTitleEn" != "" ]];
                then
                    itemTitleEs=$(echo "$itemTitleEn")
                fi            
            fi
            # Adding XML Header
            echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" >> "$mecSeasonFileDestination"
            # Adding CoreMetadata Block Start
            echo "<mdmec:CoreMetadata xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"
 xsi:schemaLocation=\"http://www.movielabs.com/schema/mdmec/v2.9 ../mdmec-v2.9.xsd\"
 xmlns:md=\"http://www.movielabs.com/schema/md/v2.9/md\"
 xmlns:mdmec=\"http://www.movielabs.com/schema/mdmec/v2.9\">" >> "$mecSeasonFileDestination"
            # Adding Basic Block Start
            echo "    <mdmec:Basic ContentID=\"md:cid:org:olympusat:$itemIdXml\">" >> "$mecSeasonFileDestination"
            # Adding LocalizedInfo in English Block Start
            echo "        <md:LocalizedInfo language=\"en-US\">" >> "$mecSeasonFileDestination"
            # Preparing Related Image Resolutions for LocalizedInfo in English Block
            urlGetRelatedItems="http://10.1.1.34:8080/API/item/$itemId/relation"
            httpResponseRelatedItems=$(curl --location --request GET $urlGetRelatedItems --header 'Accept: application/xml' --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=Tkb9vkSC8v4SceB8CHUyB3iaMPjvgoHrzhLrvo36agG3wqv0jHc7nsOtdTo9JEyM')
            relatedItemsCount=$(echo $httpResponseRelatedItems | awk -F '</relation>' '{print NF}')
            relatedItemsCount=$(($relatedItemsCount - 1))
            ## Get related items and iterate through each to check cs_type is forDistribution & get target id
            for (( m=1 ; m<=$relatedItemsCount ; m++ ));
            do
                n=2
                currentRelationValue=$(echo "$httpResponseRelatedItems" | awk -F '</relation>' '{print $'$m'}' | awk -F '<relation>' '{print $'$n'}' )
                currentRelationCsTypeValue=$(echo "$currentRelationValue" | awk -F '<value key="cs_type">' '{print $2}' | awk -F '</value>' '{print $1}')
                if [[ "$currentRelationCsTypeValue" == "forDistribution" ]];
                then
                    currentTargetIdValue=$(echo "$currentRelationValue" | awk -F '<target>' '{print $2}' | awk -F '</target>' '{print $1}')
                    relatedItemType=$(filterVidispineItemMetadata $currentTargetIdValue "metadata" "oly_graphicsType")
                    relatedItemResolution=$(filterVidispineItemMetadata $currentTargetIdValue "metadata" "oly_graphicsResolution")
                    # Calculate aspect ratio
                    aspectRatio=$(calculate_aspect_ratio "$relatedItemResolution")
                    #echo "Aspect Ratio - $aspectRatio"
                    if [[ "$itemContentType" == "season" ]];
                    then
                        if [[ "$relatedItemType" == "cover" && "$aspectRatio" == "16x9" ]];
                        then
                            echo "            <md:ArtReference resolution=\"$relatedItemResolution\" purpose=\"cover\">$itemTitle-cover-16x9.jpg</md:ArtReference>" >> "$mecSeasonFileDestinationArt"
                        elif [[ "$relatedItemType" == "cover" && "$aspectRatio" == "4x3" ]];
                        then
                            echo "            <md:ArtReference resolution=\"$relatedItemResolution\" purpose=\"boxart\">$itemTitle-box-4x3.jpg</md:ArtReference>" >> "$mecSeasonFileDestinationArt"
                        elif [[ "$relatedItemType" == "feature" && "$aspectRatio" == "16x9" ]];
                        then
                            echo "            <md:ArtReference resolution=\"$relatedItemResolution\" purpose=\"hero\">$itemTitle-hero-16x9.jpg</md:ArtReference>" >> "$mecSeasonFileDestinationArt"
                        fi
                    fi
                fi
            done
            # Adding LocalizedInfo in English Block - Title
            echo "            <!-- TitleDisplayUnlimited is required by Amazon. Limited to 250 characters. -->
			<md:TitleDisplayUnlimited>$itemTitleEn</md:TitleDisplayUnlimited>
			<!-- TitleSort is required by the MEC XSD, but is not used by Amazon. Blank fields such as below are acceptable.  -->
			<md:TitleSort></md:TitleSort>" >> "$mecSeasonFileDestination"
            # Adding LocalizedInfo in English Block - ArtReference
            cat "$mecSeasonFileDestinationArt" >> "$mecSeasonFileDestination"
            # Adding LocalizedInfo in English Block - Summaries
            echo "            <!-- Summary190 is required by the MEC XSD, but is not required by Amazon. Blank fields such as below are acceptable.  -->
			<md:Summary190>$itemLogLineEn</md:Summary190>
			<!-- Summary400 is required by Amazon -->
			<md:Summary400>$itemShortDescriptionEn</md:Summary400>
			<md:Summary4000>$itemDescriptionEn</md:Summary4000>" >> "$mecSeasonFileDestination"
            # Preparing Genre Info for LocalizedInfo in English Block
            itemAmazonPrimaryGenre=$(filterVidispineItemMetadata $itemId "metadata" "oly_amazonPrimaryGenre")
            urlGetItemAmazonSecondaryGenres="http://10.1.1.34:8080/API/item/$itemId/metadata?field=oly_amazonSecondaryGenres&terse=yes"
            httpResponseAmazonSecondaryGenres=$(curl --location --request GET $urlGetItemAmazonSecondaryGenres  --header 'Accept: application/xml' --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=Tkb9vkSC8v4SceB8CHUyB3iaMPjvgoHrzhLrvo36agG3wqv0jHc7nsOtdTo9JEyM')
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (distributionWorkflow) - ($itemId) - Secondary Genres [$httpResponseAmazonSecondaryGenres]" >> "$logfile"
            subGenreItemCount=$(echo $httpResponseAmazonSecondaryGenres | awk -F '</oly_amazonSecondaryGenres>' '{print NF}')
            subGenreItemCount=$(($subGenreItemCount - 1))
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (distributionWorkflow) - ($itemId) - subGenreItemCount - [$subGenreItemCount]" >> "$logfile"
            if [[ $subGenreItemCount -lt 2 ]];
            then
                occurenceCount=$subGenreItemCount
            else
                occurenceCount=2
            fi
            ## Get item's primary genre and add information into genre xml
            echo "            <md:Genre id=\"$itemAmazonPrimaryGenre\"></md:Genre>" >> "$mecSeasonFileDestinationGenre"
            ## Get item's secondary genres and iterate through each and add information into genre xml with appropriate genre/subgenre for Amazon
            for (( o=1 ; o<=$occurenceCount ; o++ ));
            do
                if [[ $o -eq 1 ]];
                then
                    p=3
                else
                    p=2
                fi
                #k=2
                currentValue=$(echo "$httpResponseAmazonSecondaryGenres" | awk -F '</oly_amazonSecondaryGenres>' '{print $'$o'}' | awk -F '/vidispine">' '{print $'$p'}' )
                echo "$(date +%Y/%m/%d_%H:%M:%S) - (distributionWorkflow) - ($itemId) - currentValue - [$currentValue]" >> "$logfile"
                echo "            <md:Genre id=\"$currentValue\"></md:Genre>" >> "$mecSeasonFileDestinationGenre"
            done
            # Adding LocalizedInfo in English Block - Genre
            echo "            <!-- Genres must be submitted using the AV Genre codes, such as below. -->
			<!-- Genres may be provided in just one, or all LocalizedInfo blocks. See the spec documentation for more detail. -->
			<!-- At least 1 genre is required. Up to 3 genres are allowed. -->" >> "$mecSeasonFileDestination"
            cat "$mecSeasonFileDestinationGenre" >> "$mecSeasonFileDestination"
            # Adding LocalizedInfo in English Block Close
            echo "        </md:LocalizedInfo>" >> "$mecSeasonFileDestination"
            # Adding LocalizedInfo in Spanish Block Start
            echo "        <md:LocalizedInfo language=\"es-MX\">" >> "$mecSeasonFileDestination"
            # Adding LocalizedInfo in Spanish Block
            echo "            <md:TitleDisplayUnlimited>$itemTitleEs</md:TitleDisplayUnlimited>
			<md:TitleSort></md:TitleSort>
			<md:Summary190>$itemLogLineEs</md:Summary190>
			<md:Summary400>$itemShortDescriptionEs</md:Summary400>
			<md:Summary4000>$itemDescriptionEs</md:Summary4000>" >> "$mecSeasonFileDestination"
            # Adding LocalizedInfo in Spanish Block Close
            echo "        </md:LocalizedInfo>" >> "$mecSeasonFileDestination"
            # Adding ReleaseYear Block
            echo "        <md:ReleaseYear>$itemProductionYear</md:ReleaseYear>" >> "$mecSeasonFileDestination"
            # Adding WorkType Block
            echo "        <!-- WorkType is Required -->
		<md:WorkType>$itemContentType</md:WorkType>" >> "$mecSeasonFileDestination"
            # Adding AltIdentifier Block
            echo "        <!-- The ID used in the MMC and in the Avail must also be included in the AltIdentifier section -->
		<md:AltIdentifier>
			<md:Namespace>ORG</md:Namespace>
			<md:Identifier>$itemIdXml</md:Identifier>
		</md:AltIdentifier>
		<!-- md:AltIdentifier>
			<md:Namespace>IMDB</md:Namespace>
			<md:Identifier>tt4518590</md:Identifier>
		</md:AltIdentifier -->" >> "$mecSeasonFileDestination"
            # Adding RatingSet Block Start
            echo "        <md:RatingSet>
                <!-- each rating specifies exactly one country, system and value -->
			<!-- At least one rating is required. If the work is not rated, use <md:notrated>true</md:notrated>  -->
			<!-- see http://www.movielabs.com/md/ratings/current.html for ratings -->" >> "$mecSeasonFileDestination"
            # Preparing Rating Block
            itemOriginalRating=$(filterVidispineItemMetadata $itemId "metadata" "oly_originalRating")
            case "$itemOriginalRating" in
                "tv-14")
                    echo "            <md:Rating>
				<md:Region>
					<md:country>US</md:country>
				</md:Region>
				<md:System>TVPG</md:System>
				<md:Value>TV-14</md:Value>
			</md:Rating>" >> "$mecSeasonFileDestinationRating"
                ;;
                "tv-g")
                    echo "            <md:Rating>
				<md:Region>
					<md:country>US</md:country>
				</md:Region>
				<md:System>TVPG</md:System>
				<md:Value>TV-G</md:Value>
			</md:Rating>" >> "$mecSeasonFileDestinationRating"
                ;;
                "tv-ma")
                    echo "            <md:Rating>
				<md:Region>
					<md:country>US</md:country>
				</md:Region>
				<md:System>TVPG</md:System>
				<md:Value>TV-MA</md:Value>
			</md:Rating>" >> "$mecSeasonFileDestinationRating"
                ;;
                "tv-nr")
                    echo "            <md:Rating>
				<md:Region>
					<md:country>US</md:country>
				</md:Region>
				<md:System>TVPG</md:System>
				<md:NotRated>true</md:NotRated>
			</md:Rating>" >> "$mecSeasonFileDestinationRating"
                ;;
                "tv-pg")
                    echo "            <md:Rating>
				<md:Region>
					<md:country>US</md:country>
				</md:Region>
				<md:System>TVPG</md:System>
				<md:Value>TV-PG</md:Value>
			</md:Rating>" >> "$mecSeasonFileDestinationRating"
                ;;
                "tv-y")
                    echo "            <md:Rating>
				<md:Region>
					<md:country>US</md:country>
				</md:Region>
				<md:System>TVPG</md:System>
				<md:Value>TV-Y</md:Value>
			</md:Rating>" >> "$mecSeasonFileDestinationRating"
                ;;
                *)
                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (distributionWorkflow) - ($itemId) - Season Does NOT have Original Rating Set in Cantemo" >> "$logfile"
                ;;
            esac
            # Adding Rating Block
            cat "$mecSeasonFileDestinationRating" >> "$mecSeasonFileDestination"
            
            # Adding RatingSet Block Close
            echo "        </md:RatingSet>" >> "$mecSeasonFileDestination"

            # Adding People Block Start
            echo "        <!-- people are used for the cast and crew.  -->" >> "$mecSeasonFileDestination"
            # Preparing Cast Info for People - Actor Block
            urlGetItemCast="http://10.1.1.34:8080/API/item/$itemId/metadata?field=oly_cast&terse=yes"
            httpResponseCast=$(curl --location --request GET $urlGetItemCast --header 'Accept: application/xml' --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=Tkb9vkSC8v4SceB8CHUyB3iaMPjvgoHrzhLrvo36agG3wqv0jHc7nsOtdTo9JEyM')
            castItemCount=$(echo $httpResponseCast | awk -F '</oly_cast>' '{print NF}')
            castItemCount=$(($castItemCount - 1))
            if [[ $castItemCount -lt 6 ]];
            then
                occurenceCount=$castItemCount
            else
                occurenceCount=6
            fi
            ## Get item's cast metadata and iterate through each and add information into actor xml with people-actor for Amazon
            for (( q=1 ; q<=$occurenceCount ; q++ ));
            do
                if [[ $q -eq 1 ]];
                then
                    r=3
                else
                    r=2
                fi
                currentValue=$(echo "$httpResponseCast" | awk -F '</oly_cast>' '{print $'$q'}' | awk -F '/vidispine">' '{print $'$r'}' )    
                echo "        <md:People>
			<md:Job>
				<md:JobFunction>Actor</md:JobFunction>
				<md:BillingBlockOrder>$l</md:BillingBlockOrder>
			</md:Job>
			<md:Name>
				<md:DisplayName language=\"en-US\">$currentValue</md:DisplayName>
				<md:DisplayName language=\"es-MX\">$currentValue</md:DisplayName>
			</md:Name>
		</md:People>" >> "$mecSeasonFileDestinationActor"
            done
            # Preparing Director Info for People - Director Block
            urlGetItemDirector="http://10.1.1.34:8080/API/item/$itemId/metadata?field=oly_director&terse=yes"
            httpResponseDirector=$(curl --location --request GET $urlGetItemDirector  --header 'Accept: application/xml' --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=Tkb9vkSC8v4SceB8CHUyB3iaMPjvgoHrzhLrvo36agG3wqv0jHc7nsOtdTo9JEyM')
            directorItemCount=$(echo $httpResponseDirector | awk -F '</oly_director>' '{print NF}')
            directorItemCount=$(($directorItemCount - 1))
            if [[ $directorItemCount -lt 3 ]];
            then
                occurenceCount=$directorItemCount
            else
                occurenceCount=3
            fi
            ## Get item's director metadata and iterate through each and add information into director xml with people-director for Amazon
            for (( s=1 ; s<=$occurenceCount ; s++ ));
            do
                if [[ $s -eq 1 ]];
                then
                    t=3
                else
                    t=2
                fi
                currentValue=$(echo "$httpResponseDirector" | awk -F '</oly_director>' '{print $'$s'}' | awk -F '/vidispine">' '{print $'$t'}' )
                echo "        <md:People>
			<md:Job>
				<md:JobFunction>Director</md:JobFunction>
				<md:BillingBlockOrder>$n</md:BillingBlockOrder>
			</md:Job>
			<md:Name>
				<md:DisplayName language=\"en-US\">$currentValue</md:DisplayName>
				<md:DisplayName language=\"es-MX\">$currentValue</md:DisplayName>
			</md:Name>
		</md:People>" >> "$mecSeasonFileDestinationDirector"
            done
            # Preparing Producer Info for People - Producer Block
            urlGetItemProducer="http://10.1.1.34:8080/API/item/$itemId/metadata?field=oly_producer&terse=yes"
            httpResponseProducer=$(curl --location --request GET $urlGetItemProducer  --header 'Accept: application/xml' --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=Tkb9vkSC8v4SceB8CHUyB3iaMPjvgoHrzhLrvo36agG3wqv0jHc7nsOtdTo9JEyM')
            producerItemCount=$(echo $httpResponseProducer | awk -F '</oly_producer>' '{print NF}')
            producerItemCount=$(($producerItemCount - 1))
            if [[ $producerItemCount -lt 3 ]];
            then
                occurenceCount=$producerItemCount
            else
                occurenceCount=3
            fi
            ## Get item's producer metadata and iterate through each and add information into producer xml with people-producer for Amazon
            for (( u=1 ; u<=$occurenceCount ; u++ ));
            do
                if [[ $u -eq 1 ]];
                then
                    v=3
                else
                    v=2
                fi
                currentValue=$(echo "$httpResponseProducer" | awk -F '</oly_producer>' '{print $'$u'}' | awk -F '/vidispine">' '{print $'$v'}' )
                echo "        <md:People>
			<md:Job>
				<md:JobFunction>Producer</md:JobFunction>
				<md:BillingBlockOrder>$p</md:BillingBlockOrder>
			</md:Job>
			<md:Name>
				<md:DisplayName language=\"en-US\">$currentValue</md:DisplayName>
				<md:DisplayName language=\"es-MX\">$currentValue</md:DisplayName>
			</md:Name>
		</md:People>" >> "$mecSeasonFileDestinationProducer"
            done
            # Adding People Actor, Director and Producer Blocks to People Block
            cat "$mecSeasonFileDestinationActor" >> "$mecSeasonFileDestination"
            cat "$mecSeasonFileDestinationDirector" >> "$mecSeasonFileDestination"
            cat "$mecSeasonFileDestinationProducer" >> "$mecSeasonFileDestination"
            # Adding OriginalLanguage Block
            echo "        <!-- OriginalLanguage is required by Amazon -->
		<md:OriginalLanguage>$itemOriginalLanguageCode</md:OriginalLanguage>" >> "$mecSeasonFileDestination"
            # Adding AssociatedOrg Block
            echo "        <!-- AssociatedOrg is used to provide the Partner Alias and is required -->
		<!-- Include the Partner Alias value in the @organizationID attribute and the value of "licensor" in the @role attribute -->
		<md:AssociatedOrg organizationID=\"olympusat\" role=\"licensor\"></md:AssociatedOrg>" >> "$mecSeasonFileDestination"
            # If an Episode, Adding SequenceInfo Block
            if [[ "$itemContentType" == "season" ]];
            then
                # Preparing Related Season Item Id for Sequence Info Block
                itemSeasonNumber=$(filterVidispineItemMetadata $itemId "metadata" "oly_seasonNumber")
                urlGetRelatedItems="http://10.1.1.34:8080/API/item/$itemId/relation"
                httpResponseRelatedItems=$(curl --location --request GET $urlGetRelatedItems --header 'Accept: application/xml' --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=Tkb9vkSC8v4SceB8CHUyB3iaMPjvgoHrzhLrvo36agG3wqv0jHc7nsOtdTo9JEyM')
                relatedItemsCount=$(echo $httpResponseRelatedItems | awk -F '</relation>' '{print NF}')
                relatedItemsCount=$(($relatedItemsCount - 1))
                ## Get related items and iterate through each to check cs_type is forDistribution & get target id
                for (( w=1 ; w<=$relatedItemsCount ; w++ ));
                do
                    x=2
                    currentRelationValue=$(echo "$httpResponseRelatedItems" | awk -F '</relation>' '{print $'$w'}' | awk -F '<relation>' '{print $'$x'}' )
                    currentRelationCsTypeValue=$(echo "$currentRelationValue" | awk -F '<value key="cs_type">' '{print $2}' | awk -F '</value>' '{print $1}')
                    if [[ "$currentRelationCsTypeValue" == "series" ]];
                    then
                        currentTargetIdValue=$(echo "$currentRelationValue" | awk -F '<target>' '{print $2}' | awk -F '</target>' '{print $1}')
                        seriesFromSeasonItemIdXml=$(echo $currentTargetIdValue | sed 's/-/_/g')
                        if [[ "$seriesItemIdXml" == "$seriesFromSeasonItemIdXml" ]];
                        then
                            echo "        <!-- Sequence Info and Parent information is required for TV episodes and seasons -->
		<md:SequenceInfo>
			<md:Number>$itemSeasonNumber</md:Number>
		</md:SequenceInfo>
		<md:Parent relationshipType=\"isseasonof\">
			<md:ParentContentID>md:cid:org:olympusat:$seriesFromSeasonItemIdXml</md:ParentContentID>
		</md:Parent>" >> "$mecSeasonFileDestination"
                        else
                            echo "$(date +%Y/%m/%d_%H:%M:%S) - (distributionWorkflow) - ($itemId) - Series Id Xml's from Episode & Season DO NOT MATCH {$seriesItemIdXml} [$seriesFromSeasonItemIdXml]" >> "$logfile"
                        fi
                    fi
                done
            fi
            # Adding Basic Block Close
            echo "    </mdmec:Basic>" >> "$mecSeasonFileDestination"
            # Adding CompanyDisplayCredit Block
            echo "    <!-- CompanyDisplayCredit is used to provide customer-facing studio credits. Required. -->
	<mdmec:CompanyDisplayCredit>
		<md:DisplayString language=\"en-US\">Olympusat</md:DisplayString>
	</mdmec:CompanyDisplayCredit>" >> "$mecSeasonFileDestination"
            # Adding CoreMetadata Block Close
            echo "</mdmec:CoreMetadata>" >> "$mecSeasonFileDestination"
            sleep 2
            # Check to see if mecSeasonFileDestination file exists
            if [[ -e "$mecSeasonFileDestination" ]];
            then
                # mecSeasonFileDestination file exists-moving to volumes/creative/cs13/distribution/amazon_staging/metadata folder
                echo "$(date +%Y/%m/%d_%H:%M:%S) - (distributionWorkflow) - ($itemId) - Moving Season MEC File to creative Volume" >> "$logfile"
                mv -f "$mecSeasonFileDestination" "/Volumes/creative/CS13/Distribution/Amazon_Staging/metadata/"
                sleep 2
                # Check to see if mecSeasonFileDestinationArt file exists
                if [[ -e "$mecSeasonFileDestinationArt" ]];
                then
                    # mecSeasonFileDestinationArt file exists-deleting file
                    rm -f "/opt/olympusat/xmlsForDistribution/amazon/_miscFiles/ArtForMEC-$seasonItemTitle.xml"
                fi
                # Check to see if mecSeasonFileDestinationGenre file exists
                if [[ -e "$mecSeasonFileDestinationGenre" ]];
                then
                    # mecSeasonFileDestinationGenre file exists-deleting file
                    rm -f "/opt/olympusat/xmlsForDistribution/amazon/_miscFiles/GenreForMEC-$seasonItemTitle.xml"
                fi
                # Check to see if mecSeasonFileDestinationRating file exists
                if [[ -e "$mecSeasonFileDestinationRating" ]];
                then
                    # mecSeasonFileDestinationRating file exists-deleting file
                    rm -f "/opt/olympusat/xmlsForDistribution/amazon/_miscFiles/RatingForMEC-$seasonItemTitle.xml"
                fi
                # Check to see if mecSeasonFileDestinationActor file exists
                if [[ -e "$mecSeasonFileDestinationActor" ]];
                then
                    # mecSeasonFileDestinationActor file exists-deleting file
                    rm -f "/opt/olympusat/xmlsForDistribution/amazon/_miscFiles/ActorForMEC-$seasonItemTitle.xml"
                fi
                # Check to see if mecSeasonFileDestinationDirector file exists
                if [[ -e "$mecSeasonFileDestinationDirector" ]];
                then
                    # mecSeasonFileDestinationDirector file exists-deleting file
                    rm -f "/opt/olympusat/xmlsForDistribution/amazon/_miscFiles/DirectorForMEC-$seasonItemTitle.xml"
                fi
                # Check to see if mecSeasonFileDestinationProducer file exists
                if [[ -e "$mecSeasonFileDestinationProducer" ]];
                then
                    # mecSeasonFileDestinationProducer file exists-deleting file
                    rm -f "/opt/olympusat/xmlsForDistribution/amazon/_miscFiles/ProducerForMEC-$seasonItemTitle.xml"
                fi
            fi
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (distributionWorkflow) - ($itemId) - Create Season MEC XML COMPLETED" >> "$logfile"
            sleep 2
            # ----------------------------------------------------------------------
        fi

        # ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        # Create MEC XML for Series
        itemId=$(echo $seriesItemId)
        itemIdXml=$(echo $seriesItemIdXml)
        itemRLItemId=$(filterVidispineItemMetadata $itemId "metadata" "oly_rightslineItemId")
        seriesItemTitle=$(echo "$itemTitle" | awk -F '_' '{print $2}')
        seriesItemTitleEnd=$(echo "$itemTitle" | awk -F '_' '{print $4}')
        seriesItemTitle=$(echo CA_"$seriesItemTitle"_"$itemRLItemId"_$seriesItemTitleEnd)
        mecSeriesFileDestination="/opt/olympusat/xmlsForDistribution/$distributionTo/MEC-$seriesItemTitle.xml"
        mecSeriesFileDestinationArt="/opt/olympusat/xmlsForDistribution/$distributionTo/_miscFiles/ArtForMEC-$seriesItemTitle.xml"
        mecSeriesFileDestinationGenre="/opt/olympusat/xmlsForDistribution/$distributionTo/_miscFiles/GenreForMEC-$seriesItemTitle.xml"
        mecSeriesFileDestinationRating="/opt/olympusat/xmlsForDistribution/$distributionTo/_miscFiles/RatingForMEC-$seriesItemTitle.xml"
        # Check to see if mecSeriesFileDestination file exists
        if [[ ! -e "$mecSeriesFileDestination" ]];
        then
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (distributionWorkflow) - ($itemId) - Create Series MEC XML In Progress for [$seriesItemTitle]" >> "$logfile"
            # Gathering metadata from Cantemo
            itemContentType=$(filterVidispineItemMetadata $itemId "metadata" "oly_contentType")
            itemTitleEn=$(filterVidispineItemMetadata $itemId "metadata" "oly_titleEn")
            itemTitleEs=$(filterVidispineItemMetadata $itemId "metadata" "oly_titleEs")
            itemLogLineEn=$(filterVidispineItemSubgroupMetadata $itemId "metadata" "oly_logLineEn" "English%20Synopsis")
            itemShortDescriptionEn=$(filterVidispineItemSubgroupMetadata $itemId "metadata" "oly_shortDescriptionEn" "English%20Synopsis")
            itemDescriptionEn=$(filterVidispineItemSubgroupMetadata $itemId "metadata" "oly_descriptionEn" "English%20Synopsis")
            itemLogLineEs=$(filterVidispineItemSubgroupMetadata $itemId "metadata" "oly_logLineEs" "Spanish%20Synopsis")
            itemShortDescriptionEs=$(filterVidispineItemSubgroupMetadata $itemId "metadata" "oly_shortDescriptionEs" "Spanish%20Synopsis")
            itemDescriptionEs=$(filterVidispineItemSubgroupMetadata $itemId "metadata" "oly_descriptionEs" "Spanish%20Synopsis")
            itemProductionYear=$(filterVidispineItemMetadata $itemId "metadata" "oly_productionYear")
            if [[ "$itemTitleEn" == "" ]];
            then
                if [[ "$itemTitleEs" != "" ]];
                then
                    itemTitleEn=$(echo "$itemTitleEs")
                fi            
            fi
            if [[ "$itemTitleEs" == "" ]];
            then
                if [[ "$itemTitleEn" != "" ]];
                then
                    itemTitleEs=$(echo "$itemTitleEn")
                fi            
            fi
            # Adding XML Header
            echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" >> "$mecSeriesFileDestination"
            # Adding CoreMetadata Block Start
            echo "<mdmec:CoreMetadata xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"
 xsi:schemaLocation=\"http://www.movielabs.com/schema/mdmec/v2.9 ../mdmec-v2.9.xsd\"
 xmlns:md=\"http://www.movielabs.com/schema/md/v2.9/md\"
 xmlns:mdmec=\"http://www.movielabs.com/schema/mdmec/v2.9\">" >> "$mecSeriesFileDestination"
            # Adding Basic Block Start
            echo "    <mdmec:Basic ContentID=\"md:cid:org:olympusat:$itemIdXml\">" >> "$mecSeriesFileDestination"
            # Adding LocalizedInfo in English Block Start
            echo "        <md:LocalizedInfo language=\"en-US\">" >> "$mecSeriesFileDestination"
            # Adding LocalizedInfo in English Block - Title
            echo "            <!-- TitleDisplayUnlimited is required by Amazon. Limited to 250 characters. -->
			<md:TitleDisplayUnlimited>$itemTitleEn</md:TitleDisplayUnlimited>
			<!-- TitleSort is required by the MEC XSD, but is not used by Amazon. Blank fields such as below are acceptable.  -->
			<md:TitleSort></md:TitleSort>" >> "$mecSeriesFileDestination"
            # Adding LocalizedInfo in English Block - Summaries
            echo "            <!-- Summary190 is required by the MEC XSD, but is not required by Amazon. Blank fields such as below are acceptable.  -->
			<md:Summary190>$itemLogLineEn</md:Summary190>
			<!-- Summary400 is required by Amazon -->
			<md:Summary400>$itemShortDescriptionEn</md:Summary400>
			<md:Summary4000>$itemDescriptionEn</md:Summary4000>" >> "$mecSeriesFileDestination"
            # Preparing Genre Info for LocalizedInfo in English Block
            itemAmazonPrimaryGenre=$(filterVidispineItemMetadata $itemId "metadata" "oly_amazonPrimaryGenre")
            urlGetItemAmazonSecondaryGenres="http://10.1.1.34:8080/API/item/$itemId/metadata?field=oly_amazonSecondaryGenres&terse=yes"
            httpResponseAmazonSecondaryGenres=$(curl --location --request GET $urlGetItemAmazonSecondaryGenres  --header 'Accept: application/xml' --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=Tkb9vkSC8v4SceB8CHUyB3iaMPjvgoHrzhLrvo36agG3wqv0jHc7nsOtdTo9JEyM')
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (distributionWorkflow) - ($itemId) - Secondary Genres [$httpResponseAmazonSecondaryGenres]" >> "$logfile"
            subGenreItemCount=$(echo $httpResponseAmazonSecondaryGenres | awk -F '</oly_amazonSecondaryGenres>' '{print NF}')
            subGenreItemCount=$(($subGenreItemCount - 1))
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (distributionWorkflow) - ($itemId) - subGenreItemCount - [$subGenreItemCount]" >> "$logfile"
            if [[ $subGenreItemCount -lt 2 ]];
            then
                occurenceCount=$subGenreItemCount
            else
                occurenceCount=2
            fi
            ## Get item's primary genre and add information into genre xml
            echo "            <md:Genre id=\"$itemAmazonPrimaryGenre\"></md:Genre>" >> "$mecSeriesFileDestinationGenre"
            ## Get item's secondary genres and iterate through each and add information into genre xml with appropriate genre/subgenre for Amazon
            for (( y=1 ; y<=$occurenceCount ; y++ ));
            do
                if [[ $y -eq 1 ]];
                then
                    z=3
                else
                    z=2
                fi
                #k=2
                currentValue=$(echo "$httpResponseAmazonSecondaryGenres" | awk -F '</oly_amazonSecondaryGenres>' '{print $'$y'}' | awk -F '/vidispine">' '{print $'$z'}' )
                echo "$(date +%Y/%m/%d_%H:%M:%S) - (distributionWorkflow) - ($itemId) - currentValue - [$currentValue]" >> "$logfile"
                echo "            <md:Genre id=\"$currentValue\"></md:Genre>" >> "$mecSeriesFileDestinationGenre"
            done
            # Adding LocalizedInfo in English Block - Genre
            echo "            <!-- Genres must be submitted using the AV Genre codes, such as below. -->
			<!-- Genres may be provided in just one, or all LocalizedInfo blocks. See the spec documentation for more detail. -->
			<!-- At least 1 genre is required. Up to 3 genres are allowed. -->" >> "$mecSeriesFileDestination"
            cat "$mecSeriesFileDestinationGenre" >> "$mecSeriesFileDestination"
            # Adding LocalizedInfo in English Block Close
            echo "        </md:LocalizedInfo>" >> "$mecSeriesFileDestination"
            # Adding LocalizedInfo in Spanish Block Start
            echo "        <md:LocalizedInfo language=\"es-MX\">" >> "$mecSeriesFileDestination"
            # Adding LocalizedInfo in Spanish Block
            echo "            <md:TitleDisplayUnlimited>$itemTitleEs</md:TitleDisplayUnlimited>
			<md:TitleSort></md:TitleSort>
			<md:Summary190>$itemLogLineEs</md:Summary190>
			<md:Summary400>$itemShortDescriptionEs</md:Summary400>
			<md:Summary4000>$itemDescriptionEs</md:Summary4000>" >> "$mecSeriesFileDestination"
            # Adding LocalizedInfo in Spanish Block Close
            echo "        </md:LocalizedInfo>" >> "$mecSeriesFileDestination"
            # Adding ReleaseYear Block
            echo "        <md:ReleaseYear>$itemProductionYear</md:ReleaseYear>" >> "$mecSeriesFileDestination"
            # Adding WorkType Block
            echo "        <!-- WorkType is Required -->
		<md:WorkType>$itemContentType</md:WorkType>" >> "$mecSeriesFileDestination"
            # Adding AltIdentifier Block
            echo "        <!-- The ID used in the MMC and in the Avail must also be included in the AltIdentifier section -->
		<md:AltIdentifier>
			<md:Namespace>ORG</md:Namespace>
			<md:Identifier>$itemIdXml</md:Identifier>
		</md:AltIdentifier>
		<!-- md:AltIdentifier>
			<md:Namespace>IMDB</md:Namespace>
			<md:Identifier>tt4518590</md:Identifier>
		</md:AltIdentifier -->" >> "$mecSeriesFileDestination"
            # Adding RatingSet Block Start
            echo "        <md:RatingSet>
			<!-- each rating specifies exactly one country, system and value -->
			<!-- At least one rating is required. If the work is not rated, use <md:notrated>true</md:notrated>  -->
			<!-- see http://www.movielabs.com/md/ratings/current.html for ratings -->" >> "$mecSeriesFileDestination"
            # Preparing Rating Block
            itemOriginalRating=$(filterVidispineItemMetadata $itemId "metadata" "oly_originalRating")
            case "$itemOriginalRating" in
                "tv-14")
                    echo "            <md:Rating>
				<md:Region>
					<md:country>US</md:country>
				</md:Region>
				<md:System>TVPG</md:System>
				<md:Value>TV-14</md:Value>
			</md:Rating>" >> "$mecSeriesFileDestinationRating"
                ;;
                "tv-g")
                    echo "            <md:Rating>
				<md:Region>
					<md:country>US</md:country>
				</md:Region>
				<md:System>TVPG</md:System>
				<md:Value>TV-G</md:Value>
			</md:Rating>" >> "$mecSeriesFileDestinationRating"
                ;;
                "tv-ma")
                    echo "            <md:Rating>
				<md:Region>
					<md:country>US</md:country>
				</md:Region>
				<md:System>TVPG</md:System>
				<md:Value>TV-MA</md:Value>
			</md:Rating>" >> "$mecSeriesFileDestinationRating"
                ;;
                "tv-nr")
                    echo "            <md:Rating>
				<md:Region>
					<md:country>US</md:country>
				</md:Region>
				<md:System>TVPG</md:System>
				<md:NotRated>true</md:NotRated>
			</md:Rating>" >> "$mecSeriesFileDestinationRating"
                ;;
                "tv-pg")
                    echo "            <md:Rating>
				<md:Region>
					<md:country>US</md:country>
				</md:Region>
				<md:System>TVPG</md:System>
				<md:Value>TV-PG</md:Value>
			</md:Rating>" >> "$mecSeriesFileDestinationRating"
                ;;
                "tv-y")
                    echo "            <md:Rating>
				<md:Region>
					<md:country>US</md:country>
				</md:Region>
				<md:System>TVPG</md:System>
				<md:Value>TV-Y</md:Value>
			</md:Rating>" >> "$mecSeriesFileDestinationRating"
                ;;
                *)
                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (distributionWorkflow) - ($itemId) - Season Does NOT have Original Rating Set in Cantemo" >> "$logfile"
                ;;
            esac
            # Adding Rating Block
            cat "$mecSeriesFileDestinationRating" >> "$mecSeriesFileDestination"
            # Adding RatingSet Block Close
            echo "        </md:RatingSet>" >> "$mecSeriesFileDestination"
            # Adding OriginalLanguage Block
            echo "        <!-- OriginalLanguage is required by Amazon -->
		<md:OriginalLanguage>$itemOriginalLanguageCode</md:OriginalLanguage>" >> "$mecSeriesFileDestination"
            # Adding AssociatedOrg Block
            echo "        <!-- AssociatedOrg is used to provide the Partner Alias and is required -->
		<!-- Include the Partner Alias value in the @organizationID attribute and the value of "licensor" in the @role attribute -->
		<md:AssociatedOrg organizationID=\"olympusat\" role=\"licensor\"></md:AssociatedOrg>" >> "$mecSeriesFileDestination"
            # Adding Basic Block Close
            echo "    </mdmec:Basic>" >> "$mecSeriesFileDestination"
            # Adding CompanyDisplayCredit Block
            echo "    <!-- CompanyDisplayCredit is used to provide customer-facing studio credits. Required. -->
	<mdmec:CompanyDisplayCredit>
		<md:DisplayString language=\"en-US\">Olympusat</md:DisplayString>
	</mdmec:CompanyDisplayCredit>" >> "$mecSeriesFileDestination"
            # Adding CoreMetadata Block Close
            echo "</mdmec:CoreMetadata>" >> "$mecSeriesFileDestination"
            sleep 2
            # Check to see if mecSeriesFileDestination file exists
            if [[ -e "$mecSeriesFileDestination" ]];
            then
                # mecSeriesFileDestination file exists-moving to volumes/creative/cs13/distribution/amazon_staging/metadata folder
                echo "$(date +%Y/%m/%d_%H:%M:%S) - (distributionWorkflow) - ($itemId) - Moving Series MEC File to creative Volume" >> "$logfile"
                mv -f "$mecSeriesFileDestination" "/Volumes/creative/CS13/Distribution/Amazon_Staging/metadata/"
                sleep 2
                # Check to see if mecSeriesFileDestinationArt file exists
                if [[ -e "$mecSeriesFileDestinationArt" ]];
                then
                    # mecSeriesFileDestinationArt file exists-deleting file
                    rm -f "/opt/olympusat/xmlsForDistribution/amazon/_miscFiles/ArtForMEC-$seriesItemTitle.xml"
                fi
                # Check to see if mecSeriesFileDestinationGenre file exists
                if [[ -e "$mecSeriesFileDestinationGenre" ]];
                then
                    # mecSeriesFileDestinationGenre file exists-deleting file
                    rm -f "/opt/olympusat/xmlsForDistribution/amazon/_miscFiles/GenreForMEC-$seriesItemTitle.xml"
                fi
                # Check to see if mecSeriesFileDestinationRating file exists
                if [[ -e "$mecSeriesFileDestinationRating" ]];
                then
                    # mecSeriesFileDestinationRating file exists-deleting file
                    rm -f "/opt/olympusat/xmlsForDistribution/amazon/_miscFiles/RatingForMEC-$seriesItemTitle.xml"
                fi
                # Check to see if mecSeriesFileDestinationActor file exists
                if [[ -e "$mecSeriesFileDestinationActor" ]];
                then
                    # mecSeriesFileDestinationActor file exists-deleting file
                    rm -f "/opt/olympusat/xmlsForDistribution/amazon/_miscFiles/ActorForMEC-$seriesItemTitle.xml"
                fi
                # Check to see if mecSeriesFileDestinationDirector file exists
                if [[ -e "$mecSeriesFileDestinationDirector" ]];
                then
                    # mecSeriesFileDestinationDirector file exists-deleting file
                    rm -f "/opt/olympusat/xmlsForDistribution/amazon/_miscFiles/DirectorForMEC-$seriesItemTitle.xml"
                fi
                # Check to see if mecSeriesFileDestinationProducer file exists
                if [[ -e "$mecSeriesFileDestinationProducer" ]];
                then
                    # mecSeriesFileDestinationProducer file exists-deleting file
                    rm -f "/opt/olympusat/xmlsForDistribution/amazon/_miscFiles/ProducerForMEC-$seriesItemTitle.xml"
                fi
            fi
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (distributionWorkflow) - ($itemId) - Create Series MEC XML COMPLETED" >> "$logfile"
            # ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        fi
    fi
else
    # distributionTo NOT supported-exiting script
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (distributionWorkflow) - ($itemId) - 'Distribution To' NOT Supported - exiting script" >> "$logfile"
fi

IFS=$saveIFS