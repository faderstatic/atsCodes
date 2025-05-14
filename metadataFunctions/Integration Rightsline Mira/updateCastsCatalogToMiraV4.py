# /opt/cantemo/python/bin/python
# /usr/local/bin/python3
#!/usr/bin/python3

# This application ingests metadata from an XML API response into Cantemo
# PREREQUISITE: -none-
# 	Usage: aiEmailResult.py [Cantemo ItemID] [Cantemo Username] [analysis type]

#------------------------------
# Libraries
import os
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

  titleFile = sys.argv[1]
    
  # clientProd1.admin.command('ping')
  # print(f"Pinged your deployment. You successfully connected to Prod-1")
  # clientOdev.admin.command('ping')
  # print(f"Pinged your deployment. You successfully connected to OlympusatDev")

  #------------------------------
  # Opening MongoDB database for Cluster0
  cantemoDb = clientCluster0["cantemo"]
  refCrewCollection = cantemoDb["refCrew"]
  # Opening MongoDB database for Client0
  olyplatCatalog = clientOdev["olyplat_catalog"]
  catalogCollection = olyplatCatalog["catalog"]
  movieCollection = olyplatCatalog["movie"]
  episodeCollection = olyplatCatalog["episode"]
  seriesCollection = olyplatCatalog["series"]
  genreCollection = olyplatCatalog["genre_type"]
  #------------------------------

  #------------------------------
  # Creating Spanish accented characters translation
  accentedCharacters = "áéíóúÁÉÍÓÚñÑ"
  unaccentedCharacters = "aeiouAEIOUnN"
  translationTable = str.maketrans(accentedCharacters, unaccentedCharacters)
  #------------------------------

  titleFileExists = os.path.exists(titleFile)

  if titleFileExists:
    with open(titleFile, "r") as file:
      lines = file.readlines()
      #------------------------------
      # Control whether to update Mira
      printOnly = 1
      #------------------------------
      for cantemoTitleCodeLine in lines:
        if (cantemoTitleCodeLine[0] == "S") or (cantemoTitleCodeLine[0] == "M") or (cantemoTitleCodeLine[0] == "U"):
            cantemoTitleCode = cantemoTitleCodeLine.strip().split("_")[0]
        else:
          cantemoTitleCode = cantemoTitleCodeLine.strip()
        print(f"Processing: {cantemoTitleCode}")

        #------------------------------
        # Synchronizing synopsis
        updateSynopsisResult = "No need to update synopsis in Mira"
        titleEnDesc = titleEnShortDesc = titleEsDesc = titleEsShortDesc = ""
        itemEnDesc = itemEnShortDesc = itemEsDesc = itemEsShortDesc = ""
        itemEnDescExists = itemEnShortDescExists = itemEsDescExists = itemEsShortDescExists = updateMiraSynopsisFlag = 0
        titleEnDescExists = titleEnShortDescExists = titleEsDescExists = titleEsShortDescExists = 0
        miraEnDescExists = miraEnShortDescExists = miraEsDescExists = miraEsShortDescExists = 0
        # trySeriesEnDescFlag = trySeriesEnShortDescFlag = trySeriesEsDescFlag = trySeriesEsShortDescFlag = 1

        #------------------------------
        # Taking care of episodic synopsis
        if (cantemoTitleCode[0] == "S") and (len(cantemoTitleCode) > 10):
          #------------------------------
          # Get existing synopsis information from catalog
          queryTitleCode = {'titleCode': cantemoTitleCode}
          titleCodeMetadata = list(episodeCollection.find(queryTitleCode))
          if titleCodeMetadata:
            if "translations" in titleCodeMetadata[0]:
              if titleCodeMetadata[0]['translations']['en']['description'] != "":
                itemEnDescExists = 1
                # trySeriesEnDescFlag = 0
                itemEnDesc = titleCodeMetadata[0]['translations']['en']['description']
              if titleCodeMetadata[0]['translations']['en']['shortDescription'] != "":
                itemEnShortDescExists = 1
                # trySeriesEnShortDescFlag = 0
                itemEnShortDesc = titleCodeMetadata[0]['translations']['en']['shortDescription']
              if titleCodeMetadata[0]['translations']['es']['description'] != "":
                itemEsDescExists = 1
                # trySeriesEsDescFlag = 0
                itemEsDesc = titleCodeMetadata[0]['translations']['es']['description']
              if titleCodeMetadata[0]['translations']['es']['shortDescription'] != "":
                itemEsShortDescExists = 1
                # trySeriesEsShortDescFlag = 0
                itemEsShortDesc = titleCodeMetadata[0]['translations']['es']['shortDescription']
          # if (trySeriesEnDescFlag == 1) and (trySeriesEnShortDescFlag == 1) and (trySeriesEsDescFlag == 1) and (trySeriesEsShortDescFlag == 1):
          cantemoSeriesCode = cantemoTitleCode[:7]
          queryTitleCode = {'titleCode': cantemoSeriesCode}
          titleCodeMetadata = list(seriesCollection.find(queryTitleCode))
          if titleCodeMetadata:
            if "translations" in titleCodeMetadata[0]:
              if titleCodeMetadata[0]['translations']['en']['description'] != "":
                titleEnDescExists = 1
                titleEnDesc = titleCodeMetadata[0]['translations']['en']['description']
              if titleCodeMetadata[0]['translations']['en']['shortDescription'] != "":
                titleEnShortDescExists = 1
                titleEnShortDesc = titleCodeMetadata[0]['translations']['en']['shortDescription']
              if titleCodeMetadata[0]['translations']['es']['description'] != "":
                titleEsDescExists = 1
                titleEsDesc = titleCodeMetadata[0]['translations']['es']['description']
              if titleCodeMetadata[0]['translations']['es']['shortDescription'] != "":
                titleEsShortDescExists = 1
                titleEsShortDesc = titleCodeMetadata[0]['translations']['es']['shortDescription']
          #------------------------------

          #------------------------------
          # Analyse information from Mira
          urlMira = f"http://10.1.1.22:83/Service1.svc/title_episodes/{cantemoTitleCode}"
          payload = ""
          headers = {
            'Content-Type': 'text/plain; charset=UTF-8',
          }

          miraResponse = requests.request("GET", urlMira, headers=headers, data=payload)
          miraResponse.raise_for_status
          #------------------------------
          # Parsing JSON data
          responseJson = miraResponse.json() if miraResponse and miraResponse.status_code == 200 else None
          # print(responseJson)
          miraSynopsisMissing = 0
          if "id_title_episodes" in responseJson[0]:
            miraId = responseJson[0]['id_title_episodes']
            payloadEpisode = f"{{\r\n    \"id_title_episodes\": {miraId},\r\n    \"episode_synopsis\": ["
            # miraTitleId = responseJson[0]['id_titles']
            if "episode_synopsis" in responseJson[0]:
              miraEpisodeSynopsis = responseJson[0]['episode_synopsis']
              # print(f"Description - {responseJson[0]['description']}")
              if miraEpisodeSynopsis:
                for synopsisType in miraEpisodeSynopsis:
                  if synopsisType['id_synopsis_types'] == 22:
                    if (synopsisType['synopsis'] == "") and itemEnDescExists:
                      updateMiraSynopsisFlag = 1
                      payloadEpisode = f"{payloadEpisode}\r\n        {{\r\n            \"id_synopsis_types\": 22,\r\n            \"synopsis\": \"{itemEnDesc.replace('"', '\\"')}\"}},"
                    elif (synopsisType['synopsis'] == "") and titleEnDescExists:
                      updateMiraSynopsisFlag = 1
                      payloadEpisode = f"{payloadEpisode}\r\n        {{\r\n            \"id_synopsis_types\": 22,\r\n            \"synopsis\": \"{titleEnDesc.replace('"', '\\"')}\"}},"
                    else:
                      print(f"  Mira Long Description En: {synopsisType['synopsis']}")
                  if synopsisType['id_synopsis_types'] == 21:
                    if (synopsisType['synopsis'] == "") and itemEnShortDescExists:
                      updateMiraSynopsisFlag = 1
                      payloadEpisode = f"{payloadEpisode}\r\n        {{\r\n            \"id_synopsis_types\": 21,\r\n            \"synopsis\": \"{itemEnShortDesc.replace('"', '\\"')}\"}},"
                    elif (synopsisType['synopsis'] == "") and titleEnShortDescExists:
                      updateMiraSynopsisFlag = 1
                      payloadEpisode = f"{payloadEpisode}\r\n        {{\r\n            \"id_synopsis_types\": 21,\r\n            \"synopsis\": \"{titleEnShortDesc.replace('"', '\\"')}\"}},"
                    else:
                      print(f"  Mira Short Description En: {synopsisType['synopsis']}")
                  if synopsisType['id_synopsis_types'] == 2:
                    if (synopsisType['synopsis'] == "") and itemEsDescExists:
                      updateMiraSynopsisFlag = 1
                      payloadEpisode = f"{payloadEpisode}\r\n        {{\r\n            \"id_synopsis_types\": 2,\r\n            \"synopsis\": \"{itemEsDesc.replace('"', '\\"')}\"}},"
                    elif (synopsisType['synopsis'] == "") and titleEsDescExists:
                      updateMiraSynopsisFlag = 1
                      payloadEpisode = f"{payloadEpisode}\r\n        {{\r\n            \"id_synopsis_types\": 2,\r\n            \"synopsis\": \"{titleEsDesc.replace('"', '\\"')}\"}},"
                    else:
                      print(f"  Mira Long Description Es: {synopsisType['synopsis']}")
                  if synopsisType['id_synopsis_types'] == 1:
                    if (synopsisType['synopsis'] == "") and itemEsShortDescExists:
                      updateMiraSynopsisFlag = 1
                      payloadEpisode = f"{payloadEpisode}\r\n        {{\r\n            \"id_synopsis_types\": 1,\r\n            \"synopsis\": \"{itemEsShortDesc.replace('"', '\\"')}\"}},"
                    elif (synopsisType['synopsis'] == "") and titleEsShortDescExists:
                      updateMiraSynopsisFlag = 1
                      payloadEpisode = f"{payloadEpisode}\r\n        {{\r\n            \"id_synopsis_types\": 1,\r\n            \"synopsis\": \"{titleEsShortDesc.replace('"', '\\"')}\"}},"
                    else:
                      print(f"  Mira Short Description Es: {synopsisType['synopsis']}")
              else:
                miraSynopsisMissing = 1
            else:
              miraSynopsisMissing = 1
          else:
            print(f"This item [{cantemoTitleCode}] does not exist in Mira - will need to be created")
          if miraSynopsisMissing:
            if itemEnDescExists:
              payloadEpisode = f"{payloadEpisode}\r\n        {{\r\n            \"id_synopsis_types\": 22,\r\n            \"synopsis\": \"{itemEnDesc.replace('"', '\\"')}\"}},"
            elif titleEnDescExists:
              payloadEpisode = f"{payloadEpisode}\r\n        {{\r\n            \"id_synopsis_types\": 22,\r\n            \"synopsis\": \"{titleEnDesc.replace('"', '\\"')}\"}},"
            if itemEnShortDescExists:
              payloadEpisode = f"{payloadEpisode}\r\n        {{\r\n            \"id_synopsis_types\": 21,\r\n            \"synopsis\": \"{itemEnShortDesc.replace('"', '\\"')}\"}},"
            elif titleEnShortDescExists:
              payloadEpisode = f"{payloadEpisode}\r\n        {{\r\n            \"id_synopsis_types\": 21,\r\n            \"synopsis\": \"{titleEnShortDesc.replace('"', '\\"')}\"}},"
            if itemEsDescExists:
              payloadEpisode = f"{payloadEpisode}\r\n        {{\r\n            \"id_synopsis_types\": 2,\r\n            \"synopsis\": \"{itemEsDesc.replace('"', '\\"')}\"}},"
            elif titleEsDescExists:
              payloadEpisode = f"{payloadEpisode}\r\n        {{\r\n            \"id_synopsis_types\": 2,\r\n            \"synopsis\": \"{titleEsDesc.replace('"', '\\"')}\"}},"
            if itemEsShortDescExists:
              payloadEpisode = f"{payloadEpisode}\r\n        {{\r\n            \"id_synopsis_types\": 1,\r\n            \"synopsis\": \"{itemEsShortDesc.replace('"', '\\"')}\"}},"
            elif titleEsShortDescExists:
              payloadEpisode = f"{payloadEpisode}\r\n        {{\r\n            \"id_synopsis_types\": 1,\r\n            \"synopsis\": \"{titleEsShortDesc.replace('"', '\\"')}\"}},"
          #------------------------------
          trimmedPayloadEpisode = payloadEpisode[:-1]
          rawPayloadEpisode = f"{trimmedPayloadEpisode}\r\n    ]\r\n}}"
          payloadEpisode = rawPayloadEpisode.encode('utf-8')
          if (updateMiraSynopsisFlag == 1) and (printOnly != 1):
            urlMiraEpisodeUpdate = "http://10.1.1.22:83/Service1.svc/title_episodes"
            response = requests.request("PUT", urlMiraEpisodeUpdate, headers=headers, data=payloadEpisode)
            jsonResponse = response.json()
            if jsonResponse == "null":
              updateSynopsisResult = "Updated episode synopsis information in Mira - result: success"
            else:
              updateSynopsisResult = f" Updated episode synopsis information in Mira - result: {jsonResponse}"
          else:
            print(f"--- Update Mira? - {updateMiraSynopsisFlag}")
            print(f"--- Payload for item: {rawPayloadEpisode}")
          #------------------------------
        # DONE Taking care of episodic synopsis
        #------------------------------

        #------------------------------
        # Taking care of movie and title synopsis
        
        #------------------------------
        # Get existing synopsis information from catalog
        fullCantemoTitleCode = cantemoTitleCode
        if (cantemoTitleCode[0] == "S"):
          lastECharacter = cantemoTitleCode.rfind("E")
          cantemoSeasonCode = cantemoTitleCode[:lastECharacter]
          cantemoSeriesCode = cantemoTitleCode[:7]
          queryTitleCode = {'titleCode': cantemoSeriesCode}
          titleCodeMetadata = list(seriesCollection.find(queryTitleCode))
          urlMira = f"http://10.1.1.22:83/Service1.svc/titles/{cantemoSeasonCode}"
        else:
          queryTitleCode = {'titleCode': cantemoTitleCode}
          titleCodeMetadata = list(movieCollection.find(queryTitleCode))
          urlMira = f"http://10.1.1.22:83/Service1.svc/titles/{cantemoTitleCode}"
        if titleCodeMetadata:
          if "translations" in titleCodeMetadata[0]:
            if titleCodeMetadata[0]['translations']['en']['description'] != "":
              titleEnDescExists = 1
              titleEnDesc = titleCodeMetadata[0]['translations']['en']['description']
            if titleCodeMetadata[0]['translations']['en']['shortDescription'] != "":
              titleEnShortDescExists = 1
              titleEnShortDesc = titleCodeMetadata[0]['translations']['en']['shortDescription']
            if titleCodeMetadata[0]['translations']['es']['description'] != "":
              titleEsDescExists = 1
              titleEsDesc = titleCodeMetadata[0]['translations']['es']['description']
            if titleCodeMetadata[0]['translations']['es']['shortDescription'] != "":
              titleEsShortDescExists = 1
              titleEsShortDesc = titleCodeMetadata[0]['translations']['es']['shortDescription']
        #------------------------------
        # Analyse information from Mira
        # urlMira = f"http://10.1.1.22:83/Service1.svc/titles/{cantemoTitleCode}"
        payload = ""
        headers = {
          'Content-Type': 'text/plain; charset=UTF-8',
        }
        
        miraResponse = requests.request("GET", urlMira, headers=headers, data=payload)
        miraResponse.raise_for_status
        #------------------------------
        # Parsing JSON data
        responseJson = miraResponse.json() if miraResponse and miraResponse.status_code == 200 else None
        miraSynopsisMissing = updateMiraSynopsisFlag = 0
        if "id_titles" in responseJson[0]:
          miraId = responseJson[0]['id_titles']
          payloadEpisode = f"{{\r\n    \"id_titles\": {miraId},\r\n    \"title_synopsis\": ["
          # miraTitleId = responseJson[0]['id_titles']
          if "title_synopsis" in responseJson[0]:
            miraEpisodeSynopsis = responseJson[0]['title_synopsis']
            # print(f"Description - {responseJson[0]['description']}")
            if miraEpisodeSynopsis:
              for synopsisType in miraEpisodeSynopsis:
                if synopsisType['id_synopsis_types'] == 22:
                  if (synopsisType['synopsis'] == "") and itemEnDescExists:
                    updateMiraSynopsisFlag = 1
                    payloadEpisode = f"{payloadEpisode}\r\n        {{\r\n            \"id_synopsis_types\": 22,\r\n            \"synopsis\": \"{itemEnDesc.replace('"', '\\"')}\"}},"
                  # print(f"Long Description En: {synopsisType['synopsis']}")
                  elif (synopsisType['synopsis'] == "") and titleEnDescExists:
                    updateMiraSynopsisFlag = 1
                    payloadEpisode = f"{payloadEpisode}\r\n        {{\r\n            \"id_synopsis_types\": 22,\r\n            \"synopsis\": \"{titleEnDesc.replace('"', '\\"')}\"}},"
                if synopsisType['id_synopsis_types'] == 21:
                  if (synopsisType['synopsis'] == "") and itemEnShortDescExists:
                    updateMiraSynopsisFlag = 1
                    payloadEpisode = f"{payloadEpisode}\r\n        {{\r\n            \"id_synopsis_types\": 21,\r\n            \"synopsis\": \"{itemEnShortDesc.replace('"', '\\"')}\"}},"
                  # print(f"Short Description En: {synopsisType['synopsis']}")
                  elif (synopsisType['synopsis'] == "") and titleEnShortDescExists:
                    updateMiraSynopsisFlag = 1
                    payloadEpisode = f"{payloadEpisode}\r\n        {{\r\n            \"id_synopsis_types\": 21,\r\n            \"synopsis\": \"{titleEnShortDesc.replace('"', '\\"')}\"}},"
                if synopsisType['id_synopsis_types'] == 2:
                  if (synopsisType['synopsis'] == "") and itemEsDescExists:
                    updateMiraSynopsisFlag = 1
                    payloadEpisode = f"{payloadEpisode}\r\n        {{\r\n            \"id_synopsis_types\": 2,\r\n            \"synopsis\": \"{itemEsDesc.replace('"', '\\"')}\"}},"
                  # print(f"Long Description Es: {synopsisType['synopsis']}")
                  elif (synopsisType['synopsis'] == "") and titleEsDescExists:
                    updateMiraSynopsisFlag = 1
                    payloadEpisode = f"{payloadEpisode}\r\n        {{\r\n            \"id_synopsis_types\": 2,\r\n            \"synopsis\": \"{titleEsDesc.replace('"', '\\"')}\"}},"
                if synopsisType['id_synopsis_types'] == 1:
                  if (synopsisType['synopsis'] == "") and itemEsShortDescExists:
                    updateMiraSynopsisFlag = 1
                    payloadEpisode = f"{payloadEpisode}\r\n        {{\r\n            \"id_synopsis_types\": 1,\r\n            \"synopsis\": \"{itemEsShortDesc.replace('"', '\\"')}\"}},"
                  # print(f"Short Description Es: {synopsisType['synopsis']}")
                  elif (synopsisType['synopsis'] == "") and titleEsShortDescExists:
                    updateMiraSynopsisFlag = 1
                    payloadEpisode = f"{payloadEpisode}\r\n        {{\r\n            \"id_synopsis_types\": 1,\r\n            \"synopsis\": \"{titleEsShortDesc.replace('"', '\\"')}\"}},"
            else:
              miraSynopsisMissing = 1
          else:
            miraSynopsisMissing = 1
        else:
          miraSynopsisMissing = 1
        if updateMiraSynopsisFlag:
          if titleEnDescExists:
            payloadEpisode = f"{payloadEpisode}\r\n        {{\r\n            \"id_synopsis_types\": 22,\r\n            \"synopsis\": \"{titleEnDesc.replace('"', '\\"')}\"}},"
          if titleEnShortDescExists:
            payloadEpisode = f"{payloadEpisode}\r\n        {{\r\n            \"id_synopsis_types\": 21,\r\n            \"synopsis\": \"{titleEnShortDesc.replace('"', '\\"')}\"}},"
          if titleEsDescExists:
            payloadEpisode = f"{payloadEpisode}\r\n        {{\r\n            \"id_synopsis_types\": 2,\r\n            \"synopsis\": \"{titleEsDesc.replace('"', '\\"')}\"}},"
          if titleEsShortDescExists:
            payloadEpisode = f"{payloadEpisode}\r\n        {{\r\n            \"id_synopsis_types\": 1,\r\n            \"synopsis\": \"{titleEsShortDesc.replace('"', '\\"')}\"}},"
        #------------------------------
        trimmedPayloadEpisode = payloadEpisode[:-1]
        rawPayloadEpisode = f"{trimmedPayloadEpisode}\r\n    ]\r\n}}"
        payloadEpisode = rawPayloadEpisode.encode('utf-8')
        if (updateMiraSynopsisFlag == 1) and (printOnly != 1):
          urlMiraEpisodeUpdate = "http://10.1.1.22:83/Service1.svc/titles"
          response = requests.request("PUT", urlMiraEpisodeUpdate, headers=headers, data=payloadEpisode)
          jsonResponse = response.json()
          if jsonResponse == "null":
            updateSynopsisResult = "Updated episode synopsis information in Mira - result: success"
          else:
            updateSynopsisResult = f" Updated episode synopsis information in Mira - result: {jsonResponse}"
        else:
          print(f"--- Update Mira? - {updateMiraSynopsisFlag}")
          print(f"--- Payload for title: {rawPayloadEpisode}")
        #------------------------------
        # DONE Taking care of movie and title synopsis
        #------------------------------

        # urlMira = f"http://10.1.1.22:83/Service1.svc/titles/{cantemoTitleCode}"
        payload = ""
        headers = {
          'Content-Type': 'text/plain; charset=UTF-8',
        }
        # print(f"Cantemo ID used - {cantemoTitleCode}")
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
                  if (crewRole['actorRole'] is True) and (crewRole['miraItemId'] == miraId):
                    updateRoleFlag = 0
                    print("  Already in Catalog Service as an actor for this Mira item")
                if miraCrewRole[crewNumber] == "director":
                  if (crewRole['directorRole'] is True) and (crewRole['miraItemId'] == miraId):
                    updateRoleFlag = 0
                    print("  Already in Catalog Service as a director for this Mira item")
            else:
              updateRoleFlag = 0
            if updateRoleFlag == 1:
              print("  Creating new role for this crew")
              if miraCrewRole[crewNumber] == "actor":
                crew_record = {
                  "crewName": miraCrewName[crewNumber],
                  "miraItemId": miraId,
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
                  "miraItemId": miraId,
                  "miraId": miraCrewId[crewNumber],
                  "miscId": None,
                  "actorRole": None,
                  "directorRole": True,
                  "producerRole": None
                }
                inserted_record = refCrewCollection.insert_one(crew_record)
              print(f"  Inserted new crew - record ID: {inserted_record.inserted_id}")
              print(f"  Adding new cast member from Mira to reference database: {crew_record}")
            #------------------------------
        #------------------------------
        #------------------------------

        if cantemoTitleCode[0] == "M":
          queryTitleCode = {'titleCode': cantemoTitleCode}
          catalogItemMetadata = movieCollection.find_one(queryTitleCode)
          print(f"--- Getting information for {cantemoTitleCode} from movie collection ---")
        if cantemoTitleCode[0] == "S":
          queryTitleCode = {'titleCode': fullCantemoTitleCode[:7]}
          catalogItemMetadata = seriesCollection.find_one(queryTitleCode)
          print(f"--- Getting information for {cantemoTitleCode} from series collection ---")
        
        #------------------------------
        # Get information from Catalog Service
        updateCastFlag = 0
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
                    if (crewEntry['actorRole'] is True) and (crewEntry['miraItemId'] == miraId):
                      actorUuid[iCounter] = crewEntry['miraId']
                      updateRoleFlag = 0
                      print("  Already exists in MongoDB with actor roles")
                if updateRoleFlag == 1:
                  print("  Adding new actor record to MongoDB")
                  crew_record = {
                    "crewName": metadataValue[iCounter],
                    "miraItemId": miraId,
                    "miraId": actorUuid[iCounter],
                    "miscId": None,
                    "actorRole": True,
                    "directorRole": None,
                    "producerRole": None
                  }
                  inserted_record = refCrewCollection.insert_one(crew_record)
                  print(f"  Inserted new crew - record ID: {inserted_record.inserted_id}")
                  print(f"  Adding new actor from Catalog to reference database: {crew_record}")
                #------------------------------
                payload = f"{payload}\r\n        {{\r\n            \"id_positions\": 1,\r\n            \"first_name\": \"{metadataValue[iCounter].strip().replace('"', '\\"')}\",\r\n            \"external_ident\": \"{actorUuid[iCounter]}\"\r\n        }},"
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
                    if (crewEntry['directorRole'] is True) and (crewEntry['miraItemId'] == miraId):
                      print("  Already exists in MongoDB with director roles")
                      directorUuid[iCounter] = crewEntry['miraId']
                      updateRoleFlag = 0
                if updateRoleFlag == 1:
                  print("  Add new director record to MongoDB")
                  crew_record = {
                    "crewName": metadataValue[iCounter],
                    "miraItemId": miraId,
                    "miraId": directorUuid[iCounter],
                    "miscId": None,
                    "actorRole": None,
                    "directorRole": True,
                    "producerRole": None
                  }
                  inserted_record = refCrewCollection.insert_one(crew_record)
                  print(f"  Inserted new crew - record ID: {inserted_record.inserted_id}")
                  print(f"  Adding new director from Catalog to reference database: {crew_record}")
                #------------------------------
                payload = f"{payload}\r\n        {{\r\n            \"id_positions\": 2,\r\n            \"first_name\": \"{metadataValue[iCounter].strip().replace('"', '\\"')}\",\r\n            \"external_ident\": \"{directorUuid[iCounter]}\"\r\n        }},"
          
        trimmedPayload = payload[:-1]
        urlMiraUpdate = "http://10.1.1.22:83/Service1.svc/titles"
        rawPayload = f"{trimmedPayload}\r\n    ]\r\n}}"
        payload = rawPayload.encode('utf-8')
        # payload = json.dumps(rawPayload, ensure_ascii=False).encode('utf-8')
        if printOnly != 1:
          print(updateSynopsisResult)
          response = requests.request("PUT", urlMiraUpdate, headers=headers, data=payload)
          jsonResponse = response.json()
          if jsonResponse == "null":
            print("Updated crew information in Mira - result: success")
          else:
            print(f" Updated crew information in Mira - result: {jsonResponse}")
        else:
          print(f"Cast update: {rawPayload}")
        #------------------------------
        print("----------------------------------------")
        del actorUuid
        del directorUuid
        time.sleep(2)
        #------------------------------
        # Update The User
        # print(f"{cantemoOriginalTitleWhite} (without accents: {cantemoOriginalTitle}) - {cantemoTitleCode}")
        #------------------------------
      #------------------------------
  else:
    print("Source file does not exist")
  # clientProd1.close()
  clientOdev.close()
  clientCluster0.close()


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