# /opt/cantemo/python/bin/python
#!/usr/bin/python3

# This application ingests metadata from an XML API response into Cantemo
# PREREQUISITE: -none-
# 	Usage: aiFingerprintIngest.py [full file path of the XML file

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
  outputFPFile = f"/mnt/c/Users/kkanjanapitak/Desktop/{cantemoItemId}_FP.json"
  #------------------------------
  # Making API call to Vionlabs to get fingerprints
  headers = {
    'Accept': 'application/json'
  }
  payload = {}
  # urlGetProfanitySegments = f"https://apis.prod.vionlabs.com/results/fingerprintplus/v1/{cantemoItemId}?&key=kt8cyimHXxUzFNGyhd7c7g"
  urlGetProfanitySegments = f"https://apis.prod.vionlabs.com/results/fingerprintplus/v1/OLT-003?&key=kt8cyimHXxUzFNGyhd7c7g"
  httpApiResponse = requests.request("GET", urlGetProfanitySegments, headers=headers, data=payload)
  httpApiResponse.raise_for_status()
  #------------------------------
  responseFile = open(outputFPFile, "wb")
  responseFile.write(httpApiResponse.content, indent=2)
  responseFile.close()
  #------------------------------
  # Parsing and POST JSON data
  responseJson = httpApiResponse.json()
  # profanitySegment = responseJson["genre"]
  for individualGenre in responseJson["genre"]:
    print(individualGenre)
    
      #------------------------------
      # Update Cantemo metadata
      # headers = {
      #   'Authorization': 'Basic YWRtaW46MTBsbXBAc0B0',
      #   'Cookie': 'csrftoken=obqpl1uZPs93ldSOFjsRbk2bL25JxPgBOb8t1zUH20fP0tUEdXNNjrYO8kzeOSah',
      #   'Content-Type': 'application/json'
      # }
      # urlPutProfanityInfo = f"http://10.1.1.34/AVAPI/asset/{cantemoItemId}/timespan/bulk"
      # httpApiResponse = requests.request("PUT", urlPutProfanityInfo, headers=headers, data=segmentPayload)
      # httpApiResponse.raise_for_status()
      # print(httpApiResponse.text)
      # time.sleep(5)
      #------------------------------
  #------------------------------

except HTTPError as http_err:
    print(f'HTTP error occurred: {http_err}')
except Exception as err:
    print(f'Other error occurred: {err}')