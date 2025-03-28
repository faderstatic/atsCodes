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

  #------------------------------
  # Get existing information from Mira
  urlMira = f"http://10.1.1.22:83/Service1.svc/titles/{cantemoTitleCode}"
  payload = ""
  headers = {
    'Cotent-Type': 'text/plain'
  }

  miraResponse = requests.request("GET", urlMira, headers=headers, data=payload)
  miraResponse.raise_for_status
  #------------------------------
  # Parsing JSON data
  responseJson = miraResponse.json() if miraResponse and miraResponse.status_code == 200 else None
  miraId = responseJson[0]['id_titles']
  miraCrew = responseJson[0]['title_subjects']
  miraCrewCount = len(responseJson[0]['title_subjects'])
  miraCrewName = list(range(miraCrewCount))
  miraCrewId = list(range(miraCrewCount))
  miraCrewRole = list(range(miraCrewCount))
  miraCrewNumber = 0
  miraActorCount = 0
  miraDirectorCount = 0
  for eachCrew in responseJson[0]['title_subjects']:
    if eachCrew['id_positions'] == 1:
      miraCrewName[miraCrewNumber] = eachCrew['first_name']
      miraCrewId[miraCrewNumber] = eachCrew['external_ident']
      miraCrewRole[miraCrewNumber] = "actor"
      miraCrewNumber = miraCrewNumber +1
      miraActorCount = miraActorCount + 1
    elif eachCrew['id_positions'] == 2:
      miraCrewName[miraCrewNumber] = eachCrew['first_name']
      miraCrewId[miraCrewNumber] = eachCrew['external_ident']
      miraCrewRole[miraCrewNumber] = "director"
      miraCrewNumber = miraCrewNumber + 1
      miraDirectorCount = miraDirectorCount + 1
  miraActorCount = miraActorCount - 1
  miraDirectorCount = miraDirectorCount - 1
  miraCrewNumber = miraCrewNumber - 1
  print("Information from Mira")
  for crewNumber in range(miraCrewCount):
    print(f"{miraCrewRole[crewNumber]}: {miraCrewName[crewNumber]} ({miraCrewId[crewNumber]})")
    #------------------------------
    # Check if crews from Mira already exist in the database and update
    queryCrewName = {'crewName': miraCrewName[crewNumber]}
    crewMetadata = refCrewCollection.find_one(queryCrewName)
    if crewMetadata:
      print("Already exists in MongoDB but may update roles")
      # Check if roles match
      if miraCrewRole[crewNumber] == "actor":
        if not crewMetadata['actorRole'] or crewMetadata['actorRole'] is None:
          print("Add actor to crew role")
          crew_record = {
            "actorRole": True
          }
          inserted_record = refCrewCollection.insert_one(crew_record)
          print(f"Inserted actor role - record ID: {inserted_record.inserted_id}")
      if miraCrewRole[crewNumber] == "director":
        if not crewMetadata['directorRole']  or crewMetadata['directorRole'] is None:
          print("Add director to crew role")
          crew_record = {
            "directorRole": True
          }
          inserted_record = refCrewCollection.insert_one(crew_record)
          print(f"Inserted director role - record ID: {inserted_record.inserted_id}")
    else:
      print("Adding new record to MongoDB")
      if miraCrewRole[crewNumber] == "actor":
        crew_record = {
          "crewName": miraCrewName[crewNumber],
          "miraId": miraCrewId[crewNumber],
          "miscId": None,
          "actorRole": True,
          "directorRole": None,
          "producerRole": None
        }
        inserted_record = refCrewCollection.insert_one(crew_record)
      if miraCrewRole[crewNumber] == "director":
        crew_record = {
          "crewName": miraCrewName[crewNumber],
          "miraId": miraCrewId[crewNumber],
          "miscId": None,
          "actorRole": None,
          "directorRole": True,
          "producerRole": None
        }
        inserted_record = refCrewCollection.insert_one(crew_record)
      print(f"Inserted new crew - record ID: {inserted_record.inserted_id}")
    #------------------------------
  #------------------------------
  #------------------------------

  queryTitleCode = {'titleCode': cantemoTitleCode}
  if cantemoTitleCode[0] == "M":
    catalogItemMetadata = movieCollection.find_one(queryTitleCode)
    print(f"{cantemoTitleCode} - Get information from movie collection")
  if cantemoTitleCode[0] == "S":
    catalogItemMetadata = seriesCollection.find_one(queryTitleCode)
    print(f"{cantemoTitleCode} - Get information from series collection")

  #------------------------------
  # Get information from Catalog Service
  for metadataItem, metadataValue in catalogItemMetadata.items():
    if metadataItem in ["cast", "director"]:
      if (metadataItem == "cast"):
        actorUuid = list(range(len(metadataValue)))
        for iCounter in range(len(metadataValue)):
          actorUuid[iCounter] = uuid.uuid4().hex[:16]
          print(f"Actor {iCounter} [{actorUuid[iCounter]}]: {metadataValue[iCounter]}")
          # Check if crew is already in Mira
          if metadataValue[iCounter] not in miraCrewName:
            print("Update Mira actor list")
          else:
            indexes = [i for i, val in enumerate(miraCrewName) if val == metadataValue[iCounter]]
            updateRoleFlag = 1
            for j in indexes:
              if miraCrewRole[j] == "actor":
                updateRoleFlag = 0
                print("Already in Mira as an actor")
            if updateRoleFlag == 1:
              print("Update crew role in Mira")
      if (metadataItem == "director"):
        directorUuid = list(range(len(metadataValue)))
        for iCounter in range(len(metadataValue)):
          directorUuid[iCounter] = uuid.uuid4().hex[:16]
          print(f"Director {iCounter} [{directorUuid[iCounter]}]: {metadataValue[iCounter]}")
          # Check if crew is already in Mira
          if metadataValue[iCounter] not in miraCrewName:
            print("Update Mira actor list")
          else:
            indexes = [i for i, val in enumerate(miraCrewName) if val == metadataValue[iCounter]]
            updateRoleFlag = 1
            for j in indexes:
              if miraCrewRole[j] == "director":
                updateRoleFlag = 0
                print("Already in Mira as a director")
            if updateRoleFlag == 1:
              print("Update crew role in Mira")
  #------------------------------

  # clientProd1.close()
  clientOdev.close()
  clientCluster0.close()

  del actorUuid
  del directorUuid

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