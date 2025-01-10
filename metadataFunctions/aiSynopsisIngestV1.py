# /opt/cantemo/python/bin/python
# /usr/local/bin/python3
#!/usr/bin/python3

# This application ingests metadata from an API response into Cantemo
# PREREQUISITE: -none-
# 	Usage: aiSynopsisIngestV1.py [Cantemo ItemID]

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
  olderFileDayLimit = 14
  cantemoItemId = sys.argv[1]
  # cantemoItemId = os.environ.get("portal_itemId")
  errorReport = ''
  outputSynopsisFile = f"/opt/olympusat/resources/vionlabsReports/{cantemoItemId}_SN.json"
  
  if not os.path.isfile(outputSynopsisFile):
    #------------------------------
    # Making API call to Vionlabs to get synopsis
    headers = {
      'Accept': 'application/json'
    }
    payload = {}
    urlGetSynopsis = f"https://apis.prod.vionlabs.com/results/synopsis/v1/{cantemoItemId}?version=1&key=kt8cyimHXxUzFNGyhd7c7g"
    httpApiResponse = requests.request("GET", urlGetSynopsis, headers=headers, data=payload)
    httpApiResponse.raise_for_status()
    responseJson = httpApiResponse.json()
    #------------------------------
    # Writing response data to a file
    apiResponseJson = json.loads(httpApiResponse.text)
    apiResponseJsonFormat = json.dumps(apiResponseJson, indent=2)
    responseWriting = open(outputSynopsisFile, "w")
    responseWriting.write(apiResponseJsonFormat)
    responseWriting.close()
    #------------------------------
  else:
    outputSNFileCreation = os.path.getctime(outputSynopsisFile)
    timeNow = time.time()
    fileCreationLimitOffset = timeNow - (60 * 60 * 24 * olderFileDayLimit)
    if outputSNFileCreation > fileCreationLimitOffset:
      existingAnalysisRead = open(outputSynopsisFile, "r")
      responseJson = json.loads(existingAnalysisRead.read())
      existingAnalysisRead.close()
    else:
      #------------------------------
      # Making API call to Vionlabs to get synopsis
      headers = {
        'Accept': 'application/json'
      }
      payload = {}
      urlGetSynopsis = f"https://apis.prod.vionlabs.com/results/synopsis/v1/{cantemoItemId}?version=1&key=kt8cyimHXxUzFNGyhd7c7g"
      httpApiResponse = requests.request("GET", urlGetSynopsis, headers=headers, data=payload)
      httpApiResponse.raise_for_status()
      responseJson = httpApiResponse.json()
      #------------------------------
      # Writing response data to a file
      apiResponseJson = json.loads(httpApiResponse.text)
      apiResponseJsonFormat = json.dumps(apiResponseJson, indent=2)
      responseWriting = open(outputSynopsisFile, "w")
      responseWriting.write(apiResponseJsonFormat)
      responseWriting.close()
      #------------------------------

  #------------------------------
  # Parsing JSON and post XML data
  responseData = responseJson["data"]
  synopsisType = responseData["synopsis"]
  synopsisShort = synopsisType["synopsis_short"]
  synopsisLong = synopsisType["synopsis_long"]
  overviewShort = synopsisType["overview_with_vibe_short"]
  overviewLong = synopsisType["overview_with_vibe_long"]
  # print(f"ss: {synopsisShort}\nsl: {synopsisLong}\nos: {overviewShort}\nol: {overviewLong}")

  headers = {
  'Authorization': 'Basic YWRtaW46MTBsbXBAc0B0',
  'Cookie': 'csrftoken=HFOqrbk9cGt3qnc6WBIxWPjvCFX0udBdbJnzCv9jECumOjfyG7SS2lgVbFcaHBCc',
  'Content-Type': 'application/xml'
  }
  urlPutAnalysisInfo = f"http://10.1.1.34:8080/API/item/{cantemoItemId}/metadata/"
  statusRawPayload = f"<MetadataDocument xmlns=\"http://xml.vidispine.com/schema/vidispine\"><timespan start=\"-INF\" end=\"+INF\"><field><name>oly_analysisStatus</name><value>completed - last request - synopsis</value></field></timespan></MetadataDocument>"
  parsedStatusPayload = xml.dom.minidom.parseString(statusRawPayload)
  statusPayload = parsedStatusPayload.toprettyxml()
  httpApiResponse = requests.request("PUT", urlPutAnalysisInfo, headers=headers, data=statusPayload)
  time.sleep(5)

  #------------------------------
  # Update Cantemo metadata
  metadataRawPayload = f"<MetadataDocument xmlns=\"http://xml.vidispine.com/schema/vidispine\"><timespan start=\"-INF\" end=\"+INF\">"\
  "<field><name>oly_aiSynopsisShort</name><value>{synopsisShort}</value>"\
  "</field><field><name>oly_aiSynopsisLong</name><value>{synopsisLong}</value></field>"\
  "<field><name>oly_aiOverviewShort</name><value>{overviewShort}</value></field>"\
  "<field><name>oly_aiOverviewLong</name><value>{overviewLong}</value></field>"\
  "<field><name>oly_analysisStatus</name><value>completed - last request - synopsis</value></field>"\
  "</timespan></MetadataDocument>"
  parsedMetadataPayload = xml.dom.minidom.parseString(metadataRawPayload)
  metadataPayload = parsedMetadataPayload.toprettyxml()
  httpApiResponse = requests.request("PUT", urlPutAnalysisInfo, headers=headers, data=metadataPayload)
  httpApiResponse.raise_for_status()
  #------------------------------
  #------------------------------

except HTTPError as http_err:
    print(f'HTTP error occurred: {http_err}')
except Exception as err:
    print(f'Other error occurred: {err}')