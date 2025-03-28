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
import uuid
from email.message import EmailMessage
from requests.exceptions import HTTPError
from urllib.parse import quote_plus
from pymongo import MongoClient
# import traceback
#------------------------------

# uriProd1 = "mongodb+srv://mamadmin:YOzHzj5EAhAJ4u7T@prod-1.4g3ic.mongodb.net/?retryWrites=true&w=majority&appName=Prod-1&tls=true"
uriOdev = "mongodb+srv://mamadmin:YOzHzj5EAhAJ4u7T@olympusatdev.4g3ic.mongodb.net/?retryWrites=true&w=majority&appName=OlympusatDev&tls=true"
uriCluster0 = "mongodb+srv://mamadmin:YOzHzj5EAhAJ4u7T@cluster0.ld2wjpj.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0&tls=true"
# uri = "mongodb+srv://mamadmin:YOzHzj5EAhAJ4u7T@prod-1.4g3ic.mongodb.net/admin"
# Create a new client and connect to the server
# clientProd1 = MongoClient(uriProd1)
clientOdev = MongoClient(uriOdev)
clientCluster0 = MongoClient(uriCluster0)
# Send a ping to confirm a successful connection

try:

  cantemoTitleCode = sys.argv[1]
    
  # clientProd1.admin.command('ping')
  # print(f"Pinged your deployment. You successfully connected to Prod-1")
  # clientOdev.admin.command('ping')
  # print(f"Pinged your deployment. You successfully connected to OlympusatDev")

  olyplatCatalog = clientOdev["olyplat_catalog"]
  cantemoDb = clientCluster0["cantemo"]
  refCrewCollection = cantemoDb["refCrew"]
  catalogCollection = olyplatCatalog["catalog"]
  movieCollection = olyplatCatalog["movie"]
  seriesCollection = olyplatCatalog["series"]
  genreCollection = olyplatCatalog["genre_type"]

  #------------------------------
  # Creating Spanish accented characters translation
  accentedCharacters = "áéíóúÁÉÍÓÚñÑ"
  unaccentedCharacters = "aeiouAEIOUnN"
  translationTable = str.maketrans(accentedCharacters, unaccentedCharacters)
  #------------------------------

  queryTitleCode = {'titleCode': cantemoTitleCode}
  if cantemoTitleCode[0] == "M":
    catalogItemMetadata = movieCollection.find_one(queryTitleCode)
    print("Get information from movie collection")
  if cantemoTitleCode[0] == "S":
    catalogItemMetadata = seriesCollection.find_one(queryTitleCode)
    print("Get information from series collection")

  for metadataItem, metadataValue in catalogItemMetadata.items():
    if metadataItem in ["cast", "director"]:
      if (metadataItem == "cast"):
        actorUuid = list(range(len(metadataValue)))
        for iCounter in range(len(metadataValue)):
          actorUuid[iCounter] = uuid.uuid4().hex[:16]
          print(f"Actor {iCounter} [{actorUuid[iCounter]}]: {metadataValue[iCounter]}")
        del actorUuid
      if (metadataItem == "director"):
        directorUuid = list(range(len(metadataValue)))
        for iCounter in range(len(metadataValue)):
          directorUuid[iCounter] = uuid.uuid4().hex[:16]
          print(f"Director {iCounter} [{directorUuid[iCounter]}]: {metadataValue[iCounter]}")

  # clientProd1.close()
  clientOdev.close()
  clientCluster0.close()

  #------------------------------
  # Update The User
  # print(f"{cantemoOriginalTitleWhite} (without accents: {cantemoOriginalTitle}) - {cantemoTitleCode}")
  #------------------------------

#------------------------------
except Exception as e:
    print(f"MongoDB Error: {e}")
    # print(traceback.format_exc())
    # clientProd1.close()
    clientOdev.close()
    clientCluster0.close()
except HTTPError as http_err:
  print(f'HTTP error occurred: {http_err}')
except Exception as err:
  print(f'Other error occurred: {err}')