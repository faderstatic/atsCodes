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

def create_xml_payload(data):
    root = ET.Element("data")
    item = ET.SubElement(root, "item")
    item.text = data
    xml_string = ET.tostring(root, encoding='utf-8').decode('utf-8')
    return xml_string

#------------------------------

try:

  cantemoItemId = sys.argv[1]

  #------------------------------
  # Creating Spanish accented characters translation
  accentedCharacters = "áéíóúÁÉÍÓÚñÑ"
  unaccentedCharacters = "aeiouAEIOUnN"
  translationTable = str.maketrans(accentedCharacters, unaccentedCharacters)
  #------------------------------


  cantemoOriginalTitleRaw = readCantemoMetadata(cantemoItemId, 'oly_originalTitle')
  cantemoOriginalTitleWhite = cantemoOriginalTitleRaw.lstrip()
  cantemoOriginalTitleTemp = cantemoOriginalTitleWhite.translate(translationTable)
  cantemoOriginalTitle = cantemoOriginalTitleTemp.replace(' ', '+')

  #------------------------------
  # Update The User
  # print(f"{cantemoOriginalTitle}")
  #------------------------------

  #------------------------------
  urlOmdb = f"http://omdbapi.com/?apikey=79cb45c2&t={cantemoOriginalTitle}&plot=full"
  payload = {}
  headers = {
    'apikey': '79cb45c2'
  }
  httpApiResponse = requests.request("GET", urlOmdb, headers=headers, data=payload)
  responseJson = httpApiResponse.json() if httpApiResponse and httpApiResponse.status_code == 200 else None
  if responseJson and ('Error' not in responseJson):
    omdbReleaseDate = responseJson['Year']
    omdbRated = responseJson['Rated']
    omdbDirector = str(responseJson['Director'])
    omdbWriter = str(responseJson['Writer'])
    omdbActors = str(responseJson['Actors'])
    omdbOverview = str(responseJson['Plot'])
    omdbCombinedResultTemp = f"Release Date: {omdbReleaseDate}\nRated: {omdbRated}\nDirector: {omdbDirector}\nWriter: {omdbWriter}\nActors: {omdbActors}\nOverview: {omdbOverview}"
    omdbCombinedResult = omdbCombinedResultTemp.rstrip()
  else:
    omdbCombinedResult = responseJson['Error']
  print(omdbCombinedResult)
  #------------------------------

  #------------------------------
  tmdbCombinedResultTemp = ""
  urlTmdb = f"https://api.themoviedb.org/3/search/movie?query={cantemoOriginalTitle}&original_language=en-US&page=1"
  payload = {}
  headers = {
    'Authorization': 'Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI0Yjg3M2EyNGM0OTFlYjYyY2ZiY2VmNDEzMWY5OWY4NSIsIm5iZiI6MTczNzU1NDY1OC45MjcsInN1YiI6IjY3OTBmYWUyMmQ2MWMzM2U2M2RmZmQ5MiIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.EDxZTU7a_ntkOVB8QhyC7loglpyw57haw6_4OR1Dr9w'
  }
  httpApiResponse = requests.request("GET", urlTmdb, headers=headers, data=payload)
  responseJson = httpApiResponse.json() if httpApiResponse and httpApiResponse.status_code == 200 else None
  if (responseJson) and ('results' in responseJson):
    itemCounter = 1
    for itemResults in responseJson['results']:
      if itemResults:
        tmdbOriginalTitle = str(itemResults['original_title'])
        if cantemoOriginalTitleTemp.lower() == tmdbOriginalTitle.lower():
          tmdbTitleEn = str(itemResults['title'])
          tmdbOverview = str(itemResults['overview'])
          tmdbPosterTMP = str(itemResults['poster_path'])
          tmdbReleaseDate = str(itemResults['release_date'])
          # tmdbPoster = tmdbPosterTMP.replace('/', '')
          tmdbPoster = f"https://image.tmdb.org/t/p/w300_and_h450_bestv2{itemResults['poster_path']}"
          encodedTmdbPoster = quote_plus(tmdbPoster)
          # tmdbCombinedResult = f"English Title: {tmdbTitleEn}\nOverview: {tmdbOverview}\nPoster File: {encodedTmdbPoster}"
          tmdbCombinedResultTemp = f"{tmdbCombinedResultTemp}[{itemCounter}] English Title: {tmdbTitleEn}\n[{itemCounter}] Release Date: {tmdbReleaseDate}\n[{itemCounter}] Overview: {tmdbOverview}\n"
          itemCounter += 1
    tmdbCombinedResult = tmdbCombinedResultTemp.rstrip()
  if tmdbCombinedResultTemp == "":
    tmdbCombinedResult = "No Result Found!"
  # print(f"TMDB = {tmdbCombinedResult}")
  #------------------------------

  #------------------------------
  # Update Cantemo metadata
  headers = {
  'Authorization': 'Basic YWRtaW46MTBsbXBAc0B0',
  'Cookie': 'csrftoken=HFOqrbk9cGt3qnc6WBIxWPjvCFX0udBdbJnzCv9jECumOjfyG7SS2lgVbFcaHBCc',
  'Content-Type': 'application/xml; charset=utf-8'
  }
  urlPutAnalysisInfo = f"http://10.1.1.34:8080/API/item/{cantemoItemId}/metadata/"
  itemIdRawPayload = f"<MetadataDocument xmlns=\"http://xml.vidispine.com/schema/vidispine\"><timespan start=\"-INF\" end=\"+INF\"><field><name>oly_omdbCombinedResult</name><value>{omdbCombinedResult}</value></field><field><name>oly_tmdbCombinedResult</name><value>{tmdbCombinedResult}</value></field></timespan></MetadataDocument>"
  # parsedItemIdPayload = xml.dom.minidom.parseString(itemIdRawPayload)
  # itemIdPayload = parsedItemIdPayload.toprettyxml()
  itemIdPayload = create_xml_payload(itemIdRawPayload)
  # print(itemIdPayload)
  httpApiResponse = requests.request("PUT", urlPutAnalysisInfo, headers=headers, data=itemIdPayload.encode('utf-8'))  
  #------------------------------
  
#------------------------------

except HTTPError as http_err:
  print(f'HTTP error occurred: {http_err}')
except Exception as err:
  print(f'Other error occurred: {err}')