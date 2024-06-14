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
import xml.dom.minidom
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
  apiResponseJson = json.loads(httpApiResponse.text)
  apiResponseJsonFormat = json.dumps(apiResponseJson, indent=2)
  responseWriting = open(outputFPFile, "w")
  responseWriting.write(apiResponseJsonFormat)
  responseWriting.close()

  genreXML = f"<MetadataDocument xmlns=\"http://xml.vidispine.com/schema/vidispine\"><group>Olympusat</group><timespan start=\"-INF\" end=\"+INF\"><field><name>oly_genreAnalysis</name>"
  #------------------------------
  # Parsing JSON and POST XML data
  responseJson = httpApiResponse.json()
  for individualGenre in responseJson["genre"]:
    print(individualGenre)
    genreXML += f"<value>{individualGenre}</value>"
  genreXML += "</field></timespan></MetadataDocument>"
  parsedXML = xml.dom.minidom.parse(genreXML)
  # genrePayload = parsedXML.toprettyxml()
  # print(genrePayload)
  #------------------------------
  # Update Cantemo metadata
  # headers = {
  # 'Authorization': 'Basic YWRtaW46MTBsbXBAc0B0',
  # 'Cookie': 'csrftoken=HFOqrbk9cGt3qnc6WBIxWPjvCFX0udBdbJnzCv9jECumOjfyG7SS2lgVbFcaHBCc',
  # 'Content-Type': 'application/xml'
  # }
  # urlPutAnalysisInfo = f"http://10.1.1.34:8080/API/item/{cantemoItemId}/metadata/"
  # genrePayload = f"<MetadataDocument xmlns=\"http://xml.vidispine.com/schema/vidispine\"><timespan start=\"-INF\" end=\"+INF\"><field><name>oly_analysisReport</name><value>{errorReport}</value></field></timespan></MetadataDocument>"
  # httpApiResponse = requests.request("PUT", urlPutAnalysisInfo, headers=headers, data=genrePayload)
  #------------------------------
  #------------------------------

except HTTPError as http_err:
    print(f'HTTP error occurred: {http_err}')
except Exception as err:
    print(f'Other error occurred: {err}')