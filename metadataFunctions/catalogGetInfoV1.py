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
import string
import subprocess
import xml.dom.minidom
import xml.etree.ElementTree as ET
import requests
import json
import smtplib
import urllib.request
from email.message import EmailMessage
from requests.exceptions import HTTPError
from urllib.parse import quote_plus
from pymongo.mongo_client import MongoClient
from urllib.parse import quote_plus
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
# dbUsername = 'kkanjanapitak@olympusat.com'
# dbPassword = 'Ross2016!'
# dbUsernameEncoded = quote_plus(dbUsername)
# dbPasswordEncoded = quote_plus(dbPassword)
# print(f"Username Encoded = {dbUsernameEncoded} - Password Encoded = {dbPasswordEncoded}")
# uri = "mongodb+srv://eymqsqaa:d53102b4-6381-403b-8c90-4bf9d103e91c@prod-1.4g3ic.mongodb.net/?retryWrites=true&w=majority&appName=Prod-1&tls=true"
uri = "mongodb+srv://eymqsqaa:d53102b4-6381-403b-8c90-4bf9d103e91c@prod-1.4g3ic.mongodb.net/admin"
# Create a new client and connect to the server
client = MongoClient(uri)
# Send a ping to confirm a successful connection

try:
    
  client.admin.command('ping')
  print("Pinged your deployment. You successfully connected to MongoDB!")
  print(client.list_database_names())

  cantemoItemId = sys.argv[1]

  #------------------------------
  # Creating Spanish accented characters translation
  accentedCharacters = "áéíóúÁÉÍÓÚñÑ"
  unaccentedCharacters = "aeiouAEIOUnN"
  translationTable = str.maketrans(accentedCharacters, unaccentedCharacters)
  #------------------------------

  cantemoOriginalTitleRaw = readCantemoMetadata(cantemoItemId, 'oly_originalTitle')
  cantemoOriginalTitleWhite = cantemoOriginalTitleRaw.lstrip()
  cantemoOriginalTitle = cantemoOriginalTitleWhite.translate(translationTable)
  # cantemoOriginalTitle = cantemoOriginalTitleTemp.replace(' ', '+')

  #------------------------------
  # Update The User
  print(f"{cantemoOriginalTitleWhite} \(without accents: {cantemoOriginalTitle}\)")
  #------------------------------
 
#------------------------------
except Exception as e:
    print(f"MongoDB Error: {e}")
except HTTPError as http_err:
  print(f'HTTP error occurred: {http_err}')
except Exception as err:
  print(f'Other error occurred: {err}')