# /opt/cantemo/python/bin/python
#!/usr/bin/python3

# This application ingests metadata from an XML API response into Cantemo
# PREREQUISITE: -none-
# 	Usage: aiProfanityIngest.py [full file path of the XML file

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

try:
  cantemoItemId = sys.argv[1]
  # cantemoItemId = os.environ.get("portal_itemId")
  errorReport = ''
  profanityThreshold = 72

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
  # Making API call to Vionlabs to find possible profanity locations
  headers = {
    'Accept': 'application/json'
  }
  payload = {}
  urlGetProfanitySegments = f"https://apis.prod.vionlabs.com/results/profanity/v1/segments/{cantemoItemId}?&key=kt8cyimHXxUzFNGyhd7c7g"
  # urlGetProfanitySegments = f"https://apis.prod.vionlabs.com/results/profanity/v1/segments/OLT-003?&key=kt8cyimHXxUzFNGyhd7c7g"
  httpApiResponse = requests.request("GET", urlGetProfanitySegments, headers=headers, data=payload)
  httpApiResponse.raise_for_status()
  #------------------------------

  #------------------------------
  # Parsing and POST JSON data
  responseJson = httpApiResponse.json()
  profanitySegment = responseJson["profanity"]
  for individualSegment in profanitySegment["segments"]:
    profanityScore = individualSegment["score"]
    profanityScore *= 100
    profanityScore = round(profanityScore, 2)
    if profanityScore >= profanityThreshold:
      startingTimecode = int(individualSegment["start"] * timebaseMultiplier)
      endingTimecode = int(individualSegment["end"] * timebaseMultiplier)
      # segmentPayload = '{"comment": "Profanity level '+str(profanityScore)+' of 100", "start_tc": "'+str(startingTimecode)+f"@{itemTimebase}"+'", "end_tc": "'+str(endingTimecode)+f"@{itemTimebase}"+'"}'
      segmentPayload = json.dumps([
        {
          "start": {
          "frame": startingTimecode,
          "numerator": timebaseNumerator,
          "denominator": timebaseDenominator
        },
        "end": {
          "frame": endingTimecode,
          "numerator": timebaseNumerator,
          "denominator": timebaseDenominator
        },
        "type": "AvMarker",
        "metadata": [
          {
            "key": "av_marker_description",
            "value": '"Profanity level '+str(profanityScore)+' of 100"'
          },
          {
            "key": "title",
            "value": "Profanity"
          },
          {
            "key": "av_marker_track_id",
            "value": "av:track:audio:issues"
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
      urlPutProfanityInfo = f"http://10.1.1.34/AVAPI/asset/{cantemoItemId}/timespan/bulk"
      httpApiResponse = requests.request("PUT", urlPutProfanityInfo, headers=headers, data=segmentPayload)
      httpApiResponse.raise_for_status()
      print(httpApiResponse.text)
      time.sleep(3)
      #------------------------------

  headers = {
  'Authorization': 'Basic YWRtaW46MTBsbXBAc0B0',
  'Cookie': 'csrftoken=HFOqrbk9cGt3qnc6WBIxWPjvCFX0udBdbJnzCv9jECumOjfyG7SS2lgVbFcaHBCc',
  'Content-Type': 'application/xml'
  }
  urlPutAnalysisStatusInfo = f"http://10.1.1.34:8080/API/item/{cantemoItemId}/metadata/"
  statusRawPayload = f"<MetadataDocument xmlns=\"http://xml.vidispine.com/schema/vidispine\"><timespan start=\"-INF\" end=\"+INF\"><field><name>oly_analysisStatus</name><value>completed - last request - profanity</value></field></timespan></MetadataDocument>"
  parsedStatusPayload = xml.dom.minidom.parseString(statusRawPayload)
  statusPayload = parsedStatusPayload.toprettyxml()
  httpApiResponse = requests.request("PUT", urlPutAnalysisStatusInfo, headers=headers, data=statusPayload)
  
  #------------------------------

except HTTPError as http_err:
    print(f'HTTP error occurred: {http_err}')
except Exception as err:
    print(f'Other error occurred: {err}')