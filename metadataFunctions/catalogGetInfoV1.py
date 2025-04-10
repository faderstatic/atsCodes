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
from xml.sax.saxutils import escape
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
# dbUsername = ''
# dbPassword = ''
# dbUsernameEncoded = quote_plus(dbUsername)
# dbPasswordEncoded = quote_plus(dbPassword)
# print(f"Username Encoded = {dbUsernameEncoded} - Password Encoded = {dbPasswordEncoded}")
#------------------------------

# uriProd1 = "mongodb+srv://mamadmin:YOzHzj5EAhAJ4u7T@prod-1.4g3ic.mongodb.net/?retryWrites=true&w=majority&appName=Prod-1&tls=true"
uriOdev = "mongodb+srv://mamadmin:YOzHzj5EAhAJ4u7T@olympusatdev.4g3ic.mongodb.net/?retryWrites=true&w=majority&appName=OlympusatDev&tls=true"
# uri = "mongodb+srv://mamadmin:YOzHzj5EAhAJ4u7T@prod-1.4g3ic.mongodb.net/admin"
# Create a new client and connect to the server
# clientProd1 = MongoClient(uriProd1)
clientOdev = MongoClient(uriOdev)
# Send a ping to confirm a successful connection

try:
    
  # clientProd1.admin.command('ping')
  # print(f"Pinged your deployment. You successfully connected to Prod-1")
  # clientOdev.admin.command('ping')
  # print(f"Pinged your deployment. You successfully connected to OlympusatDev")

  olyplatCatalog = clientOdev["olyplat_catalog"]
  catalogCollection = olyplatCatalog["catalog"]
  movieCollection = olyplatCatalog["movie"]
  seriesCollection = olyplatCatalog["series"]
  episodeCollection = olyplatCatalog["episode"]
  seasonCollection = olyplatCatalog["season"]
  genreCollection = olyplatCatalog["genre_type"]

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

  titleCode = list(range(3))
  catalogItemMetadata = list(range(3))
  titleCode[0] = readCantemoMetadata(cantemoItemId, 'oly_titleCode').strip()

  #------------------------------
  # Start with gathering information on movie or series level
  if titleCode[0] is not None:
    if titleCode[0][0] == "M":
      titleCodeDepth = 1
      queryTitleCode = {'titleCode': titleCode[0]}
      catalogItemMetadata[0] = movieCollection.find_one(queryTitleCode)
      # print("Get information from movie collection")
    elif titleCode[0][0] == "S":
      titleCodeDepth = 3
      queryTitleCode = {'titleCode': titleCode[0]}
      catalogItemMetadata[0] = episodeCollection.find_one(queryTitleCode)
      # print("Get information from episode collection")
      # Prepare series (titleCode[2]) and season (titleCode[1]) titlecode incase no information in episode
      titleCode[2] = titleCode[0][:7]
      # print(titleCode[2])
      queryTitleCode = {'titleCode': titleCode[2]}
      catalogItemMetadata[2] = seriesCollection.find_one(queryTitleCode)
      # episodeNumberPosition = titleCode[0].rfind("E")
      # if episodeNumberPosition != -1:
      #   titleCode[1] = titleCode[0][:episodeNumberPosition]
      # else:
      #   titleCode[1] = titleCode[0]
      # queryTitleCode = {'titleCode': titleCode[1]}
      # catalogItemMetadata[1] = seasonCollection.find_one(queryTitleCode)
  #------------------------------

  catalogMetadataUpdate = ""

  # print(f"base level metadata collected: {catalogItemMetadata[0]}")
  # print(catalogItemMetadata[1])
  # print(f"            series collection: {catalogItemMetadata[2]}")
  if (catalogItemMetadata[0] == "") or (not catalogItemMetadata[0]) or (catalogItemMetadata[0] == 0):
    firstValue = 2
  else:
    firstValue = 0

  if (catalogItemMetadata[firstValue] != firstValue):
    for metadataItem, metadataValue in catalogItemMetadata[firstValue].items():
      if metadataItem in ["year", "languageLabel", "productionCompany", "sourceType", "cast", "producer", "director", "primaryGenreLabel", "secondaryGenresLabel", "duration", "description", "metadataSource", "editorsNotes", "translations", "secondaryGenres", "primaryGenre"]:
        if metadataItem == "secondaryGenres":
          if ((not metadataValue) or (metadataValue == "")) and titleCode[0][0] == "S":
            metadataValue = catalogItemMetadata[2][metadataItem]
            # if (not metadataValue) or (metadataValue == ""):
            #   metadataValue = catalogItemMetadata[2][metadataItem]
          if (metadataValue) and (metadataValue != ""):
            genreCombined = ""
            for eachGenre in metadataValue:
              queryGenreCode = {'entityUUID': eachGenre}
              genreValue = genreCollection.find_one(queryGenreCode)
              genreCombined = genreCombined+genreValue['entityValue']+","
            metadataValue = genreCombined[:-1]
        elif metadataItem == "primaryGenre":
          if ((not metadataValue) or (metadataValue == "")) and titleCode[0][0] == "S":
            metadataValue = catalogItemMetadata[2][metadataItem]
            # if (not metadataValue) or (metadataValue == ""):
            #   metadataValue = catalogItemMetadata[2][metadataItem]
          if (metadataValue) and (metadataValue != ""):
            queryGenreCode = {'entityUUID': metadataValue}
            genreValue = genreCollection.find_one(queryGenreCode)
            metadataValue = genreValue['entityValue']
        elif metadataItem == "translations":
          if ((not metadataValue) or (metadataValue == "")) and titleCode[0][0] == "S":
            metadataValue = catalogItemMetadata[2][metadataItem]
            # if (not metadataValue) or (metadataValue == ""):
            #   metadataValue = catalogItemMetadata[2][metadataItem]
          if (metadataValue) and (metadataValue != ""):
            enTranslations = metadataValue['en']
            if enTranslations['description']:
              catalogMetadataUpdate = catalogMetadataUpdate + f"""description en: {enTranslations['description']}
  """
            if enTranslations['shortDescription']:
              catalogMetadataUpdate = catalogMetadataUpdate + f"""short description en: {enTranslations['shortDescription']}
  """
            esTranslations = metadataValue['es']
            if esTranslations['description']:
              catalogMetadataUpdate = catalogMetadataUpdate + f"""description es: {esTranslations['description']}
  """
            if esTranslations['shortDescription']:
              catalogMetadataUpdate = catalogMetadataUpdate + f"""short description es: {esTranslations['shortDescription']}
  """
        elif metadataItem == "metadataSource":
          if ((not metadataValue) or (metadataValue == "")) and titleCode[0][0] == "S":
            metadataValue = catalogItemMetadata[2][metadataItem]
            # if (not metadataValue) or (metadataValue == ""):
            #   metadataValue = catalogItemMetadata[2][metadataItem]
          if (metadataValue) and (metadataValue != ""):
            for infoItem in metadataValue:
              sourceType = infoItem['sourceType']
              sourceUrl = infoItem['url']
              catalogMetadataUpdate = catalogMetadataUpdate + f"""Source Type - {sourceType}: {sourceUrl}
  """
        else:
          if ((not metadataValue) or (metadataValue == "")) and titleCode[0][0] == "S":
            metadataValue = catalogItemMetadata[2][metadataItem]
            # if (not metadataValue) or (metadataValue == ""):
            #   metadataValue = catalogItemMetadata[2][metadataItem]
          if (metadataValue) and (metadataValue != ""):
            catalogMetadataUpdate = catalogMetadataUpdate + f"""{metadataItem}: {str(metadataValue).replace('[',"").replace(']',"")}
  """
      # print(f"{metadataItem}: {metadataValue}")

  # print(catalogMetadataUpdate)
  # clientProd1.close()
  clientOdev.close()

  #------------------------------
  # Update The User
  # print(f"{cantemoOriginalTitleWhite} (without accents: {cantemoOriginalTitle}) - {cantemoTitleCode}")
  #------------------------------

  if (not catalogMetadataUpdate) or (catalogMetadataUpdate == "") or (catalogItemMetadata[firstValue] != firstValue):
    catalogMetadataUpdate = "Information of this item cannot be found in Catalog Service"
  # print(f"Value to update is: {catalogMetadataUpdate}")

  #------------------------------
  # Update Cantemo metadata
  catalogMetadataUpdateValid = escape(catalogMetadataUpdate)
  headers = {
  'Authorization': 'Basic YWRtaW46MTBsbXBAc0B0',
  'Cookie': 'csrftoken=HFOqrbk9cGt3qnc6WBIxWPjvCFX0udBdbJnzCv9jECumOjfyG7SS2lgVbFcaHBCc',
  'Accept': 'application/xml',
  'Content-Type': 'application/xml; charset=utf-8'
  }
  urlPutAnalysisInfo = f"http://10.1.1.34:8080/API/item/{cantemoItemId}/metadata/"
  itemRawPayload = f"""
<MetadataDocument xmlns=\"http://xml.vidispine.com/schema/vidispine\"> 
<timespan start=\"-INF\" end=\"+INF\">
  <field>
    <name>oly_catalogMetadata</name>
    <value>{catalogMetadataUpdateValid}</value>
  </field>
</timespan>
</MetadataDocument>"""
  # print(itemRawPayload)
  itemPayload = itemRawPayload.encode('utf-8')
  # print(itemPayload)
  httpApiResponse = requests.request("PUT", urlPutAnalysisInfo, headers=headers, data=itemPayload)
  #------------------------------

#------------------------------
except Exception as e:
    print(f"MongoDB Error: {e}")
    # print(traceback.format_exc())
    # clientProd1.close()
    clientOdev.close()
except HTTPError as http_err:
  print(f'HTTP error occurred: {http_err}')
except Exception as err:
  print(f'Other error occurred: {err}')