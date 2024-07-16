# /opt/cantemo/python/bin/python
#!/usr/bin/python3

# This application ingests metadata from an XML API response into Cantemo
# PREREQUISITE: -none-
# 	Usage: aiBingeMarkersIngestVx.py [

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
  urlGetBingeMarkers = f"https://apis.prod.vionlabs.com/results/markers/v1/asset/{cantemoItemId}?&key=kt8cyimHXxUzFNGyhd7c7g"
  httpApiResponse = requests.request("GET", urlGetBingeMarkers, headers=headers, data=payload)
  httpApiResponse.raise_for_status()
  #------------------------------

  #------------------------------
  # Parsing and POST JSON data
  responseJson = httpApiResponse.json()
  introStartTimecode = responseJson["intro_start"]
  introEndTimecode = responseJson["intro_end"]
  recapStartTimecode = responseJson["recap_start"]
  recapEndTimecode = responseJson["recap_end"]
  creditStartTimecode = responseJson["credit_start"]
  creditEndTimecode = responseJson["credit_end"]
  # print(f"{introStartTimecode}, {introEndTimecode}, {recapStartTimecode}, {recapEndTimecode}, {creditStartTimecode}, {creditEndTimecode}")
  headers = {
      'Authorization': 'Basic YWRtaW46MTBsbXBAc0B0',
      'Cookie': 'csrftoken=obqpl1uZPs93ldSOFjsRbk2bL25JxPgBOb8t1zUH20fP0tUEdXNNjrYO8kzeOSah',
      'Content-Type': 'application/json'
    }
  urlPutBingeMarkerInfo = f"http://10.1.1.34/AVAPI/asset/{cantemoItemId}/timespan/bulk"

  if not introStartTimecode and not introEndTimecode:
    # segmentPayload = '{"comment": "Profanity level '+str(profanityScore)+' of 100", "start_tc": "'+str(startingTimecode)+f"@{itemTimebase}"+'", "end_tc": "'+str(endingTimecode)+f"@{itemTimebase}"+'"}'
    segmentPayload = json.dumps([
      {
        "start": {
        "frame": introStartTimecode,
        "numerator": timebaseNumerator,
        "denominator": timebaseDenominator
      },
      "end": {
        "frame": introEndTimecode,
        "numerator": timebaseNumerator,
        "denominator": timebaseDenominator
      },
      "type": "AvMarker",
      "metadata": [
        {
          "key": "av_marker_description",
          "value": "Intro Segment"
        },
        {
          "key": "title",
          "value": "Intro"
        },
        {
          "key": "av_marker_track_id",
          "value": "av:track:info"
        }
      ],
      "assetId": '"'+cantemoItemId+'"'
    }
  ])
    
    #------------------------------
    # Update Cantemo metadata
    httpApiResponse = requests.request("PUT", urlPutBingeMarkerInfo, headers=headers, data=segmentPayload)
    httpApiResponse.raise_for_status()
    print(httpApiResponse.text)
    time.sleep(5)
    #------------------------------

  if not recapStartTimecode and not recapEndTimecode:
    segmentPayload = json.dumps([
      {
        "start": {
        "frame": recapStartTimecode,
        "numerator": timebaseNumerator,
        "denominator": timebaseDenominator
      },
      "end": {
        "frame": recapEndTimecode,
        "numerator": timebaseNumerator,
        "denominator": timebaseDenominator
      },
      "type": "AvMarker",
      "metadata": [
        {
          "key": "av_marker_description",
          "value": "Recap Segment"
        },
        {
          "key": "title",
          "value": "Recap"
        },
        {
          "key": "av_marker_track_id",
          "value": "av:track:info"
        }
      ],
      "assetId": '"'+cantemoItemId+'"'
    }
  ])
    
    #------------------------------
    # Update Cantemo metadata
    httpApiResponse = requests.request("PUT", urlPutBingeMarkerInfo, headers=headers, data=segmentPayload)
    httpApiResponse.raise_for_status()
    print(httpApiResponse.text)
    time.sleep(5)
    #------------------------------

  if not creditStartTimecode and not creditEndTimecode:
    segmentPayload = json.dumps([
      {
        "start": {
        "frame": creditStartTimecode,
        "numerator": timebaseNumerator,
        "denominator": timebaseDenominator
      },
      "end": {
        "frame": creditEndTimecode,
        "numerator": timebaseNumerator,
        "denominator": timebaseDenominator
      },
      "type": "AvMarker",
      "metadata": [
        {
          "key": "av_marker_description",
          "value": "Credit Segment"
        },
        {
          "key": "title",
          "value": "Credit"
        },
        {
          "key": "av_marker_track_id",
          "value": "av:track:info"
        }
      ],
      "assetId": '"'+cantemoItemId+'"'
    }
  ])
    
    #------------------------------
    # Update Cantemo metadata
    httpApiResponse = requests.request("PUT", urlPutBingeMarkerInfo, headers=headers, data=segmentPayload)
    httpApiResponse.raise_for_status()
    print(httpApiResponse.text)
    time.sleep(5)
    #------------------------------

  headers = {
  'Authorization': 'Basic YWRtaW46MTBsbXBAc0B0',
  'Cookie': 'csrftoken=HFOqrbk9cGt3qnc6WBIxWPjvCFX0udBdbJnzCv9jECumOjfyG7SS2lgVbFcaHBCc',
  'Content-Type': 'application/xml'
  }
  urlPutAnalysisStatusInfo = f"http://10.1.1.34:8080/API/item/{cantemoItemId}/metadata/"
  statusRawPayload = f"<MetadataDocument xmlns=\"http://xml.vidispine.com/schema/vidispine\"><timespan start=\"-INF\" end=\"+INF\"><field><name>oly_analysisStatus</name><value>completed - last request - binge marker</value></field></timespan></MetadataDocument>"
  parsedStatusPayload = xml.dom.minidom.parseString(statusRawPayload)
  statusPayload = parsedStatusPayload.toprettyxml()
  httpApiResponse = requests.request("PUT", urlPutAnalysisStatusInfo, headers=headers, data=statusPayload)
  
  #------------------------------

except HTTPError as http_err:
    print(f'HTTP error occurred: {http_err}')
except Exception as err:
    print(f'Other error occurred: {err}')