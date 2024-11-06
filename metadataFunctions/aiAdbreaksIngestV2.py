# /opt/cantemo/python/bin/python
#!/usr/bin/python3

# This application ingests metadata from an XML API response into Cantemo
# PREREQUISITE: -none-
# 	Usage: aiAdbreaksIngestVx.py [Cantemo item ID]

#------------------------------
# Requirements
'''
TIMESTAMP GUIDELINES

1-FOR VOD/DISTRIBUTION we use ROKU guidelines:
-Movie ad policy:
No adBreaks should be listed during the first 10 minutes of playback
No pre-roll adBreak should be listed – 00:00:00.000
adBreak cue points should be provided at naturally occurring scene breaks and/or fades to black
There should be no less than 10 minutes between each adBreak
No adBreaks within 10 minutes of end credits

-Series episode ad policy
Content length longer than 15 minutes:
No adBreaks should be listed during the first 5 mins of playback
No pre-roll adBreak should be listed - 00:00:00
adBreak cue points should be provided at naturally occurring scene breaks and/or fades to black
There should be no less than 7 mins between each adBreak
No adBreaks within the last 5 minutes of end credits

2-FOR POPCORN MEXICO CHANNEL we use RTC(Mex government) guidelines:
-Files Less than 20min = 2 Segments
-Files 20min to 26min = 3 Segments
-Files 26min to 55min = 5 Segments
-Files 56min to 1h20min = 7 Segments
-Files 1h21min to 1h45min = 9 Segments
-Files longer than 1h45m. =10 Segments
(If a show- All episodes should be same amount of segments)
'''
#------------------------------

#------------------------------
# Libraries
import os
import glob
import sys
import datetime
import time
import subprocess
import xml.dom.minidom
import xml.etree.ElementTree as ET
import requests
import json
from requests.exceptions import HTTPError
from array import *
#------------------------------

#------------------------------
# Internal functions

def findSegments(fcfRankFrameList, fcfSegmentCount, fcfTargetFrames, fcfMinFrames, fcfIntroFrames, fcfEndFrame):
  rankTolerance = 3 # determine which "rank" result categories will be used
  breaksFound = [0 for x in range(fcfSegmentCount)]
  currentSegment = 1
  # print(f"{fcfEndFrame} - {fcfTargetFrames}, {currentSegment} - {fcfSegmentCount}")
  while ((fcfEndFrame - fcfTargetFrames) > 0) and (currentSegment < fcfSegmentCount):
    smallestDeviation = fcfEndFrame
    for i in range(1, (rankTolerance + 1), 1):
      for j in range(1, (fcfRankFrameList[i][0] +1), 1):
        segmentSize = fcfEndFrame - fcfRankFrameList[i][j]
        deviationFrames = abs(segmentSize - fcfTargetFrames)
        # print(f"{fcfEndFrame} - {fcfRankFrameList[i][j]}, Deviation: {deviationFrames}, Current closest maker: {smallestDeviation}, Segment size: {segmentSize}")
        if (deviationFrames < smallestDeviation) and (segmentSize > fcfMinFrames) and (fcfRankFrameList[i][j] > (fcfIntroFrames + fcfMinFrames)):
          smallestDeviation = deviationFrames
          breaksFound[currentSegment] = fcfRankFrameList[i][j]
    # setDurationSeconds = round((((fcfEndFrame - breaksFound[currentSegment]) * 1001) / 30000), 2)
    fcfEndFrame = breaksFound[currentSegment]
    # print(f"Ad frame using {breaksFound[currentSegment]} with segment duration {setDurationSeconds}")
    # print(f"End frame is now at frame {fcfEndFrame}")
    currentSegment += 1
  return breaksFound

def findSegmentsFromEnds(fseRankFrameList, fseSegmentCount, fseTargetFrames, fseMinFrames, fseIntroFrames, fseEndFrame):
  rankTolerance = 3 # determine which "rank" result categories will be used
  breaksFound = [0 for x in range(fseSegmentCount)]
  currentSegment = 1
  return breaksFound
#------------------------------

try:
  cantemoItemId = sys.argv[1]
  # cantemoItemId = os.environ.get("portal_itemId")
  errorReport = ''
  typeOne = "RTC_MX"
  typeTwo = "VOD"
  rowSize, columnSize = (5,50)
  breakCandidates = [[0 for x in range(columnSize)] for y in range(rowSize)]

  #------------------------------
  # Making API to Vidispine to get timebase
  headers = {
    'Authorization': 'Basic YWRtaW46MTBsbXBAc0B0',
    'Cookie': 'csrftoken=OtjDQ4lhFt2wJjGaJhq3xi05z3uA6D8F7wCWNVXxMuJ8A9jw7Ri7ReqSNGLS2VRR',
    'Accept': 'application/json'
  }
  urlGetTimebaseInfo = f"http://10.1.1.34:8080/API/item/{cantemoItemId}/metadata?field=startTimeCode,durationSeconds,oly_contentType&terse=yes&interval=generic"
  payload = {}
  httpApiResponse = requests.request("GET", urlGetTimebaseInfo, headers=headers, data=payload)
  httpApiResponse.raise_for_status()
  #------------------------------

  #------------------------------
  # Parsing JSON data for timebase
  responseJson = httpApiResponse.json() if httpApiResponse and httpApiResponse.status_code == 200 else None
  if responseJson and 'item' in responseJson:
    for itemInformation in responseJson['item']:
      for timecodeInformation in itemInformation['startTimeCode']:
        itemTimecode = timecodeInformation['value']
  timecodeComponents = itemTimecode.split('@', 2)
  itemTimebase = timecodeComponents[1]
  if not isinstance (itemTimebase, int):
    if itemTimebase == "NTSC30" or itemTimebase == "NTSC":
      itemTimebase = "NTSC"
      timebaseMultiplier = 30000 / 1001
      timebaseNumerator = 30000
      timebaseDenominator = 1001
    if itemTimebase == "PAL25" or itemTimebase == "PAL":
      itemTimebase = "PAL"
      timebaseMultiplier = 25
      timebaseNumerator = 25
      timebaseDenominator = 1
  #------------------------------

  #------------------------------
  # Gather information for the clip
  if responseJson and 'item' in responseJson:
    for itemInformation in responseJson['item']:
      for durationInformation in itemInformation['durationSeconds']:
        itemDuration = durationInformation['value']
      for contentInformation in itemInformation['oly_contentType']:
        contentType = contentInformation['value']
  
  itemDurationFrames = int(round(float(itemDuration) * float(timebaseMultiplier), 0))
  if itemDurationFrames < 35964:
    rtcSegmentCount = 2
  elif itemDurationFrames < 46753:
    rtcSegmentCount = 3
  elif itemDurationFrames < 98901:
    rtcSegmentCount = 5
  elif itemDurationFrames < 143856:
    rtcSegmentCount = 7
  elif itemDurationFrames < 188811:
    rtcSegmentCount = 9
  else:
    segmentCount = 10
  print(f"This item is processed as a {contentType}")
  print(f"Total duration: {itemDurationFrames} frames")
  print(f"Segments needed (for {typeOne}): {rtcSegmentCount}")
  targetSegmentFrames = int(round(itemDurationFrames / rtcSegmentCount, 0))
  print(f"Target segment size (for {typeOne}): {targetSegmentFrames} frames")
  #------------------------------

  #------------------------------
  # Making API call to Vionlabs to get intro ending and end credits
  headers = {
    'Accept': 'application/json'
  }
  payload = {}
  urlGetAdBreakMarkers = f"https://apis.prod.vionlabs.com/results/markers/v1/asset/{cantemoItemId}?&key=kt8cyimHXxUzFNGyhd7c7g"
  httpApiResponse = requests.request("GET", urlGetAdBreakMarkers, headers=headers, data=payload)
  httpApiResponse.raise_for_status()
  #------------------------------
  
  #------------------------------
  # Parsing and POST JSON data
  responseJson = httpApiResponse.json()
  creditStartTime = responseJson["credit_start"]
  creditStartFrame = int(round(((creditStartTime * 30000) / 1001), 0))
  introEndTime = responseJson["intro_end"]
  if introEndTime:
    introEndFrame = int(round(((introEndTime * 30000) / 1001), 0))
  else:
    introEndFrame = 0
  #------------------------------
  
  #------------------------------
  # Making API call to Vionlabs to find possible ad break locations
  headers = {
    'Accept': 'application/json'
  }
  payload = {}
  urlGetAdbreaksSegments = f"https://apis.prod.vionlabs.com/results/adbreaks/v2/filter/frame/{cantemoItemId}?&key=kt8cyimHXxUzFNGyhd7c7g"
  # urlGetAdbreaksSegments = f"https://apis.prod.vionlabs.com/results/adbreaks/v2/filter/frame/OLT-003?&key=kt8cyimHXxUzFNGyhd7c7g"
  httpApiResponse = requests.request("GET", urlGetAdbreaksSegments, headers=headers, data=payload)
  httpApiResponse.raise_for_status()
  #------------------------------
  
  #------------------------------
  # Parsing and POST JSON data for TYPE 1
  if contentType == "movie" or contentType == "episode":
    responseJson = httpApiResponse.json()
    for adbreakSegment in responseJson["adbreak"]:
      rankingSegment = adbreakSegment["rank"]
      indexCounter = 1
      for candidateSegment in adbreakSegment["candidates"]:
        breakCandidates[rankingSegment][indexCounter] = candidateSegment
        # print(f"breakCandidates ({rankingSegment}, {indexCounter}) contain value: {breakCandidates[rankingSegment][indexCounter]}")
        indexCounter += 1
        breakCandidates[rankingSegment][0] = indexCounter
    typeOneSegmentList = findSegments(breakCandidates, rtcSegmentCount, targetSegmentFrames, 0, targetSegmentFrames, creditStartFrame)
    for i in typeOneSegmentList:
      if i != 0:
        candidateTimecode = int(i)
        endingTimecode = int(i + 10)
        segmentPayload = json.dumps([
          {
            "start": {
              "frame": candidateTimecode,
              "numerator": timebaseNumerator,
              "denominator": timebaseDenominator
            },
            "end": {
              "frame": endingTimecode,
              "numerator": timebaseNumerator,
              "denominator": timebaseDenominator
            },
            "type": "AvAdBreak",
            "metadata": [
            {
              "key": "title",
              "value": "Ad Break"
            },
            {
              "key": "av_marker_description",
              "value": typeOne
            },
            {
              "key": "av_marker_track_id",
              "value": "AvAdBreak"
            },
            {
              "key": "ad_break_type",
              "value": "av:adbreak:marker:break"
            }
            ],
            "assetId": '"'+cantemoItemId+'"'
          }
        ])
        #------------------------------
        # Update Cantemo metadata
        headers = {
          'Authorization': 'Basic YWRtaW46MTBsbXBAc0B0',
          'Cookie': 'csrftoken=obqpl1uZPs93ldSOFjsRbk2bL25JxPgBOb8t1zUH20fP0tUEdXNNjrYO8kzeOSah',
          'Content-Type': 'application/json'
        }
        urlPutAdBreakMarkers = f"http://10.1.1.34/AVAPI/asset/{cantemoItemId}/timespan/bulk"
        httpApiResponse = requests.request("PUT", urlPutAdBreakMarkers, headers=headers, data=segmentPayload)
        httpApiResponse.raise_for_status()
        time.sleep(5)
        #------------------------------

  #------------------------------
  # Parsing and POST JSON data for TYPE 2
  if contentType == "movie":
    minDistributionSegmentMinutes = 10
    minDistributionSegmentFrames = int((minDistributionSegmentMinutes * 60 * 30000) / 1001)
    vodSegmentCount = int(round((itemDurationFrames / minDistributionSegmentFrames), 0))
    typeTwoSegmentList = findSegments(breakCandidates, vodSegmentCount, minDistributionSegmentFrames, minDistributionSegmentFrames, minDistributionSegmentFrames, creditStartFrame)
  elif contentType == "episode":
    minDistributionSegmentMinutes = 7
    minDistributionSegmentFrames = int((minDistributionSegmentMinutes * 60 * 30000) / 1001)
    vodSegmentCount = int(round((itemDurationFrames / minDistributionSegmentFrames), 0))
    typeTwoSegmentList = findSegments(breakCandidates, vodSegmentCount, minDistributionSegmentFrames, minDistributionSegmentFrames, introEndFrame, creditStartFrame)
  if typeTwoSegmentList:
    print(f"Maximum segment count (for {typeTwo}): {vodSegmentCount}")
    print(f"Minimum segment size (for {typeTwo}): {minDistributionSegmentFrames} frames")
    for i in typeTwoSegmentList:
      if i != 0:
        candidateTimecode = int(i)
        endingTimecode = int(i + 10)
        segmentPayload = json.dumps([
          {
            "start": {
              "frame": candidateTimecode,
              "numerator": timebaseNumerator,
              "denominator": timebaseDenominator
            },
            "end": {
              "frame": endingTimecode,
              "numerator": timebaseNumerator,
              "denominator": timebaseDenominator
            },
            "type": "AvAdBreak",
            "metadata": [
            {
              "key": "title",
              "value": "Ad Break"
            },
            {
              "key": "av_marker_description",
              "value": typeTwo
            },
            {
              "key": "av_marker_track_id",
              "value": "AvAdBreak"
            },
            {
              "key": "ad_break_type",
              "value": "av:adbreak:marker:break"
            }
            ],
            "assetId": '"'+cantemoItemId+'"'
          }
        ])
        #------------------------------
        # Update Cantemo metadata
        httpApiResponse = requests.request("PUT", urlPutAdBreakMarkers, headers=headers, data=segmentPayload)
        httpApiResponse.raise_for_status()
        time.sleep(5)
        #------------------------------


  #------------------------------
  headers = {
  'Authorization': 'Basic YWRtaW46MTBsbXBAc0B0',
  'Cookie': 'csrftoken=HFOqrbk9cGt3qnc6WBIxWPjvCFX0udBdbJnzCv9jECumOjfyG7SS2lgVbFcaHBCc',
  'Content-Type': 'application/xml'
  }
  urlPutAnalysisStatusInfo = f"http://10.1.1.34:8080/API/item/{cantemoItemId}/metadata/"
  statusRawPayload = f"<MetadataDocument xmlns=\"http://xml.vidispine.com/schema/vidispine\"><timespan start=\"-INF\" end=\"+INF\"><field><name>oly_analysisStatus</name><value>completed - last request - adbreak</value></field></timespan></MetadataDocument>"
  parsedStatusPayload = xml.dom.minidom.parseString(statusRawPayload)
  statusPayload = parsedStatusPayload.toprettyxml()
  httpApiResponse = requests.request("PUT", urlPutAnalysisStatusInfo, headers=headers, data=statusPayload)
  #------------------------------

except HTTPError as http_err:
    print(f'HTTP error occurred: {http_err}')
except Exception as err:
    print(f'Other error occurred: {err}')