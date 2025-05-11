# /opt/cantemo/python/bin/python
# /usr/local/bin/python3
#!/usr/bin/python3

#------------------------------
# Libraries
import os
import sys
import time
import xml.etree.ElementTree as ET
import requests
import uuid
import json
import csv
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
  outputFile = sys.argv[2]
  languageExport = sys.argv[3]
  descriptionType = sys.argv[4]
  getSeriesInfo = sys.argv[5]

  #******************************
  # Control language and description type output
  # languageExport = "en"
  # languageExport = "es"
  # descriptionType = "short"
  # descriptionType = "long"
  # getSeriesInfo = "no"
  # getSeriesInfo = "yes"
  #******************************

  if getSeriesInfo == "yes":
    csvHeader = ['Title Code', 'Synopsis', 'Series Synopsis', 'Casts', 'Producers', 'Directors']
  else:
    csvHeader = ['Title Code', 'Synopsis', 'Casts', 'Producers', 'Directors']
  titleFileExists = os.path.exists(titleFile)
  outputFileExists = os.path.exists(outputFile)
    
  # clientProd1.admin.command('ping')
  # print(f"Pinged your deployment. You successfully connected to Prod-1")
  # clientOdev.admin.command('ping')
  # print(f"Pinged your deployment. You successfully connected to OlympusatDev")

  olyplatCatalog = clientOdev["olyplat_catalog"]
  catalogCollection = olyplatCatalog["catalog"]
  movieCollection = olyplatCatalog["movie"]
  episodeCollection = olyplatCatalog["episode"]
  seasonCollection = olyplatCatalog["season"]
  seriesCollection = olyplatCatalog["series"]
  genreCollection = olyplatCatalog["genre_type"]

  #------------------------------
  # Creating Spanish accented characters translation
  accentedCharacters = "áéíóúÁÉÍÓÚñÑ"
  unaccentedCharacters = "aeiouAEIOUnN"
  translationTable = str.maketrans(accentedCharacters, unaccentedCharacters)
  #------------------------------

  if titleFileExists:
    with open(titleFile, "r") as file:
      lines = file.readlines()
      #------------------------------
      # Control whether to update Mira
      printOnly = 0
      #------------------------------
      with open(outputFile, 'w', newline='') as outFile:
        lineWriter = csv.writer(outFile)
        lineWriter.writerow(csvHeader)
        for cantemoTitleCodeLine in lines:
          if (cantemoTitleCodeLine[0] == "S") or (cantemoTitleCodeLine[0] == "M"):
            cantemoTitleCode = cantemoTitleCodeLine.strip().split("_")[0]
          else:
            cantemoTitleCode = cantemoTitleCodeLine.strip()
          print(f"Processing: {cantemoTitleCode}")
          itemInfo = []
          itemInfo.append(cantemoTitleCode)

          #------------------------------
          # Getting synopsis
          catalogEnDesc = catalogEnShortDesc = catalogEsDesc = catalogEsShortDesc = ""
          catalogSeriesEnDesc = catalogSeriesEnShortDesc = catalogSeriesEsDesc = catalogSeriesEsShortDesc = ""
          catalogActor = catalogProducer = ""
          queryTitleCode = {'titleCode': cantemoTitleCode}
          if (cantemoTitleCode[0] == "S") and (len(cantemoTitleCode) > 10):
            catalogItemMetadata = list(episodeCollection.find(queryTitleCode))
            print(f"--- Getting information for {cantemoTitleCode} from episode collection ---")
          elif (cantemoTitleCode[0] == "S") and ((len(cantemoTitleCode) >= 9) and (len(cantemoTitleCode) <= 10)):
            catalogItemMetadata = list(seasonCollection.find(queryTitleCode))
            print(f"--- Getting information for {cantemoTitleCode} from season collection ---")
          elif (cantemoTitleCode[0] == "S") and (len(cantemoTitleCode) == 7):
            catalogItemMetadata = list(seriesCollection.find(queryTitleCode))
            print(f"--- Getting information for {cantemoTitleCode} from series collection ---")
          else:
            catalogItemMetadata = list(movieCollection.find(queryTitleCode))
            print(f"--- Getting information for {cantemoTitleCode} from movie collection ---")
          #------------------------------
          # Get existing synopsis information from catalog
          blankInfo = 1
          if catalogItemMetadata:
            if (catalogItemMetadata[0]['translations']['en']['description'] != "") and (descriptionType == "long") and (languageExport == "en"):
              catalogEnDesc = catalogItemMetadata[0]['translations']['en']['description']
              itemInfo.append(catalogEnDesc)
              blankInfo = 0
            if (catalogItemMetadata[0]['translations']['en']['shortDescription'] != "") and (descriptionType == "short") and (languageExport == "en"):
              catalogEnShortDesc = catalogItemMetadata[0]['translations']['en']['shortDescription']
              itemInfo.append(catalogEnShortDesc)
              blankInfo = 0
            if (catalogItemMetadata[0]['translations']['es']['description'] != "") and (descriptionType == "long") and (languageExport == "es"):
              catalogEsDesc = catalogItemMetadata[0]['translations']['es']['description']
              itemInfo.append(catalogEsDesc)
              blankInfo = 0
            if (catalogItemMetadata[0]['translations']['es']['shortDescription'] != "") and (descriptionType == "short") and (languageExport == "es"):
              catalogEsShortDesc = catalogItemMetadata[0]['translations']['es']['shortDescription']
              itemInfo.append(catalogEsShortDesc)
              blankInfo = 0
            if blankInfo == 1:
              itemInfo.append("")
          else:
            itemInfo.append("")
            print(f"--- Information does not exist in Catalog service for the title code [{cantemoTitleCode}] ---")
          if (getSeriesInfo == "yes") and (cantemoTitleCode[0] == "S"):
            cantemoSeriesCode = cantemoTitleCode[:7]
            queryTitleCode = {'titleCode': cantemoSeriesCode}
            catalogSeriesMetadata = list(seriesCollection.find(queryTitleCode))
            print(f"--- Getting information for {cantemoSeriesCode} from series collection ---")
            blankInfo = 1
            if catalogSeriesMetadata:
              if (catalogSeriesMetadata[0]['translations']['en']['description'] != "") and (descriptionType == "long") and (languageExport == "en"):
                catalogEnDesc = catalogSeriesMetadata[0]['translations']['en']['description']
                itemInfo.append(catalogEnDesc)
                blankInfo = 0
              if (catalogSeriesMetadata[0]['translations']['en']['shortDescription'] != "") and (descriptionType == "short") and (languageExport == "en"):
                catalogEnShortDesc = catalogSeriesMetadata[0]['translations']['en']['shortDescription']
                itemInfo.append(catalogEnShortDesc)
                blankInfo = 0
              if (catalogSeriesMetadata[0]['translations']['es']['description'] != "") and (descriptionType == "long") and (languageExport == "es"):
                catalogEsDesc = catalogSeriesMetadata[0]['translations']['es']['description']
                itemInfo.append(catalogEsDesc)
                blankInfo = 0
              if (catalogSeriesMetadata[0]['translations']['es']['shortDescription'] != "") and (descriptionType == "short") and (languageExport == "es"):
                catalogEsShortDesc = catalogSeriesMetadata[0]['translations']['es']['shortDescription']
                itemInfo.append(catalogEsShortDesc)
                blankInfo = 0
              if blankInfo == 1:
                itemInfo.append("")
            else:
              itemInfo.append("")
              print(f"--- Information does not exist in Catalog service in SERIES LEVEL for the title code [{cantemoTitleCode}] ---")
          #------------------------------
          emptyCollectionQuery = 0
          if (cantemoTitleCode[0] == "S"):
            cantemoCrewCode = cantemoTitleCode[:7]
            queryTitleCode = {'titleCode': cantemoCrewCode}
            if seriesCollection.count_documents(queryTitleCode) != 0:
              catalogCrewMetadata = seriesCollection.find(queryTitleCode)
            else:
              emptyCollectionQuery = 1
          else:
            cantemoCrewCode = cantemoTitleCode
            queryTitleCode = {'titleCode': cantemoCrewCode}
            if seriesCollection.count_documents(queryTitleCode) != 0:
              catalogCrewMetadata = movieCollection.find(queryTitleCode)
            else:
              emptyCollectionQuery = 1
          castInformation = producerInformation = directorInformation = ""
          if not emptyCollectionQuery:
            if catalogCrewMetadata[0]['cast']:
              for cast in catalogCrewMetadata[0]['cast']:
                if castInformation == "":
                  castInformation = cast
                else:
                  castInformation = f"{castInformation}, {cast}"
              # castInformation = f"{castInformation}"
              # print(f"--- CAST: {castInformation}")
              itemInfo.append(castInformation)
            else:
              itemInfo.append("")
            if catalogCrewMetadata[0]['producer']:
              for producer in catalogCrewMetadata[0]['producer']:
                if producerInformation == "":
                  producerInformation = f"{producer}"
                else:
                  producerInformation = f"{producerInformation}, {producer}"
              # producerInformation = f"{producerInformation}"
              # print(f"--- PRODUCER: {producerInformation}")
              itemInfo.append(producerInformation)
            else:
              itemInfo.append("")
            if catalogCrewMetadata[0]['director']:
              for director in catalogCrewMetadata[0]['director']:
                if directorInformation == "":
                  directorInformation = f"{director}"
                else:
                  directorInformation = f"{directorInformation}, {director}"
              # directorInformation = f"{directorInformation}"
              # print(f"--- DIRECTOR: {directorInformation}")
              itemInfo.append(directorInformation)
            else:
              itemInfo.append("")
          else:
            itemInfo.extend(["","",""])

          lineWriter.writerow(itemInfo)

      #------------------------------
  else:
    print(f"File [{titleFile}] does not exists!")
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