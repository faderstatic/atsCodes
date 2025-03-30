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
  if miraCrew != None:
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
    print(f"--- Getting information for {cantemoTitleCode} from Mira ---")
    for crewNumber in range(miraCrewCount):
      print(f"{miraCrewRole[crewNumber]}: {miraCrewName[crewNumber]} ({miraCrewId[crewNumber]})")
      #------------------------------
      # Check if crews from Mira already exist in the database and update
      queryCrewName = {'crewName': miraCrewName[crewNumber]}
      crewMetadata = list(refCrewCollection.find(queryCrewName))
      updateRoleFlag = 1
      if crewMetadata:
        for crewRole in crewMetadata:
          if miraCrewRole[crewNumber] == "actor":
            if crewRole['actorRole'] is True:
              updateRoleFlag = 0
              print("  Already in Catalog Service as an actor")
          if miraCrewRole[crewNumber] == "director":
            if crewRole['directorRole'] is True:
              updateRoleFlag = 0
              print("  Already in Catalog Service as a director")
      else:
        updateRoleFlag = 0
      if updateRoleFlag == 1:
        print("  Creating new role for this crew")
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
        print(f"  Inserted new crew - record ID: {inserted_record.inserted_id}")
      #------------------------------
  #------------------------------
  #------------------------------

  queryTitleCode = {'titleCode': cantemoTitleCode}
  if cantemoTitleCode[0] == "M":
    catalogItemMetadata = movieCollection.find_one(queryTitleCode)
    print(f"--- Getting information for {cantemoTitleCode} from movie collection ---")
  if cantemoTitleCode[0] == "S":
    catalogItemMetadata = seriesCollection.find_one(queryTitleCode)
    print(f"--- Getting information for {cantemoTitleCode} from series collection ---")
  
  #------------------------------
  # Get information from Catalog Service
  updateMiraMedataFlag = 0
  payload = f"{{\r\n    \"id_titles\": {miraId},\r\n    \"title_subjects\": ["
  for metadataItem, metadataValue in catalogItemMetadata.items():
    if metadataItem in ["cast", "director"]:
      # Working on actors
      if (metadataItem == "cast"):
        actorUuid = list(range(len(metadataValue)))
        for iCounter in range(len(metadataValue)):
          actorUuid[iCounter] = uuid.uuid4().hex[:16]
          print(f"actor: {metadataValue[iCounter]} ({actorUuid[iCounter]})")

          #------------------------------
          # Check if crews from Catalog Service already exist in the database and update
          queryCrewName = {'crewName': metadataValue[iCounter]}
          crewMetadata = list(refCrewCollection.find(queryCrewName))
          updateRoleFlag = 1
          if crewMetadata:
            for crewEntry in crewMetadata:
              if crewEntry['actorRole'] is True:
                actorUuid[iCounter] = crewEntry['miraId']
                updateRoleFlag = 0
                print("  Already exists in MongoDB with actor roles")
          if updateRoleFlag == 1:
            print("  Adding new actor record to MongoDB")
            crew_record = {
              "crewName": metadataValue[iCounter],
              "miraId": actorUuid[iCounter],
              "miscId": None,
              "actorRole": True,
              "directorRole": None,
              "producerRole": None
            }
            inserted_record = refCrewCollection.insert_one(crew_record)
            print(f"  Inserted new crew - record ID: {inserted_record.inserted_id}")
          #------------------------------
          payload = f"{payload}\r\n        {{\r\n            \"id_positions\": 1,\r\n            \"first_name\": \"{metadataValue[iCounter]}\",\r\n            \"external_ident\": \"{actorUuid[iCounter]}\"\r\n        }},"
      # Working on directors
      if (metadataItem == "director"):
        directorUuid = list(range(len(metadataValue)))
        for iCounter in range(len(metadataValue)):
          directorUuid[iCounter] = uuid.uuid4().hex[:16]
          print(f"director: {metadataValue[iCounter]} ({directorUuid[iCounter]})")

          #------------------------------
          # Check if crews from Catalog Service already exist in the database and update
          queryCrewName = {'crewName': metadataValue[iCounter]}
          crewMetadata = list(refCrewCollection.find(queryCrewName))
          updateRoleFlag = 1
          if crewMetadata:
            for crewEntry in crewMetadata:
              if crewEntry['directorRole'] is True:
                print("  Already exists in MongoDB with director roles")
                directorUuid[iCounter] = crewEntry['miraId']
                updateRoleFlag = 0
          if updateRoleFlag == 1:
            print("  Add new director record to MongoDB")
            crew_record = {
              "crewName": metadataValue[iCounter],
              "miraId": directorUuid[iCounter],
              "miscId": None,
              "actorRole": None,
              "directorRole": True,
              "producerRole": None
            }
            inserted_record = refCrewCollection.insert_one(crew_record)
            print(f"  Inserted new crew - record ID: {inserted_record.inserted_id}")
        #------------------------------
          payload = f"{payload}\r\n        {{\r\n            \"id_positions\": 2,\r\n            \"first_name\": \"{metadataValue[iCounter]}\",\r\n            \"external_ident\": \"{directorUuid[iCounter]}\"\r\n        }},"
    
  trimmedPayload = payload[:-1]
  urlMiraUpdate = "http://10.1.1.22:83/Service1.svc/titles"
  rawPayload = f"{trimmedPayload}\r\n    ]\r\n}}"
  headers = {
    'Content-Type': 'text/plain; charset=utf-8',
    'accept': 'application/json'
  }
  payload = rawPayload
  # print(payload)
  response = requests.request("PUT", urlMiraUpdate, headers=headers, data=payload)
  print(f" Updated crew inforamation in Mira - result: {response.text}")
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