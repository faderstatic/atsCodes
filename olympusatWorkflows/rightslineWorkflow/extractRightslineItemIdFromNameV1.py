# /opt/cantemo/python/bin/python
# /usr/local/bin/python3
#!/usr/bin/python3

# This application ingests metadata from an XML API response into Cantemo
# PREREQUISITE: -none-
# 	Usage: aiEmailResult.py [Cantemo ItemID] [Cantemo Username] [analysis type]

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
import smtplib
from email.message import EmailMessage
from requests.exceptions import HTTPError
#------------------------------

#------------------------------
# Internal Functions

def readCantemoMetadata(rcmItemId, rcmFieldName):
  #------------------------------
  # Making API to Cantemo to get lookup values
  headers = {
    'Authorization': 'Basic YWRtaW46MTBsbXBAc0B0',
    'Cookie': 'csrftoken=OtjDQ4lhFt2wJjGaJhq3xi05z3uA6D8F7wCWNVXxMuJ8A9jw7Ri7ReqSNGLS2VRR',
    'Accept': 'application/json'
  }
  payload = {}
  urlGetMetadata = f"http://10.1.1.34:8080/API/item/{rcmItemId}/metadata?field={rcmFieldName}&terse=yes&interval=generic"
  httpApiResponse = requests.request("GET", urlGetMetadata, headers=headers, data=payload)
  httpApiResponse.raise_for_status()
  #------------------------------
  # Parsing JSON data
  responseJson = httpApiResponse.json() if httpApiResponse and httpApiResponse.status_code == 200 else None
  if responseJson and 'item' in responseJson:
    for itemInformation in responseJson['item']:
      if rcmFieldName in itemInformation:
        for titleInformation in itemInformation[rcmFieldName]:
          metadataValue = titleInformation['value']
          if metadataValue == '':
            metadataValue = '<none>'
      else:
        metadataValue = '<none>'
  #------------------------------
  return metadataValue

#------------------------------

try:

  cantemoItemId = sys.argv[1]

  cantemoTitle = readCantemoMetadata(cantemoItemId, 'title')
  time.sleep(1)
  cantemoTitleCode = readCantemoMetadata(cantemoItemId, 'oly_titleCode')
  time.sleep(1)
  cantemoRightslineId = readCantemoMetadata(cantemoItemId, 'oly_rightslineItemId')

  if (cantemoRightslineId == '<none>') and cantemoTitle.startswith("CA_",0,3):
    stringSegments = cantemoTitle.split('_')
    cantemoRightslineId = stringSegments[2]
    #------------------------------
    # Update Cantemo metadata
    headers = {
    'Authorization': 'Basic YWRtaW46MTBsbXBAc0B0',
    'Cookie': 'csrftoken=HFOqrbk9cGt3qnc6WBIxWPjvCFX0udBdbJnzCv9jECumOjfyG7SS2lgVbFcaHBCc',
    'Content-Type': 'application/xml'
    }
    urlPutAnalysisInfo = f"http://10.1.1.34:8080/API/item/{cantemoItemId}/metadata/"
    itemIdRawPayload = f"<MetadataDocument xmlns=\"http://xml.vidispine.com/schema/vidispine\"><timespan start=\"-INF\" end=\"+INF\"><field><name>oly_rightslineItemId</name><value>{cantemoRightslineId}</value></field></timespan></MetadataDocument>"
    parsedItemIdPayload = xml.dom.minidom.parseString(itemIdRawPayload)
    itemIdPayload = parsedItemIdPayload.toprettyxml()
    httpApiResponse = requests.request("PUT", urlPutAnalysisInfo, headers=headers, data=itemIdPayload)
    #------------------------------

  #------------------------------
  # Update The User
  print(f"{cantemoTitle} (Title Code: {cantemoTitleCode}) - (Rightsline ID: {cantemoRightslineId})")
  #------------------------------
  #------------------------------

except HTTPError as http_err:
    print(f'HTTP error occurred: {http_err}')
except Exception as err:
    print(f'Other error occurred: {err}')