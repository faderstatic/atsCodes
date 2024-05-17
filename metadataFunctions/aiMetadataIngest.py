# /opt/cantemo/python/bin/python
#!/usr/bin/python3

# This application ingests metadata from an XML output file into Cantemo
# PREREQUISITE: -none-
# 	Usage: analysisMetadataIngest.py [full file path of the XML file

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
  urlGetAdbreaks = f"https://apis.prod.vionlabs.com/results/adbreaks/v2/filter/frame/{cantemoItemId}?&key=kt8cyimHXxUzFNGyhd7c7g"
  httpApiResponse = requests.request("GET", urlGetAdbreaks, headers=headers, data=payload)
  httpApiResponse.raise_for_status()
  #------------------------------

  #------------------------------
  # Parsing JSON data
  # ET.register_namespace('ns', 'http://xml.vidispine.com/schema/vidispine')
  responseJson = httpApiResponse.json()
  itemAiAnalysis = json.loads(httpApiResponse.text)
  for lineValue in responseJson:
    itemAiAnalysis = lineValue["adbreak"]
  # responseXmlRoot = ET.fromstring(responseXml)
  # fileLocation = responseXmlRoot.find('{http://xml.vidispine.com/schema/vidispine}uri')
  #------------------------------

  #------------------------------
  # Formatting sorce  filename
  baseFileName = os.path.basename(fileLocation.text)
  justFileName, justFileExtension = os.path.splitext(baseFileName)
  justFileExtensionTrimmed = justFileExtension.replace('.', '')
  # print(f"Filename: {justFileName} - File Extension: {justFileExtension}")
  sourceXmlFile = f"/Volumes/creative/MAM/_autoIngest/staging/zAdmin/xmlImport/{justFileName}_{justFileExtensionTrimmed}.xml"
  sourceXmlFile = f"/mnt/c/Users/kkanjanapitak/Desktop/Repositories/atsCodes/sampleFiles/Baton/Grand_HD_RU_SGRAND1_S5E1_Master_mxf.xml"
  #------------------------------

  tree = ET.parse(sourceXmlFile)
  root = tree.getroot()

  #------------------------------
  # Gather metadata from the report
  # for errorResults in root.iter('error'):
  #     errorMessage = errorResults.get('synopsis')
  #     errorDescription = errorResults.get('description')
  #     errorTimecode = errorResults.get('timecode')
  #     errorReport = errorReport + f"{errorTimecode} - {errorMessage} ({errorDescription})\n"
  #------------------------------

  #------------------------------
  # Update Cantemo metadata
  headers = {
    'Authorization': 'Basic YWRtaW46MTBsbXBAc0B0',
    'Cookie': 'csrftoken=HFOqrbk9cGt3qnc6WBIxWPjvCFX0udBdbJnzCv9jECumOjfyG7SS2lgVbFcaHBCc',
    'Content-Type': 'application/xml'
  }
  cantemoItemId = 'OLY-203'
  urlPutAnalysisInfo = f"http://10.1.1.34:8080/API/item/{cantemoItemId}/metadata/"
  payload = f"<MetadataDocument xmlns=\"http://xml.vidispine.com/schema/vidispine\"><timespan start=\"-INF\" end=\"+INF\"><field><name>oly_analysisReport</name><value>{responseJson}</value></field></timespan></MetadataDocument>"
  httpApiResponse = requests.request("PUT", urlPutAnalysisInfo, headers=headers, data=payload)

except HTTPError as http_err:
    print(f'HTTP error occurred: {http_err}')
except Exception as err:
    print(f'Other error occurred: {err}')