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
from datetime import datetime
import time
import subprocess
import xml.dom.minidom
import xml.etree.ElementTree as ET
import requests
import json
from requests.exceptions import HTTPError
from array import *
#------------------------------

#------------------------------
# Internal Functions

#------------------------------

#------------------------------

try:
  cantemoItemId = sys.argv[1]
  metadataFields = 'durationSeconds'
  itemTrtMinutes = 0

  headers = {
    'Authorization': 'Basic YWRtaW46MTBsbXBAc0B0',
    'Cookie': 'csrftoken=OtjDQ4lhFt2wJjGaJhq3xi05z3uA6D8F7wCWNVXxMuJ8A9jw7Ri7ReqSNGLS2VRR',
    'Accept': 'application/json'
  }
  urlGetItemInfo = f"http://10.1.1.34:8080/API/item/{cantemoItemId}/metadata?field={metadataFields}"
  payload = {}
  httpApiResponse = requests.request("GET", urlGetItemInfo, headers=headers, data=payload)
  httpApiResponse.raise_for_status()
  print({httpApiResponse})
  #------------------------------
  headers = {
    'Authorization': 'Basic YWRtaW46MTBsbXBAc0B0',
    'Cookie': 'csrftoken=HFOqrbk9cGt3qnc6WBIxWPjvCFX0udBdbJnzCv9jECumOjfyG7SS2lgVbFcaHBCc',
    'Content-Type': 'application/xml'
  }
  urlPutMetadataInfo = f"http://10.1.1.34:8080/API/item/{cantemoItemId}/metadata/"
  #------------------------------
  # Parsing JSON data
  #responseJson = httpApiResponse.json() if httpApiResponse and httpApiResponse.status_code == 200 else None
  #print({responseJson})
  #payload = f"<MetadataDocument xmlns=\"http://xml.vidispine.com/schema/vidispine\"><timespan start=\"-INF\" end=\"+INF\"><field><name>oly_trtMinutes</name><value>{itemTrtMinutes}</value></field></timespan></MetadataDocument>"
  #httpApiResponse = requests.request("PUT", urlPutMetadataInfo, headers=headers, data=payload)
  #httpApiResponse.raise_for_status()
  #if responseJson and 'item' in responseJson:
  #  print("Test")
  #------------------------------

except HTTPError as http_err:
    print(f'HTTP error occurred: {http_err}')
except Exception as err:
    print(f'Other error occurred: {err}')