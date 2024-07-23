#!/bin/bash

#::***************************************************************************************************************************
#::This shell script will create the appropriate xmls for the content type, for Amazon delivery
#::Engineers: Ryan Sims & Tang Kanjanapitak
#::Client: Olympusat
#::Updated: 07/23/2024
#::Rev A: 
#::System requirements: This script will run in LINUX & MacOS
#::***************************************************************************************************************************

#--------------------------------------------------
# External funtions to include
. /opt/olympusat/scriptsLibrary/olympusatCantemo.lib
#--------------------------------------------------

saveIFS=$IFS
IFS=$(echo -e "\n\b")

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

        # Check to see if mmcFileDestination file exists
        if [[ -e "$mmcFileDestination" ]];
        then
            # mmcFileDestination file exists-deleting file before continuing
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (distributionWorkflow) - ($itemId) - mmcFileDestination file exists - moving file to zMoved folder before continuing with script" >> "$logfile"

            mv -f "$mmcFileDestination" "/opt/olympusat/xmlsForDistribution/zMoved/"

            sleep 5
        else
            # mmcFileDestination file does NOT exists
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (distributionWorkflow) - ($itemId) - mmcFileDestination file does NOT exist" >> "$logfile"

            sleep 1
        fi

        # Check to see if mecFileDestination file exists
        if [[ -e "$mecFileDestination" ]];
        then
            # mecFileDestination file exists-deleting file before continuing
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (distributionWorkflow) - ($itemId) - mecFileDestination file exists - moving file to zMoved folder before continuing with script" >> "$logfile"

            mv -f "$mecFileDestination" "/opt/olympusat/xmlsForDistribution/zMoved/"

            sleep 5
        else
            # mecFileDestination file does NOT exists
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (distributionWorkflow) - ($itemId) - mecFileDestination file does NOT exist" >> "$logfile"

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

        echo "$(date +%Y/%m/%d_%H:%M:%S) - (distributionWorkflow) - ($itemId) - Item Id Xml - [$itemIdXml]" >> "$logfile"
        echo "$(date +%Y/%m/%d_%H:%M:%S) - (distributionWorkflow) - ($itemId) - Title - [$itemTitle]" >> "$logfile"
        echo "$(date +%Y/%m/%d_%H:%M:%S) - (distributionWorkflow) - ($itemId) - Original Filename - [$itemOriginalFilename]" >> "$logfile"
        echo "$(date +%Y/%m/%d_%H:%M:%S) - (distributionWorkflow) - ($itemId) - Distribution Language - [$itemDistributionLanguage]" >> "$logfile"
        echo "$(date +%Y/%m/%d_%H:%M:%S) - (distributionWorkflow) - ($itemId) - Language Code 1 - [$itemLanguageCode1]" >> "$logfile"
        echo "$(date +%Y/%m/%d_%H:%M:%S) - (distributionWorkflow) - ($itemId) - Language Code 2 - [$itemLanguageCode2]" >> "$logfile"

        # ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        # Creating MMC XML
        echo "$(date +%Y/%m/%d_%H:%M:%S) - (distributionWorkflow) - ($itemId) - Creating MMC XML for [$itemTitle]" >> "$logfile"

        # Adding Header
        echo "<manifest:MediaManifest xmlns:manifest="http://www.movielabs.com/schema/manifest/v1.8/manifest" xmlns:md="http://www.movielabs.com/schema/md/v2.7/md" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.movielabs.com/schema/manifest/v1.8/manifest manifest-v1.8.1.xsd" ManifestID="SofaSpud.Example" updateNum="1">" >> "$mmcFileDestination"

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
        <manifest:Audio AudioTrackID="md:audtrackid:org:olympusat:$itemIdXml:feature.audio.$itemLanguageCode2">
            <md:Type>primary</md:Type>
            <md:Language>$itemLanguageCode1</md:Language>
            <manifest:ContainerReference>
                <manifest:ContainerLocation>$itemOriginalFilename</manifest:ContainerLocation>
            </manifest:ContainerReference>
        </manifest:Audio>" >> "$mmcFileDestination"

        # Adding Video Block in Inventory Block
        echo "        <manifest:Video VideoTrackID="md:vidtrackid:org:olympusat:$itemIdXml:feature.video">
            <md:Type>primary</md:Type>
            <md:Picture></md:Picture>
            <manifest:ContainerReference>
                <manifest:ContainerLocation>$itemOriginalFilename</manifest:ContainerLocation>
            </manifest:ContainerReference>
        </manifest:Video>" >> "$mmcFileDestination"

        # Adding Metadata Block in Inventory Block
        echo "        <manifest:Metadata ContentID="md:cid:org:olympusat:$itemIdXml">
            <manifest:ContainerReference type="common">
                <manifest:ContainerLocation>MEC-$itemTitle.xml</manifest:ContainerLocation>
            </manifest:ContainerReference>
        </manifest:Metadata>" >> "$mmcFileDestination"

        # Adding Inventory Block Close
        echo "    </manifest:Inventory>" >> "$mmcFileDestination"

        # Adding Presentations Block Start
        echo "    <manifest:Presentations>" >> "$mmcFileDestination"

        # Adding Presentation Block in Presentations Block
        echo "        <!--   the main feature presentation   -->
        <manifest:Presentation PresentationID="md:presentationid:org:olympusat:$itemIdXml:feature.presentation">
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
        echo "        <manifest:Experience ExperienceID="md:experienceid:org:olympusat:$itemIdXml:experience" version="1.0">
            <manifest:ContentID>md:cid:org:olympusat:$itemIdXml</manifest:ContentID>
            <manifest:Audiovisual ContentID="md:cid:org:olympusat:$itemIdXml">
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

        # ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        
        # ----------------------------------------------------------------------
        # Creating MEC XML
        echo "$(date +%Y/%m/%d_%H:%M:%S) - (distributionWorkflow) - ($itemId) - Creating MEC XML for [$itemTitle]" >> "$logfile"



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
