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
  # Making API call to Cantemo to get file name
  headers = {
    'Accept': 'application/json'
  }
  payload = {}
  urlGetProfanitySegments = f"https://apis.prod.vionlabs.com/results/profanity/v1/segments/{cantemoItemId}?&key=kt8cyimHXxUzFNGyhd7c7g"
  httpApiResponse = requests.request("GET", urlGetProfanitySegments, headers=headers, data=payload)
  httpApiResponse.raise_for_status()
  #------------------------------

  #------------------------------
  # Parsing and POST JSON data
  responseJson = httpApiResponse.json()
  profanitySegment = responseJson["profanity"]
  # responseJson = json.loads(httpApiResponse.text)
  for individualSegment in profanitySegment["segments"]:
    startingTimecode = individualSegment["start"]
    endingTimecode = individualSegment["end"]
    profanityScore = individualSegment["score"]
    # segmentInformation = f"Segment timecodes: {startingSegment} - {endingSegment} - Profanity Score: {scoreSegment}\n"
    # segmentInformation = segmentInformation[:-1]
    segmentPayload = '{'+f"\n\t\"comment\": \"Profanity Score\": \""+str(profanityScore)+f"\",\n\t\"start_tc\": \""+str(startingTimecode)+f"\",\n\t\"end_tc\": \""+str(endingTimecode)+f"\"\n"+'}'
    # print(segmentPayload)
  
    #------------------------------
    # Update Cantemo metadata
    headers = {
      'Authorization': 'Basic YWRtaW46MTBsbXBAc0B0',
      'Cookie': 'csrftoken=OtjDQ4lhFt2wJjGaJhq3xi05z3uA6D8F7wCWNVXxMuJ8A9jw7Ri7ReqSNGLS2VRR',
      'Content-Type': 'application/json'
    }
    cantemoItemId = 'OLY-4463'
    urlPutProfanityInfo = f"http://10.1.1.34/API/v2/comments/item/{cantemoItemId}/"
    # payload = f"<MetadataDocument xmlns=\"http://xml.vidispine.com/schema/vidispine\"><timespan start=\"-INF\" end=\"+INF\"><field><name>oly_analysisReport</name><value>{responseJson}</value></field></timespan></MetadataDocument>"
    httpApiResponse = requests.request("POST", urlPutAnalysisInfo, headers=headers, data=segmentPayload)
    #------------------------------

except HTTPError as http_err:
    print(f'HTTP error occurred: {http_err}')
except Exception as err:
    print(f'Other error occurred: {err}')