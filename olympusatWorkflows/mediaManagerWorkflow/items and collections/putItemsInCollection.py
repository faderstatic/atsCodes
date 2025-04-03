# /opt/cantemo/python/bin/python
# /usr/local/bin/python3
#!/usr/bin/python3

# This application read a list of title codes from a text file and put them into a specified Cantemo collection
# PREREQUISITE: -none-
# 	Usage: putItemsInCollection.py [file with title codes list] [Cantemo Collection name]

#------------------------------
# Libraries
import sys
import time
import xml.etree.ElementTree as ET
import requests
import uuid
import json
from email.message import EmailMessage
from requests.exceptions import HTTPError
from urllib.parse import quote_plus
from pymongo import MongoClient
# import traceback
#------------------------------

#------------------------------
# Internal Functions

def readCantemoMetadata(rcmItemId, rcmFieldName):
  #------------------------------
  # Making API to Cantemo to get metadata values
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
  titleFile = sys.argv[1]
  destinationCollection = sys.argv[2]

  cantemoSearchUrl = "http://10.1.1.34/API/v2/search/"
  headers = {
    'Authorization': 'Basic YWRtaW46MTBsbXBAc0B0',
    'Cookie': 'csrftoken=OtjDQ4lhFt2wJjGaJhq3xi05z3uA6D8F7wCWNVXxMuJ8A9jw7Ri7ReqSNGLS2VRR',
    'Accept': 'application/json',
    'Content-Type': 'application/json'
  }

  with open(titleFile, "r") as file:
    lines = file.readlines()
    for cantemoTitleCodeLine in lines:
      cantemoTitleCode = cantemoTitleCodeLine.strip()
      print(f"Putting {cantemoTitleCode} in {destinationCollection}")
      searchPayloadText = {
    "filter": {
        "operator": "AND",
        "terms": [
            {
                "name": "oly_titleCode",
                "value": cantemoTitleCode,
                "exact": True
            },
            {
                "name": "oly_versionType",
                "value": "conformFile"
            }
        ]
    }
}
      searchPayload = json.dumps(searchPayloadText)
      print(searchPayload)

      httpResponse = requests.request("PUT", cantemoSearchUrl, headers=headers, data=searchPayload)
      print(httpResponse.text)

except HTTPError as http_err:
  print(f'HTTP error occurred: {http_err}')
except Exception as err:
  print(f'Other error occurred: {err}')