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
import csv
from email.message import EmailMessage
from requests.exceptions import HTTPError
from urllib.parse import quote_plus, quote
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
  destinationCollectionQuoted = quote(destinationCollection)
  failedItem = ""
  missingItem = ""

  cantemoSearchUrl = "http://10.1.1.34/API/v2/search/"
  headers = {
    'Authorization': 'Basic YWRtaW46MTBsbXBAc0B0',
    'Cookie': 'csrftoken=OtjDQ4lhFt2wJjGaJhq3xi05z3uA6D8F7wCWNVXxMuJ8A9jw7Ri7ReqSNGLS2VRR',
    'Accept': 'application/json',
    'Content-Type': 'application/json'
  }

  #------------------------------
  # Find and/or create collection
  collectionSearchPayloadText = {
    "filter": {
        "operator": "AND",
        "terms": [
            {
                "name": "type",
                "value": "collection",
                "exact": True
            },
            {
                "name": "name",
                "value": destinationCollection,
                "exact": True
            }
        ]
    }
}
  useExistingCollection = 0
  collectionSearchPayload = json.dumps(collectionSearchPayloadText)
  httpApiResponse = requests.request("PUT", cantemoSearchUrl, headers=headers, data=collectionSearchPayload)
  httpApiResponse.raise_for_status()
  responseJson = httpApiResponse.json() if httpApiResponse and httpApiResponse.status_code == 200 else None
  if responseJson and 'results' in responseJson:
    if responseJson['results']:
      for resultItem in responseJson['results']:
        if "id" in resultItem:
          if resultItem['id'] is not None:
            collectionId = resultItem['id']
            print(f"Collection ID for {destinationCollection} is {collectionId}")
            useExistingCollection = 1
    else:
      print(f"{destinationCollection} does not exist in Cantemo. Creating new collection.")
      payload = ""
      createCollectionUrl = f"http://10.1.1.34:8080/API/collection?name={destinationCollectionQuoted}"
      createCollectionHeaders = {
    'Authorization': 'Basic YWRtaW46MTBsbXBAc0B0',
    'Accept': 'application/json',
    'Cookie': 'csrftoken=OtjDQ4lhFt2wJjGaJhq3xi05z3uA6D8F7wCWNVXxMuJ8A9jw7Ri7ReqSNGLS2VRR'
  }
      httpApiResponse = requests.request("POST", cantemoSearchUrl, headers=createCollectionHeaders, data=payload)
      httpApiResponse.raise_for_status()
      responseJson = httpApiResponse.json() if httpApiResponse and httpApiResponse.status_code == 200 else None
      collectionId = responseJson['id']
  #------------------------------

  #------------------------------
  # Getting content of existing collection
  if useExistingCollection == 1:
    payload = ""
    urlCollectionContent = f"http://10.1.1.34:8080/API/collection/{collectionId}/item/"
    httpApiResponse = requests.request("GET", urlCollectionContent, headers=headers, data=payload)
    httpApiResponse.raise_for_status()
    responseJson = httpApiResponse.json() if httpApiResponse and httpApiResponse.status_code == 200 else None
    if responseJson['item']:
      collectionItems = responseJson['item']
      # print(collectionItems)
      # formattedId = {'id': 'OLY-14199'}
      # if formattedId in collectionItems:
      #   print("it exists")
    else:
      # print(f"Collection \"{destinationCollection}\" is empty")
      collectionItems = ""
  else:
    collectionItems = ""
  #------------------------------
  
  #------------------------------
  # Read items from a file and process them
  # with open(titleFile, "r") as file:
  with open(titleFile, newline='') as csvfile:
    reader = csv.reader(csvfile)
    # lines = file.readlines()
    #for cantemoTitleCodeLine in lines:
    for row in reader:
      if len(row) > 1:
        cantemoTitleCode = row[0].strip()
        cantemoTitle = row[1].strip()
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
        httpApiResponse = requests.request("PUT", cantemoSearchUrl, headers=headers, data=searchPayload)
        httpApiResponse.raise_for_status()
        responseJson = httpApiResponse.json() if httpApiResponse and httpApiResponse.status_code == 200 else None
        if responseJson and 'results' in responseJson:
          if responseJson['results']:
            for resultItem in responseJson['results']:
              if "id" in resultItem:
                if resultItem['id'] is not None:
                  print(f"  Cantemo item ID is {resultItem['id']}")
                  if any(item['id'] == resultItem['id'] for item in collectionItems):
                    print(f"  {resultItem['id']} is already in collection")
                  else:
                    # print("  assign this item")
                    putItemToCollectionUrl = f"http://10.1.1.34:8080/API/collection/{collectionId}/{resultItem['id']}"
                    httpApiResponse = requests.request("PUT", putItemToCollectionUrl, headers=headers, data=payload)
                    httpApiResponse.raise_for_status()
                    # responseJson = httpApiResponse.json() if httpApiResponse and httpApiResponse.status_code == 200 else None
                    if httpApiResponse and httpApiResponse.status_code == 200:
                      print(f"  {resultItem['id']} is successfully added.")
                    else:
                      print(f"  Adding {resultItem['id']} to {destinationCollection} failed.")
                      failedItem = f"{failedItem}, {resultItem['id']}"
                    time.sleep(2)
          else:
            print(f"  Item with title code [{cantemoTitleCode}] cannot be found in Cantemo. Searching with title [{cantemoTitle}].")
            searchPayloadText = {
    "filter": {
        "operator": "AND",
        "terms": [
            {
                "name": "title",
                "value": cantemoTitle,
                "exact": True
            }
        ]
    }
}
            searchPayload = json.dumps(searchPayloadText)
            httpApiResponse = requests.request("PUT", cantemoSearchUrl, headers=headers, data=searchPayload)
            httpApiResponse.raise_for_status()
            responseJson = httpApiResponse.json() if httpApiResponse and httpApiResponse.status_code == 200 else None
            if responseJson and 'results' in responseJson:
              if responseJson['results']:
                for resultItem in responseJson['results']:
                  if "id" in resultItem:
                    if resultItem['id'] is not None:
                      print(f"  Cantemo item ID is {resultItem['id']}")
                      if any(item['id'] == resultItem['id'] for item in collectionItems):
                        print(f"  {resultItem['id']} is already in collection")
                      else:
                        # print("  assign this item")
                        putItemToCollectionUrl = f"http://10.1.1.34:8080/API/collection/{collectionId}/{resultItem['id']}"
                        httpApiResponse = requests.request("PUT", putItemToCollectionUrl, headers=headers, data=payload)
                        httpApiResponse.raise_for_status()
                        # responseJson = httpApiResponse.json() if httpApiResponse and httpApiResponse.status_code == 200 else None
                        if httpApiResponse and httpApiResponse.status_code == 200:
                          print(f"  {resultItem['id']} is successfully added.")
                        else:
                          print(f"  Adding {resultItem['id']} to {destinationCollection} failed.")
                          failedItem = f"{failedItem}, {resultItem['id']}"
                        time.sleep(2)
              else:
                print(f"  Item with title code [{cantemoTitleCode}] or title [{cantemoTitle}] cannot be found in Cantemo.")
                missingItem = f"{missingItem}, {resultItem['id']}"
  #------------------------------
  print("-----Error Report-----")
  print("Items failed to be added:")
  print(failedItem)
  print("----------------------")
  print("Item missing from Cantemo:")
  print(missingItem)
  print("----------------------")
  #------------------------------

except HTTPError as http_err:
  print(f'HTTP error occurred: {http_err}')
except Exception as err:
  print(f'Other error occurred: {err}')