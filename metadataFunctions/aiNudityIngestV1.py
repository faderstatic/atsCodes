# /opt/cantemo/python/bin/python
#!/usr/bin/python3

# This application ingests metadata from an XML API response into Cantemo
# PREREQUISITE: -none-
# 	Usage: aiNudityIngest.py [cantemo ID] [nudity level 1-100] [acceptable gap between clips in frames]

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
#------------------------------

#------------------------------
# Internal Functions

def updateCantemoMarkers(ucmId, ucmStartFrame, ucmEndFrame, ucmTbNumerator, ucmTbDenominator, ucmNudeLevel, ucmNudeLabel):
  ucmSegmentPayload = json.dumps([
    {
      "start": {
      "frame": ucmStartFrame,
      "numerator": ucmTbNumerator,
      "denominator": ucmTbDenominator
      },
      "end": {
      "frame": ucmEndFrame,
      "numerator": ucmTbNumerator,
      "denominator": ucmTbDenominator
      },
      "type": "AvMarker",
      "metadata": [
        {
          "key": "av_marker_description",
          "value": '"'+str(ucmNudeLevel)+'% Nudity Probability - '+ucmNudeLabel+'"'
        },
        {
          "key": "title",
          "value": "Nudity"
        },
        {
          "key": "av_marker_track_id",
          "value": "av:track:video:issues"
        }
      ],
      "assetId": '"'+ucmId+'"'
    }
  ])
  #------------------------------
  # Update Cantemo metadata
  ucmHeaders = {
    'Authorization': 'Basic YWRtaW46MTBsbXBAc0B0',
    'Cookie': 'csrftoken=obqpl1uZPs93ldSOFjsRbk2bL25JxPgBOb8t1zUH20fP0tUEdXNNjrYO8kzeOSah',
    'Content-Type': 'application/json'
  }
  ucmUrlPutNudityInfo = f"http://10.1.1.34/AVAPI/asset/{ucmId}/timespan/bulk"
  httpApiResponse = requests.request("PUT", ucmUrlPutNudityInfo, headers=ucmHeaders, data=ucmSegmentPayload)
  httpApiResponse.raise_for_status()
  time.sleep(3)
  # print(httpApiResponse.text)
  #------------------------------

try:
  cantemoItemId = sys.argv[1]
  # cantemoItemId = os.environ.get("portal_itemId")
  errorReport = ''
  nudityThresholdDesignation = sys.argv[2]
  nudityThreshold = int(nudityThresholdDesignation)
  nudityEndFramePrev = 0
  nudityStartFramePrev = 0
  gapThresholdDesignation = sys.argv[3]
  gapThreshold = int(gapThresholdDesignation)
  nudityLevel = 0
  nudityLevelPrev = 0
  nuditySceneCount = 0
  segmentCompletion = "close"
  updateCantemoFlag = "true"

  #------------------------------
  # Making API to Vidispine to get timebase
  headers = {
    'Authorization': 'Basic YWRtaW46MTBsbXBAc0B0',
    'Cookie': 'csrftoken=OtjDQ4lhFt2wJjGaJhq3xi05z3uA6D8F7wCWNVXxMuJ8A9jw7Ri7ReqSNGLS2VRR',
    'Accept': 'application/json'
  }
  urlGetTimebaseInfo = f"http://10.1.1.34:8080/API/item/{cantemoItemId}/metadata?field=startTimeCode&terse=yes"
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
  # Making API call to Vionlabs to find possible nudity locations
  headers = {
    'Accept': 'application/json'
  }
  payload = {}
  urlGetNuditySegments = f"https://apis.prod.vionlabs.com/results/nudity/v1/frames/{cantemoItemId}?&key=kt8cyimHXxUzFNGyhd7c7g"
  httpApiResponse = requests.request("GET", urlGetNuditySegments, headers=headers, data=payload)
  httpApiResponse.raise_for_status()
  #------------------------------

  #------------------------------
  # Parsing and POST JSON data
  responseJson = httpApiResponse.json()
  for nuditySegment in responseJson:
    nudityScore = nuditySegment["score"]
    nudityScore *= 100
    nudityScore = round(nudityScore, 2)
    if nudityScore >= nudityThreshold:
      segmentStartFrame = int(nuditySegment["frame_number"])
      nudityLabel = nuditySegment["label"]
      if nudityLevel < nudityScore:
        nudityLevel = nudityScore
      if segmentCompletion == "close":
        nudityStartFrame = segmentStartFrame
        gapDuration = (nudityStartFrame - nudityEndFramePrev)
        if gapDuration > gapThreshold and nuditySceneCount:
          if nudityLevelPrev > nudityLevel:
            nudityLevel = nudityLevelPrev
            nudityLevelPrev = 0
          if updateCantemoFlag == "true":
            updateCantemoMarkers(cantemoItemId, nudityStartFramePrev, nudityEndFramePrev, timebaseNumerator, timebaseDenominator, nudityLevel, nudityLabel)
          else:
            print(f"Segment info: {nudityStartFramePrev}, {nudityEndFramePrev}, {gapDuration} - {nudityLevel}/{nudityLabel}")
        elif nuditySceneCount:
          nudityStartFrame = nudityStartFramePrev
      segmentCompletion = "open"
    elif segmentCompletion == "open":
      nudityEndFrame = int(nuditySegment["frame_number"])
      segmentCompletion = "close"
      nudityStartFramePrev = nudityStartFrame
      nudityEndFramePrev = nudityEndFrame
      nudityLevelPrev = nudityLevel
      nudityLevel = 0
      nuditySceneCount += 1

  if updateCantemoFlag == "true":
    headers = {
    'Authorization': 'Basic YWRtaW46MTBsbXBAc0B0',
    'Cookie': 'csrftoken=HFOqrbk9cGt3qnc6WBIxWPjvCFX0udBdbJnzCv9jECumOjfyG7SS2lgVbFcaHBCc',
    'Content-Type': 'application/xml'
    }
    urlPutAnalysisStatusInfo = f"http://10.1.1.34:8080/API/item/{cantemoItemId}/metadata/"
    statusRawPayload = f"<MetadataDocument xmlns=\"http://xml.vidispine.com/schema/vidispine\"><timespan start=\"-INF\" end=\"+INF\"><field><name>oly_analysisStatus</name><value>completed - last request - nudity</value></field></timespan></MetadataDocument>"
    parsedStatusPayload = xml.dom.minidom.parseString(statusRawPayload)
    statusPayload = parsedStatusPayload.toprettyxml()
    httpApiResponse = requests.request("PUT", urlPutAnalysisStatusInfo, headers=headers, data=statusPayload)

  if updateCantemoFlag == "true":
    updateCantemoMarkers(cantemoItemId, nudityStartFramePrev, nudityEndFramePrev, timebaseNumerator, timebaseDenominator, nudityLevelPrev, nudityLabel)
  else:
    print(f"Segment info: {nudityStartFramePrev}, {nudityEndFramePrev}, {gapDuration} - {nudityLevelPrev}/{nudityLabel}")
  
  #------------------------------

except HTTPError as http_err:
    print(f'HTTP error occurred: {http_err}')
except Exception as err:
    print(f'Other error occurred: {err}')