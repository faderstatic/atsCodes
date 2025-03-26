# /opt/cantemo/python/bin/python
# /usr/local/bin/python3
#!/usr/bin/python3

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
from pymongo import MongoClient
# import traceback
#------------------------------

#------------------------------
# dbUsername = ''
# dbPassword = ''
# dbUsernameEncoded = quote_plus(dbUsername)
# dbPasswordEncoded = quote_plus(dbPassword)
# print(f"Username Encoded = {dbUsernameEncoded} - Password Encoded = {dbPasswordEncoded}")
#------------------------------

uriOdev = "mongodb+srv://mamadmin:YOzHzj5EAhAJ4u7T@olympusatdev.4g3ic.mongodb.net/?retryWrites=true&w=majority&appName=OlympusatDev&tls=true"
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
  seasonCollection = olyplatCatalog["season"]
  seriesCollection = olyplatCatalog["series"]
  episodeCollection = olyplatCatalog["episode"]
  genreCollection = olyplatCatalog["genre_type"]

  #------------------------------
  # Creating Spanish accented characters translation
  accentedCharacters = "áéíóúÁÉÍÓÚñÑ"
  unaccentedCharacters = "aeiouAEIOUnN"
  translationTable = str.maketrans(accentedCharacters, unaccentedCharacters)
  #------------------------------

  queryAvailableSynopsis = {
    "$or" : [
      { "translations.en.description": { "$exists" : True, "$ne" : "" } }, 
      { "translations.es.description": { "$exists" : True, "$ne" : "" } }
      ]
  }

  #------------------------------
  # Gather and create file for episode synopsis
  outputSynopsisFile = f"./catalogEpisodeSynopsis.tsv"
  catalogItem = episodeCollection.find(queryAvailableSynopsis)
  responseWriting = open(outputSynopsisFile, "w")
  for catalogItemMetadata in catalogItem:
    # print(catalogItemMetadata)
    titleCode = catalogItemMetadata['titleCode']
    synTranslations = catalogItemMetadata['translations']
    enTranslations = synTranslations['en']
    enDescription = enTranslations['description']
    enShortDescription = enTranslations['shortDescription']
    esTranslations = synTranslations['es']
    esDescription = esTranslations['description']
    esShortDescription = esTranslations['shortDescription']
    catalogMetadataUpdateDirty = f"{titleCode}\t{enDescription}\t{enShortDescription}\t{esDescription}\t{esShortDescription}"
    catalogMetadataUpdate = f"{catalogMetadataUpdateDirty.replace("\r","").replace("\n","")}\n"
    # print(catalogMetadataUpdate)
    responseWriting.write(catalogMetadataUpdate)
  responseWriting.close()
  #------------------------------

  #------------------------------
  # Gather and create file for movie synopsis
  outputSynopsisFile = f"./catalogMovieSynopsis.tsv"
  catalogItem = movieCollection.find(queryAvailableSynopsis)
  responseWriting = open(outputSynopsisFile, "w")
  for catalogItemMetadata in catalogItem:
    # print(catalogItemMetadata)
    titleCode = catalogItemMetadata['titleCode']
    synTranslations = catalogItemMetadata['translations']
    enTranslations = synTranslations['en']
    enDescription = enTranslations['description']
    enShortDescription = enTranslations['shortDescription']
    esTranslations = synTranslations['es']
    esDescription = esTranslations['description']
    esShortDescription = esTranslations['shortDescription']
    catalogMetadataUpdateDirty = f"{titleCode}\t{enDescription}\t{enShortDescription}\t{esDescription}\t{esShortDescription}"
    catalogMetadataUpdate = f"{catalogMetadataUpdateDirty.replace("\r","").replace("\n","")}\n"
    # print(catalogMetadataUpdate)
    responseWriting.write(catalogMetadataUpdate)
  responseWriting.close()
  #------------------------------

  #------------------------------
  # Gather and create file for season synopsis
  outputSynopsisFile = f"./catalogSeasonSynopsis.tsv"
  catalogItem = seasonCollection.find(queryAvailableSynopsis)
  responseWriting = open(outputSynopsisFile, "w")
  for catalogItemMetadata in catalogItem:
    # print(catalogItemMetadata)
    titleCode = catalogItemMetadata['titleCode']
    synTranslations = catalogItemMetadata['translations']
    enTranslations = synTranslations['en']
    enDescription = enTranslations['description']
    enShortDescription = enTranslations['shortDescription']
    esTranslations = synTranslations['es']
    esDescription = esTranslations['description']
    esShortDescription = esTranslations['shortDescription']
    catalogMetadataUpdateDirty = f"{titleCode}\t{enDescription}\t{enShortDescription}\t{esDescription}\t{esShortDescription}"
    catalogMetadataUpdate = f"{catalogMetadataUpdateDirty.replace("\r","").replace("\n","")}\n"
    # print(catalogMetadataUpdate)
    responseWriting.write(catalogMetadataUpdate)
  responseWriting.close()
  #------------------------------

  #------------------------------
  # Gather and create file for series synopsis
  outputSynopsisFile = f"./catalogSeriesSynopsis.tsv"
  catalogItem = seriesCollection.find(queryAvailableSynopsis)
  responseWriting = open(outputSynopsisFile, "w")
  for catalogItemMetadata in catalogItem:
    # print(catalogItemMetadata)
    titleCode = catalogItemMetadata['titleCode']
    synTranslations = catalogItemMetadata['translations']
    enTranslations = synTranslations['en']
    enDescription = enTranslations['description']
    enShortDescription = enTranslations['shortDescription']
    esTranslations = synTranslations['es']
    esDescription = esTranslations['description']
    esShortDescription = esTranslations['shortDescription']
    catalogMetadataUpdateDirty = f"{titleCode}\t{enDescription}\t{enShortDescription}\t{esDescription}\t{esShortDescription}"
    catalogMetadataUpdate = f"{catalogMetadataUpdateDirty.replace("\r","").replace("\n","")}\n"
    # print(catalogMetadataUpdate)
    responseWriting.write(catalogMetadataUpdate)
  responseWriting.close()
  #------------------------------

  # clientProd1.close()
  clientOdev.close()

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