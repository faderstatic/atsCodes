# /opt/cantemo/python/bin/python
# /usr/local/bin/python3
#!/usr/bin/python3

# This application ingests metadata from an XML API response into Cantemo
# PREREQUISITE: -none-
# 	Usage: aiEmailResult.py [Cantemo ItemID] [Cantemo Username] [analysis type]

#------------------------------
# Libraries
import os
import io
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
  outputMethod = sys.argv[2]
  outputFile = sys.argv[3]

  #------------------------------
  # Control whether to update Mira
  if outputMethod == "test":
    printOnly = 1
  else:
    printOnly = 0
  #------------------------------

    
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
      with open(outputFile, 'w') as outFile:
        for cantemoTitleCodeLine in lines:
          if (cantemoTitleCodeLine[0] == "S") or (cantemoTitleCodeLine[0] == "M") or (cantemoTitleCodeLine[0] == "U"):
              cantemoTitleCode = cantemoTitleCodeLine.strip().split("_")[0]
          else:
            cantemoTitleCode = cantemoTitleCodeLine.strip()
          print(f"-------------------- Processing: {cantemoTitleCode} --------------------")
          outFile.write(f"--------------------Processing: {cantemoTitleCode} --------------------\n")
          #------------------------------
          # Synchronizing synopsis
          titleEnDesc = titleEnShortDesc = titleEsDesc = titleEsShortDesc = ""
          itemEnDesc = itemEnShortDesc = itemEsDesc = itemEsShortDesc = ""
          itemEnDescExists = itemEnShortDescExists = itemEsDescExists = itemEsShortDescExists = updateMiraSynopsisFlag = 0
          titleEnDescExists = titleEnShortDescExists = titleEsDescExists = titleEsShortDescExists = 0
          miraEnDescExists = miraEnShortDescExists = miraEsDescExists = miraEsShortDescExists = 0
          updateItemSynopsisResult = "Did not update item information in Mira"
          updateTitleSynopsisResult = "Did not update title information in Mira"
          # trySeriesEnDescFlag = trySeriesEnShortDescFlag = trySeriesEsDescFlag = trySeriesEsShortDescFlag = 1

          #------------------------------
          # Taking care of episodic synopsis
          outFile.write("--- Looking at synopsis in item ---\n")
          print("--- Looking at synopsis in item ---")
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
                  ccItemEnDesc = len(itemEnDesc)
                  if outputMethod == "file":
                    outFile.write(f"* Item Description English Exists *: {itemEnDesc}\n")
                  else:
                    print(f"* Item Description English Exists *: {itemEnDesc}")
                if titleCodeMetadata[0]['translations']['en']['shortDescription'] != "":
                  itemEnShortDescExists = 1
                  # trySeriesEnShortDescFlag = 0
                  itemEnShortDesc = titleCodeMetadata[0]['translations']['en']['shortDescription']
                  ccItemEnShortDesc = len(itemEnShortDesc)
                  if outputMethod == "file":
                    outFile.write(f"* Item Short Description English Exists *: {itemEnShortDesc}\n")
                  else:
                    print(f"* Item Short Description English Exists *: {itemEnShortDesc}")
                if titleCodeMetadata[0]['translations']['es']['description'] != "":
                  itemEsDescExists = 1
                  # trySeriesEsDescFlag = 0
                  itemEsDesc = titleCodeMetadata[0]['translations']['es']['description']
                  ccItemEsDesc = len(itemEsDesc)
                  if outputMethod == "file":
                    outFile.write(f"* Item Description Spanish Exists *: {itemEsDesc}\n")
                  else:
                    print(f"* Item Description Spanish Exists *: {itemEsDesc}")
                if titleCodeMetadata[0]['translations']['es']['shortDescription'] != "":
                  itemEsShortDescExists = 1
                  # trySeriesEsShortDescFlag = 0
                  itemEsShortDesc = titleCodeMetadata[0]['translations']['es']['shortDescription']
                  ccItemEsShortDesc = len(itemEsShortDesc)
                  if outputMethod == "file":
                    outFile.write(f"* Item Short Description Spanish Exists *: {itemEsShortDesc}\n")
                  else:
                    print(f"* Item Short Description Spanish Exists *: {itemEsShortDesc}")
            # if (trySeriesEnDescFlag == 1) and (trySeriesEnShortDescFlag == 1) and (trySeriesEsDescFlag == 1) and (trySeriesEsShortDescFlag == 1):
            cantemoSeriesCode = cantemoTitleCode[:7]
            queryTitleCode = {'titleCode': cantemoSeriesCode}
            titleCodeMetadata = list(seriesCollection.find(queryTitleCode))
            if titleCodeMetadata:
              if "translations" in titleCodeMetadata[0]:
                if titleCodeMetadata[0]['translations']['en']['description'] != "":
                  titleEnDescExists = 1
                  titleEnDesc = titleCodeMetadata[0]['translations']['en']['description']
                  ccTitleEnDesc = len(titleEnDesc)
                  if outputMethod == "file":
                    outFile.write(f"* Title Description English Exists *: {titleEnDesc}\n")
                  else:
                    print(f"* Title Description English Exists *: {titleEnDesc}")
                if titleCodeMetadata[0]['translations']['en']['shortDescription'] != "":
                  titleEnShortDescExists = 1
                  titleEnShortDesc = titleCodeMetadata[0]['translations']['en']['shortDescription']
                  ccTitleEnShortDesc = len(titleEnShortDesc)
                  if outputMethod == "file":
                    outFile.write(f"* Title Short Description English Exists *: {titleEnShortDesc}\n")
                  else:
                    print(f"* Title Short Description English Exists *: {titleEnShortDesc}")
                if titleCodeMetadata[0]['translations']['es']['description'] != "":
                  titleEsDescExists = 1
                  titleEsDesc = titleCodeMetadata[0]['translations']['es']['description']
                  ccTitleEsDesc = len(titleEsDesc)
                  if outputMethod == "file":
                    outFile.write(f"* Title Description Spanish Exists *: {titleEsDesc}\n")
                  else:
                    print(f"* Title Description Spanish Exists *: {titleEsDesc}")
                if titleCodeMetadata[0]['translations']['es']['shortDescription'] != "":
                  titleEsShortDescExists = 1
                  titleEsShortDesc = titleCodeMetadata[0]['translations']['es']['shortDescription']
                  ccTitleEsShortDesc = len(titleEsShortDesc)
                  if outputMethod == "file":
                    outFile.write(f"* Title Short Description Spanish Exists: {titleEsShortDesc}\n")
                  else:
                    print(f"* Title Short Description Spanish Exists: {titleEsShortDesc}")
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
            missingMiraEn = missingMiraEnShort = missingMiraEs = missingMiraEsShort = 1
            if "id_title_episodes" in responseJson[0]:
              miraId = responseJson[0]['id_title_episodes']
              payloadEpisode = f"{{\r\n    \"id_title_episodes\": {miraId},\r\n    \"episode_synopsis\": ["
              # miraTitleId = responseJson[0]['id_titles']
              if "episode_synopsis" in responseJson[0]:
                miraEpisodeSynopsis = responseJson[0]['episode_synopsis']
                # print(f"Description - {responseJson[0]['description']}")
                if miraEpisodeSynopsis:
                  for synopsisType in miraEpisodeSynopsis:
                    if (synopsisType['id_synopsis_types'] == 22) and (synopsisType['synopsis'] != ""):
                      missingMiraEn = 0
                      miraItemEn = synopsisType['synopsis'].replace('"', r'\"')
                      ccMiraItemEn = len(miraItemEn)
                      if outputMethod == "file":
                        outFile.write("* Mira item contains English Description *\n")
                      else:
                        print("* Mira item contains English Description *")
                    if (synopsisType['id_synopsis_types'] == 21) and (synopsisType['synopsis'] != ""):
                      missingMiraEnShort = 0
                      miraItemEnShort = synopsisType['synopsis'].replace('"', r'\"')
                      ccMiraItemEnShort = len(miraItemEnShort)
                      if outputMethod == "file":
                        outFile.write("* Mira item contains Short English Description *\n")
                      else:
                        print("* Mira item contains Short English Description *")
                    if (synopsisType['id_synopsis_types'] == 2) and (synopsisType['synopsis'] != ""):
                      missingMiraEs = 0
                      miraItemEs = synopsisType['synopsis'].replace('"', r'\"')
                      ccMiraItemEs = len(miraItemEs)
                      if outputMethod == "file":
                        outFile.write("* Mira item contains Spanish Description *\n")
                      else:
                        print("* Mira item contains Spanish Description *")
                    if (synopsisType['id_synopsis_types'] == 1) and (synopsisType['synopsis'] != ""):
                      missingMiraEsShort = 0
                      miraItemEsShort = synopsisType['synopsis'].replace('"', r'\"')
                      ccMiraItemEsShort = len(miraItemEsShort)
                      if outputMethod == "file":
                        outFile.write("* Mira item contains Short Spanish Description *\n")
                      else:
                        print("* Mira item contains Short Spanish Description *")
            if missingMiraEn and itemEnDescExists:
            # if missingMiraEn and itemEnDescExists and (ccItemEnDesc <= 250):
            # if itemEnDescExists and (ccItemEnDesc <= 250):
              updateMiraSynopsisFlag = 1
              payloadEpisode = f"{payloadEpisode}\r\n        {{\r\n            \"id_synopsis_types\": 22,\r\n            \"synopsis\": \"{itemEnDesc.replace('"', '\\"')}\"}},"
              if outputMethod == "file":
                outFile.write("*** Filling in English description into Mira item from catalog item description English ***\n")
              else:
                print("*** Filling in English description into Mira item from catalog item description English ***")
            elif missingMiraEn and titleEnDescExists:
            # elif missingMiraEn and titleEnDescExists and (ccTitleEnDesc <= 250):
            # elif titleEnDescExists and (ccTitleEnDesc <= 250):
              updateMiraSynopsisFlag = 1
              payloadEpisode = f"{payloadEpisode}\r\n        {{\r\n            \"id_synopsis_types\": 22,\r\n            \"synopsis\": \"{titleEnDesc.replace('"', '\\"')}\"}},"
              if outputMethod == "file":
                outFile.write("*** Filling in English description into Mira item from catalog title description English ***\n")
              else:
                print("*** Filling in English description into Mira item from catalog title description English ***")
            else:
              payloadEpisode = f"{payloadEpisode}\r\n        {{\r\n            \"id_synopsis_types\": 22,\r\n            \"synopsis\": \"{miraItemEn}\"}},"
              if outputMethod == "file":
                outFile.write(f"  Using Mira Long Description En: {miraItemEn}\n")
              else:
                print(f"  Using Mira item Long Description En: {miraItemEn}")
            if missingMiraEnShort and itemEnShortDescExists:
            # if missingMiraEnShort and itemEnShortDescExists and (ccItemEnShortDesc <= 110):
            # if itemEnShortDescExists and (ccItemEnShortDesc <= 110):
              updateMiraSynopsisFlag = 1
              payloadEpisode = f"{payloadEpisode}\r\n        {{\r\n            \"id_synopsis_types\": 21,\r\n            \"synopsis\": \"{itemEnShortDesc.replace('"', '\\"')}\"}},"
              if outputMethod == "file":
                outFile.write("*** Filling in English short description into Mira item from catalog item short description English ***\n")
              else:
                print("*** Filling in English short description into Mira item from catalog item short description English ***")
            elif missingMiraEnShort and titleEnShortDescExists:
            # elif missingMiraEnShort and titleEnShortDescExists and (ccTitleEnShortDesc <= 110):
            # elif titleEnShortDescExists and (ccTitleEnShortDesc <= 110):
              updateMiraSynopsisFlag = 1
              payloadEpisode = f"{payloadEpisode}\r\n        {{\r\n            \"id_synopsis_types\": 21,\r\n            \"synopsis\": \"{titleEnShortDesc.replace('"', '\\"')}\"}},"
              if outputMethod == "file":
                outFile.write("*** Filling in English short description into Mira item from catalog title short description English ***\n")
              else:
                print("*** Filling in English short description into Mira item from catalog title short description English ***")
            else:
              payloadEpisode = f"{payloadEpisode}\r\n        {{\r\n            \"id_synopsis_types\": 21,\r\n            \"synopsis\": \"{miraItemEnShort}\"}},"
              if outputMethod == "file":
                outFile.write(f"  Using Mira Short Description En: {miraItemEnShort}\n")
              else:
                print(f"  Using Mira item Short Description En: {miraItemEnShort}")
            if missingMiraEs and itemEsDescExists:
            # if missingMiraEs and itemEsDescExists and (ccItemEsDesc <= 250):
            # if itemEsDescExists and (ccItemEsDesc <= 250):
              updateMiraSynopsisFlag = 1
              payloadEpisode = f"{payloadEpisode}\r\n        {{\r\n            \"id_synopsis_types\": 2,\r\n            \"synopsis\": \"{itemEsDesc.replace('"', '\\"')}\"}},"
              if outputMethod == "file":
                outFile.write("*** Filling in Spanish description into Mira item from catalog item description Spanish ***\n")
              else:
                print("*** Filling in Spanish description into Mira item from catalog item description Spanish ***")
            elif missingMiraEs and titleEsDescExists:
            # elif missingMiraEs and titleEsDescExists and (ccTitleEsDesc <= 250):
            # elif titleEsDescExists and (ccTitleEsDesc <= 250):
              updateMiraSynopsisFlag = 1
              payloadEpisode = f"{payloadEpisode}\r\n        {{\r\n            \"id_synopsis_types\": 2,\r\n            \"synopsis\": \"{titleEsDesc.replace('"', '\\"')}\"}},"
              if outputMethod == "file":
                outFile.write("*** Filling in Spanish description into Mira item from catalog title description Spanish ***\n")
              else:
                print("*** Filling in Spanish description into Mira item from catalog title description Spanish ***")
            else:
              payloadEpisode = f"{payloadEpisode}\r\n        {{\r\n            \"id_synopsis_types\": 2,\r\n            \"synopsis\": \"{miraItemEs}\"}},"
              if outputMethod == "file":
                outFile.write(f"  Using Mira Long Description Es: {miraItemEs}\n")
              else:
                print(f"  Using Mira item Long Description Es: {miraItemEs}")
            if missingMiraEsShort and itemEsShortDescExists:
            # if missingMiraEsShort and itemEsShortDescExists and (ccItemEsShortDesc <= 110):
            # if itemEsShortDescExists and (ccItemEsShortDesc <= 110):
              updateMiraSynopsisFlag = 1
              payloadEpisode = f"{payloadEpisode}\r\n        {{\r\n            \"id_synopsis_types\": 1,\r\n            \"synopsis\": \"{itemEsShortDesc.replace('"', '\\"')}\"}},"
              if outputMethod == "file":
                outFile.write("*** Filling in Spanish short description into Mira item from catalog item short description Spanish ***\n")
              else:
                print("*** Filling in Spanish short description into Mira item from catalog item short description Spanish ***")
            elif missingMiraEsShort and titleEsShortDescExists:
            # elif missingMiraEsShort and titleEsShortDescExists and (ccTitleEsShortDesc <= 110):
            # elif titleEsShortDescExists and (ccTitleEsShortDesc <= 110):
              updateMiraSynopsisFlag = 1
              payloadEpisode = f"{payloadEpisode}\r\n        {{\r\n            \"id_synopsis_types\": 1,\r\n            \"synopsis\": \"{titleEsShortDesc.replace('"', '\\"')}\"}},"
              if outputMethod == "file":
                outFile.write("*** Filling in Spanish short description into Mira item from catalog title short description Spanish ***\n")
              else:
                print("*** Filling in Spanish short description into Mira item from catalog title short description Spanish ***")
            else:
              payloadEpisode = f"{payloadEpisode}\r\n        {{\r\n            \"id_synopsis_types\": 1,\r\n            \"synopsis\": \"{miraItemEsShort}\"}},"
              if outputMethod == "file":
                outFile.write(f"  Using Mira Short Description Es: {miraItemEsShort}\n")
              else:
                print(f"  Using Mira item Short Description Es: {miraItemEsShort}")
            #------------------------------
            # headers = {
            #  'Content-Type': 'application/json; charset=UTF-8',
            # } 
            trimmedPayloadEpisode = payloadEpisode[:-1]
            rawPayloadEpisode = f"{trimmedPayloadEpisode}\r\n    ]\r\n}}"
            # rawJsonPayloadEpisode = json.dumps(rawPayloadEpisode)
            # payloadEpisode = rawPayloadEpisode.encode('utf-8')
            payloadUtf8Stream = io.BytesIO(rawPayloadEpisode.encode('utf-8'))
            if outputMethod == "file":
              outFile.write(f"--- Update Mira? - {updateMiraSynopsisFlag}\n")
              outFile.write(f"--- Payload for item: {rawPayloadEpisode}\n")
            else:
              print(f"--- Update Mira? - {updateMiraSynopsisFlag}")
              print(f"--- Payload for item: {rawPayloadEpisode}")
            if (updateMiraSynopsisFlag == 1) and (printOnly != 1):
              urlMiraEpisodeUpdate = "http://10.1.1.22:83/Service1.svc/title_episodes"
              response = requests.request("PUT", urlMiraEpisodeUpdate, headers=headers, data=payloadUtf8Stream, timeout=(10,120))
              jsonResponse = response.json()
              if jsonResponse == "null":
                updateItemSynopsisResult = "Updated item synopsis information in Mira - result: success"
              else:
                updateItemSynopsisResult = f" Updated item synopsis information in Mira - result: {jsonResponse}"
            #------------------------------
          # DONE Taking care of episodic synopsis
          #------------------------------

          #------------------------------
          # Taking care of movie and title synopsis
          outFile.write("--- Looking at synopsis in title ---\n")
          print("--- Looking at synopsis in title ---")
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
                ccTitleEnDesc = len(titleEnDesc)
                if outputMethod == "file":
                  outFile.write(f"  Catalog title description EN: {titleEnDesc}\n")
                else:
                  print(f"  Catalog title description EN: {titleEnDesc}")
              if titleCodeMetadata[0]['translations']['en']['shortDescription'] != "":
                titleEnShortDescExists = 1
                titleEnShortDesc = titleCodeMetadata[0]['translations']['en']['shortDescription']
                ccTitleEnShortDesc = len(titleEnShortDesc)
                if outputMethod == "file":
                  outFile.write(f"  Catalog short title description EN: {titleEnShortDesc}\n")
                else:
                  print(f"  Catalog short title description EN: {titleEnShortDesc}")
              if titleCodeMetadata[0]['translations']['es']['description'] != "":
                titleEsDescExists = 1
                titleEsDesc = titleCodeMetadata[0]['translations']['es']['description']
                ccTitleEsDesc = len(titleEsDesc)
                if outputMethod == "file":
                  outFile.write(f"  Catalog title description ES: {titleEsDesc}\n")
                else:
                  print(f"  Catalog title description ES: {titleEsDesc}")
              if titleCodeMetadata[0]['translations']['es']['shortDescription'] != "":
                titleEsShortDescExists = 1
                titleEsShortDesc = titleCodeMetadata[0]['translations']['es']['shortDescription']
                ccTitleEsShortDesc = len(titleEsShortDesc)
                if outputMethod == "file":
                  outFile.write(f"  Catalog title short description ES: {titleEsShortDesc}\n")
                else:
                  print(f"  Catalog title short description ES: {titleEsShortDesc}")
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
          updateMiraSynopsisFlag = 0
          missingMiraEn = missingMiraEnShort = missingMiraEs = missingMiraEsShort = 1
          if "id_titles" in responseJson[0]:
            miraId = responseJson[0]['id_titles']
            payloadEpisode = f"{{\r\n    \"id_titles\": {miraId},\r\n    \"title_synopsis\": ["
            # miraTitleId = responseJson[0]['id_titles']
            if "title_synopsis" in responseJson[0]:
              miraEpisodeSynopsis = responseJson[0]['title_synopsis']
              # print(f"Description - {responseJson[0]['description']}")
              if miraEpisodeSynopsis:
                for synopsisType in miraEpisodeSynopsis:
                  if (synopsisType['id_synopsis_types'] == 22) and (synopsisType['synopsis'] != ""):
                    missingMiraEn = 0
                    miraTitleEn = synopsisType['synopsis'].replace('"', r'\"')
                    ccMiraTitleEn = len(miraTitleEn)
                  if (synopsisType['id_synopsis_types'] == 21) and (synopsisType['synopsis'] != ""):
                    missingMiraEnShort = 0
                    miraTitleEnShort = synopsisType['synopsis'].replace('"', r'\"')
                    ccMiraTitleEnShort = len(miraTitleEnShort)
                  if (synopsisType['id_synopsis_types'] == 2) and (synopsisType['synopsis'] != ""):
                    missingMiraEs = 0
                    miraTitleEs = synopsisType['synopsis'].replace('"', r'\"')
                    ccMiraTitleEs = len(miraTitleEs)
                  if (synopsisType['id_synopsis_types'] == 1) and (synopsisType['synopsis'] != ""):
                    missingMiraEsShort = 0
                    miraTitleEsShort = synopsisType['synopsis'].replace('"', r'\"')
                    ccMiraTitleEsShort = len(miraTitleEsShort)
          if missingMiraEn and titleEnDescExists:
          # if missingMiraEn and titleEnDescExists and (ccTitleEnDesc <= 250):
            updateMiraSynopsisFlag = 1
            payloadEpisode = f"{payloadEpisode}\r\n        {{\r\n            \"id_synopsis_types\": 22,\r\n            \"synopsis\": \"{titleEnDesc.replace('"', '\\"')}\"}},"
          else:
            payloadEpisode = f"{payloadEpisode}\r\n        {{\r\n            \"id_synopsis_types\": 22,\r\n            \"synopsis\": \"{miraTitleEn}\"}},"
            if outputMethod == "file":
              outFile.write(f"  Using Mira title description EN: {miraTitleEn}\n")
            else:
              print(f"  Using Mira title description EN: {miraTitleEn}")
          if missingMiraEnShort and titleEnShortDescExists:
          # if missingMiraEnShort and titleEnShortDescExists and (ccTitleEnShortDesc <= 110):
            updateMiraSynopsisFlag = 1
            payloadEpisode = f"{payloadEpisode}\r\n        {{\r\n            \"id_synopsis_types\": 21,\r\n            \"synopsis\": \"{titleEnShortDesc.replace('"', '\\"')}\"}},"
          else:
            payloadEpisode = f"{payloadEpisode}\r\n        {{\r\n            \"id_synopsis_types\": 21,\r\n            \"synopsis\": \"{miraTitleEnShort}\"}},"
            if outputMethod == "file":
              outFile.write(f"  Using Mira title short description EN: {miraTitleEnShort}\n")
            else:
              print(f"  Using Mira title short description EN: {miraTitleEnShort}")
          if missingMiraEs and titleEsDescExists:
          # if missingMiraEs and titleEsDescExists and (ccTitleEsDesc <= 250):
            updateMiraSynopsisFlag = 1
            payloadEpisode = f"{payloadEpisode}\r\n        {{\r\n            \"id_synopsis_types\": 2,\r\n            \"synopsis\": \"{titleEsDesc.replace('"', '\\"')}\"}},"
          else:
            payloadEpisode = f"{payloadEpisode}\r\n        {{\r\n            \"id_synopsis_types\": 2,\r\n            \"synopsis\": \"{miraTitleEs}\"}},"
            if outputMethod == "file":
              outFile.write(f"  Using Mira title description ES: {miraTitleEs}\n")
            else:
              print(f"  Using Mira title description ES: {miraTitleEs}")
          if missingMiraEsShort and titleEsShortDescExists:
          # if missingMiraEsShort and titleEsShortDescExists and (ccTitleEsShortDesc <= 110):
            updateMiraSynopsisFlag = 1
            payloadEpisode = f"{payloadEpisode}\r\n        {{\r\n            \"id_synopsis_types\": 1,\r\n            \"synopsis\": \"{titleEsShortDesc.replace('"', '\\"')}\"}},"
          else:
            payloadEpisode = f"{payloadEpisode}\r\n        {{\r\n            \"id_synopsis_types\": 1,\r\n            \"synopsis\": \"{miraTitleEsShort}\"}},"
            if outputMethod == "file":
              outFile.write(f"  Using Mira title short description ES: {miraTitleEsShort}\n")
            else:
              print(f"  Using Mira title short description ES: {miraTitleEsShort}")
          #------------------------------
          trimmedPayloadEpisode = payloadEpisode[:-1]
          rawPayloadEpisode = f"{trimmedPayloadEpisode}\r\n    ]\r\n}}"
          # rawJsonPayloadEpisode = json.dumps(rawPayloadEpisode)
          # payloadEpisode = rawPayloadEpisode.encode('utf-8')
          payloadUtf8Stream = io.BytesIO(rawPayloadEpisode.encode('utf-8'))
          if outputMethod == "file":
            outFile.write(f"--- Update Mira? - {updateMiraSynopsisFlag}\n")
            outFile.write(f"--- Payload for title: {rawPayloadEpisode}\n")
          else:
            print(f"--- Update Mira? - {updateMiraSynopsisFlag}")
            print(f"--- Payload for title: {rawPayloadEpisode}")
          if (updateMiraSynopsisFlag == 1) and (printOnly != 1):
            urlMiraEpisodeUpdate = "http://10.1.1.22:83/Service1.svc/titles"
            response = requests.request("PUT", urlMiraEpisodeUpdate, headers=headers, data=payloadUtf8Stream, timeout=(10,120))
            jsonResponse = response.json()
            if jsonResponse == "null":
              updateTitleSynopsisResult = "Updated title synopsis information in Mira - result: success"
            else:
              updateTitleSynopsisResult = f" Updated title synopsis information in Mira - result: {jsonResponse}"
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
            outFile.write(f"--- Getting information for {cantemoTitleCode} from Mira ---\n")
            print(f"--- Getting information for {cantemoTitleCode} from Mira ---")
            for crewNumber in range(miraCrewCount):
              outFile.write(f"{miraCrewRole[crewNumber]}: {miraCrewName[crewNumber]} ({miraCrewId[crewNumber]})\n")
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
                      outFile.write("  Already in Catalog Service as an actor for this Mira item\n")
                      print("  Already in Catalog Service as an actor for this Mira item")
                  if miraCrewRole[crewNumber] == "director":
                    if (crewRole['directorRole'] is True) and (crewRole['miraItemId'] == miraId):
                      updateRoleFlag = 0
                      outFile.write("  Already in Catalog Service as a director for this Mira item\n")
                      print("  Already in Catalog Service as a director for this Mira item")
              else:
                updateRoleFlag = 0
              if updateRoleFlag == 1:
                outFile.write("  Creating new role for this crew\n")
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
                outFile.write(f"  Inserted new crew - record ID: {inserted_record.inserted_id}\n")
                print(f"  Inserted new crew - record ID: {inserted_record.inserted_id}")
                outFile.write(f"  Adding new cast member from Mira to reference database: {crew_record}\n")
                print(f"  Adding new cast member from Mira to reference database: {crew_record}")
              #------------------------------
          #------------------------------
          #------------------------------

          if cantemoTitleCode[0] == "M":
            queryTitleCode = {'titleCode': cantemoTitleCode}
            catalogItemMetadata = movieCollection.find_one(queryTitleCode)
            outFile.write(f"--- Getting information for {cantemoTitleCode} from movie collection ---\n")
            print(f"--- Getting information for {cantemoTitleCode} from movie collection ---")
          if cantemoTitleCode[0] == "S":
            queryTitleCode = {'titleCode': fullCantemoTitleCode[:7]}
            catalogItemMetadata = seriesCollection.find_one(queryTitleCode)
            outFile.write(f"--- Getting information for {cantemoTitleCode} from series collection ---\n")
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
                  outFile.write(f"actor: {metadataValue[iCounter]} ({actorUuid[iCounter]})\n")
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
                        outFile.write("  Already exists in MongoDB with actor roles\n")
                        print("  Already exists in MongoDB with actor roles")
                  if updateRoleFlag == 1:
                    outFile.write("  Adding new actor record to MongoDB\n")
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
                    outFile.write(f"  Inserted new crew - record ID: {inserted_record.inserted_id}\n")
                    print(f"  Inserted new crew - record ID: {inserted_record.inserted_id}")
                    outFile.write(f"  Adding new actor from Catalog to reference database: {crew_record}\n")
                    print(f"  Adding new actor from Catalog to reference database: {crew_record}")
                  #------------------------------
                  payload = f"{payload}\r\n        {{\r\n            \"id_positions\": 1,\r\n            \"first_name\": \"{metadataValue[iCounter].strip().replace('"', '\\"')}\",\r\n            \"external_ident\": \"{actorUuid[iCounter]}\"\r\n        }},"
              # Working on directors
              if (metadataItem == "director"):
                directorUuid = list(range(len(metadataValue)))
                for iCounter in range(len(metadataValue)):
                  directorUuid[iCounter] = uuid.uuid4().hex[:16]
                  outFile.write(f"director: {metadataValue[iCounter]} ({directorUuid[iCounter]})\n")
                  print(f"director: {metadataValue[iCounter]} ({directorUuid[iCounter]})")

                  #------------------------------
                  # Check if crews from Catalog Service already exist in the database and update
                  queryCrewName = {'crewName': metadataValue[iCounter]}
                  crewMetadata = list(refCrewCollection.find(queryCrewName))
                  updateRoleFlag = 1
                  if crewMetadata:
                    for crewEntry in crewMetadata:
                      if (crewEntry['directorRole'] is True) and (crewEntry['miraItemId'] == miraId):
                        outFile.write("  Already exists in MongoDB with director roles\n")
                        print("  Already exists in MongoDB with director roles")
                        directorUuid[iCounter] = crewEntry['miraId']
                        updateRoleFlag = 0
                  if updateRoleFlag == 1:
                    outFile.write("  Add new director record to MongoDB\n")
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
                    outFile.write(f"  Inserted new crew - record ID: {inserted_record.inserted_id}\n")
                    print(f"  Inserted new crew - record ID: {inserted_record.inserted_id}")
                    outFile.write(f"  Adding new director from Catalog to reference database: {crew_record}\n")
                    print(f"  Adding new director from Catalog to reference database: {crew_record}")
                  #------------------------------
                  payload = f"{payload}\r\n        {{\r\n            \"id_positions\": 2,\r\n            \"first_name\": \"{metadataValue[iCounter].strip().replace('"', '\\"')}\",\r\n            \"external_ident\": \"{directorUuid[iCounter]}\"\r\n        }},"
            
          trimmedPayload = payload[:-1]
          urlMiraUpdate = "http://10.1.1.22:83/Service1.svc/titles"
          rawPayload = f"{trimmedPayload}\r\n    ]\r\n}}"
          # rawJsonPayload = json.dumps(rawPayload)
          payload = rawPayload.encode('utf-8')
          # payload = json.dumps(rawPayload, ensure_ascii=False).encode('utf-8')
          outFile.write(f"{updateItemSynopsisResult}\n")
          print(updateItemSynopsisResult)
          outFile.write(f"{updateTitleSynopsisResult}\n")
          print(updateTitleSynopsisResult)
          if printOnly != 1:
            response = requests.request("PUT", urlMiraUpdate, headers=headers, data=payload)
            jsonResponse = response.json()
            if jsonResponse == "null":
              outFile.write("Updated crew information in Mira - result: success\n")
              print("Updated crew information in Mira - result: success")
            else:
              outFile.write(f" Updated crew information in Mira - result: {jsonResponse}\n")
              print(f" Updated crew information in Mira - result: {jsonResponse}")
          else:
            outFile.write(f"Cast update: {rawPayload}\n")
            print(f"Cast update: {rawPayload}")
          #------------------------------
          outFile.write("----------------------------------------\n")
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
    print(f"DB read/write Error: {e}")
    # print(traceback.format_exc())
    # clientProd1.close()
    clientOdev.close()
    clientCluster0.close()
except HTTPError as http_err:
  print(f'HTTP error occurred: {http_err}')
except Exception as err:
  print(f'Other error occurred: {err}')