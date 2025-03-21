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
  # responseJson = json.loads(httpApiResponse.text)
  responseJson = httpApiResponse.json() if httpApiResponse and httpApiResponse.status_code == 200 else None
  # print(type(responseJson))
  # print(type(responseJson["item"]))
  # print(responseJson["item"])
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
    if itemTimebase == "PAL25" or itemTimebase == "PAL":
      itemTimebase = "PAL"
      timebaseMultiplier = 25
  # cantemoItemId = 'OLT-003'
  
  #------------------------------
  # Making API call to Vionlabs to find possible profanity locations
  headers = {
    'Accept': 'application/json'
  }
  payload = {}
  # urlGetProfanitySegments = f"https://apis.prod.vionlabs.com/results/profanity/v1/segments/{cantemoItemId}?&key=kt8cyimHXxUzFNGyhd7c7g"
  urlGetProfanitySegments = f"https://apis.prod.vionlabs.com/results/profanity/v1/segments/OLT-003?&key=kt8cyimHXxUzFNGyhd7c7g"
  httpApiResponse = requests.request("GET", urlGetProfanitySegments, headers=headers, data=payload)
  httpApiResponse.raise_for_status()
  #------------------------------

  #------------------------------
  # Parsing and POST JSON data
  responseJson = httpApiResponse.json()
  profanitySegment = responseJson["profanity"]
  # responseJson = json.loads(httpApiResponse.text)
  for individualSegment in profanitySegment["segments"]:
    profanityScore = individualSegment["score"]
    profanityScore *= 100
    profanityScore = round(profanityScore, 2)
    if profanityScore >= 70:
      startingTimecode = int(individualSegment["start"] * timebaseMultiplier)
      endingTimecode = int(individualSegment["end"] * timebaseMultiplier)
      # endingTimecode = int(individualSegment["end"]) * (30000 / 1001)
      # segmentInformation = f"Segment timecodes: {startingSegment} - {endingSegment} - Profanity Score: {scoreSegment}\n"
      # segmentInformation = segmentInformation[:-1]
      # segmentString = '{'+f"\n\t\"comment\": \"Profanity Score "+str(profanityScore)+f"\",\n\t\"start_tc\": \""+str(startingTimecode)+f"@{itemTimebase}\",\n\t\"end_tc\": \""+str(endingTimecode)+f"@{itemTimebase}\"\n"+'}'
      segmentPayload = '{"comment": "Profanity level '+str(profanityScore)+' of 100", "start_tc": "'+str(startingTimecode)+f"@{itemTimebase}"+'", "end_tc": "'+str(endingTimecode)+f"@{itemTimebase}"+'"}'
      # segmentPayload = json.dumps(segmentString)
      # print(segmentString)
      # print(segmentPayload)
      # print(segmentPayload)

      #------------------------------
      # Update Cantemo metadata
      headers = {
        'Authorization': 'Basic YWRtaW46MTBsbXBAc0B0',
        'Cookie': 'csrftoken=6TSbOVYmsDD9ORWkUOkqgcXZ1IMetgInzZ96EcWJ048jMUNqD4nhNcqmrFapF8Sa',
        'Content-Type': 'application/json'
      }
      urlPutProfanityInfo = f"http://10.1.1.34/API/v2/comments/item/{cantemoItemId}/"
      # payload = f"<MetadataDocument xmlns=\"http://xml.vidispine.com/schema/vidispine\"><timespan start=\"-INF\" end=\"+INF\"><field><name>oly_analysisReport</name><value>{responseJson}</value></field></timespan></MetadataDocument>"
      httpApiResponse = requests.request("POST", urlPutProfanityInfo, headers=headers, data=segmentPayload)
      httpApiResponse.raise_for_status()
      print(httpApiResponse.text)
      time.sleep(5)
      #------------------------------
  #------------------------------

except HTTPError as http_err:
    print(f'HTTP error occurred: {http_err}')
except Exception as err:
    print(f'Other error occurred: {err}')