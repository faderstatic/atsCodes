# /opt/cantemo/python/bin/python
# /usr/local/bin/python3
#!/usr/bin/python3

# This application ingests metadata from an XML API response into Cantemo
# PREREQUISITE: -none-
# 	Usage: mediaManagerWorkflow-metadataWorkflow_v1.0.py [Cantemo ItemID]

#------------------------------
# Libraries
import os
import os.path
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

#------------------------------

#------------------------------

try:
  cantemoItemId = sys.argv[1]
  userName = sys.argv[2]
  metadataStatus = sys.argv[3]
  assignedTo = sys.argv[4]
  
  metadataFields = 'oly_metadataAssignedTo,oly_metadataStatus,oly_metadataBy,oly_metadataDate'
  metadataGroupName = 'Ingest'

  headers = {
    'Authorization': 'Basic YWRtaW46MTBsbXBAc0B0',
    'Cookie': 'csrftoken=OtjDQ4lhFt2wJjGaJhq3xi05z3uA6D8F7wCWNVXxMuJ8A9jw7Ri7ReqSNGLS2VRR',
    'Accept': 'application/json'
  }
  urlGetSubgroupInfo = f"http://10.1.1.34:8080/API/item/{cantemoItemId}/metadata?field={metadataFields}&group={metadataGroupName}"
  payload = {}
  httpApiResponse = requests.request("GET", urlGetSubgroupInfo, headers=headers, data=payload)
  httpApiResponse.raise_for_status()
  #------------------------------

  #------------------------------
  # Parsing JSON data for subgroup metadata values
  responseJson = httpApiResponse.json() if httpApiResponse and httpApiResponse.status_code == 200 else None
  if responseJson and 'item' in responseJson:
    for itemInformation in responseJson['item']:
      metadataInformation = itemInformation['metadata']
      for timespanInformation in metadataInformation['timespan']:
        for groupInformation in timespanInformation['group']:
          for fieldInformation in groupInformation['field']:
            if fieldInformation['name'] == 'oly_metadataAssignedTo':
              for assignmentInformation in fieldInformation['value']:
                assignmentMetadata = assignmentInformation['value']
                print(f"{assignmentMetadata} - ", end="")
            elif fieldInformation['name'] == 'oly_metadataStatus':
              for assignmentInformation in fieldInformation['value']:
                assignmentStatus = assignmentInformation['value']
                print(f"{assignmentStatus}")

  '''
  if not os.path.isfile(outputFPFile):
    #------------------------------
    # Making API call to Vionlabs to get fingerprints
    headers = {
      'Accept': 'application/json'
    }
    payload = {}
    urlGetFingerprintPlus = f"https://apis.prod.vionlabs.com/results/fingerprintplus/v1/{cantemoItemId}?&key=kt8cyimHXxUzFNGyhd7c7g"
    # urlGetProfanitySegments = f"https://apis.prod.vionlabs.com/results/fingerprintplus/v1/OLT-003?&key=kt8cyimHXxUzFNGyhd7c7g"
    httpApiResponse = requests.request("GET", urlGetFingerprintPlus, headers=headers, data=payload)
    httpApiResponse.raise_for_status()
    responseJson = httpApiResponse.json()
    #------------------------------
    # Writing response data to a file
    apiResponseJson = json.loads(httpApiResponse.text)
    apiResponseJsonFormat = json.dumps(apiResponseJson, indent=2)
    responseWriting = open(outputFPFile, "w")
    responseWriting.write(apiResponseJsonFormat)
    responseWriting.close()
    #------------------------------
  else:
    outputFPFileCreation = os.path.getctime(outputFPFile)
    timeNow = time.time()
    fileCreationLimitOffset = timeNow - (60 * 60 * 24 * olderFileDayLimit)
    if outputFPFileCreation > fileCreationLimitOffset:
      existingAnalysisRead = open(outputFPFile, "r")
      responseJson = json.loads(existingAnalysisRead.read())
      existingAnalysisRead.close()
    else:
      #------------------------------
      # Making API call to Vionlabs to get fingerprints
      headers = {
        'Accept': 'application/json'
      }
      payload = {}
      urlGetFingerprintPlus = f"https://apis.prod.vionlabs.com/results/fingerprintplus/v1/{cantemoItemId}?&key=kt8cyimHXxUzFNGyhd7c7g"
      # urlGetProfanitySegments = f"https://apis.prod.vionlabs.com/results/fingerprintplus/v1/OLT-003?&key=kt8cyimHXxUzFNGyhd7c7g"
      httpApiResponse = requests.request("GET", urlGetFingerprintPlus, headers=headers, data=payload)
      httpApiResponse.raise_for_status()
      responseJson = httpApiResponse.json()
      #------------------------------
      # Writing response data to a file
      apiResponseJson = json.loads(httpApiResponse.text)
      apiResponseJsonFormat = json.dumps(apiResponseJson, indent=2)
      responseWriting = open(outputFPFile, "w")
      responseWriting.write(apiResponseJsonFormat)
      responseWriting.close()
      #------------------------------
  '''
  '''
  #------------------------------
  # Update Cantemo metadata
  headers = {
  'Authorization': 'Basic YWRtaW46MTBsbXBAc0B0',
  'Cookie': 'csrftoken=HFOqrbk9cGt3qnc6WBIxWPjvCFX0udBdbJnzCv9jECumOjfyG7SS2lgVbFcaHBCc',
  'Content-Type': 'application/xml'
  }
  urlPutAnalysisInfo = f"http://10.1.1.34:8080/API/item/{cantemoItemId}/metadata/"
  # genrePayload = f"<MetadataDocument xmlns=\"http://xml.vidispine.com/schema/vidispine\"><timespan start=\"-INF\" end=\"+INF\"><field><name>oly_analysisReport</name><value>{errorReport}</value></field></timespan></MetadataDocument>"
  httpApiResponse = requests.request("PUT", urlPutAnalysisInfo, headers=headers, data=genrePayload)
  time.sleep(5)
  httpApiResponse = requests.request("PUT", urlPutAnalysisInfo, headers=headers, data=moodPayload)
  time.sleep(5)
  httpApiResponse = requests.request("PUT", urlPutAnalysisInfo, headers=headers, data=keywordPayload)
  time.sleep(5)
  httpApiResponse = requests.request("PUT", urlPutAnalysisInfo, headers=headers, data=statusPayload)
  #------------------------------
  #------------------------------
  '''

except HTTPError as http_err:
    print(f'HTTP error occurred: {http_err}')
except Exception as err:
    print(f'Other error occurred: {err}')