# /opt/cantemo/python/bin/python
#!/usr/bin/python3

# This application ingests metadata from an XML API response into Cantemo
# PREREQUISITE: -none-
# 	Usage: aiAdbreaksIngest.py [full file path of the XML file

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
  urlGetAdbreaksSegments = f"https://apis.prod.vionlabs.com/results/adbreaks/v2/filter/frame/{cantemoItemId}?&key=kt8cyimHXxUzFNGyhd7c7g"
  # urlGetAdbreaksSegments = f"https://apis.prod.vionlabs.com/results/adbreaks/v2/filter/frame/OLT-003?&key=kt8cyimHXxUzFNGyhd7c7g"
  httpApiResponse = requests.request("GET", urlGetAdbreaksSegments, headers=headers, data=payload)
  httpApiResponse.raise_for_status()
  #------------------------------

  #------------------------------
  # Parsing and POST JSON data
  responseJson = httpApiResponse.json()
  for adbreakSegment in responseJson["adbreak"]:
    rankingSegment = adbreakSegment["rank"]
    # print(rankingSegment)
    for candidateSegment in adbreakSegment["candidates"]:
      # print(candidateSegment)
      candidateTimecode = int(candidateSegment)
      endingTimecode = int(candidateSegment + 10)
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
            "key": "av_marker_description",
            "value": '"Rank '+str(rankingSegment)+'"'
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
      # print(segmentPayload)
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
      # print(httpApiResponse.text)
      time.sleep(5)
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