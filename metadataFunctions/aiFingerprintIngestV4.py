# /opt/cantemo/python/bin/python
# /usr/local/bin/python3
#!/usr/bin/python3

# This application ingests metadata from an XML API response into Cantemo
# PREREQUISITE: -none-
# 	Usage: aiFingerprintIngestV1.py [Cantemo ItemID]

#------------------------------
# Libraries
import os
import os.path
import glob
import sys
import datetime
import time
import subprocess
import xml.dom.minidom
import xml.etree.ElementTree as ET
import requests
import json
from requests.exceptions import HTTPError
#------------------------------

#------------------------------
# Internal Functions

def readCantimoLookup(rclFieldName):
  #------------------------------
  # Making API to Cantemo to get lookup values
  headers = {
    'Authorization': 'Basic YWRtaW46MTBsbXBAc0B0',
    'Cookie': 'csrftoken=OtjDQ4lhFt2wJjGaJhq3xi05z3uA6D8F7wCWNVXxMuJ8A9jw7Ri7ReqSNGLS2VRR',
    'Accept': 'application/json'
  }
  urlGetLookup = f"http://10.1.1.34:8080/API/metadata-field/{rclFieldName}/metadata"
  payload = {}
  httpApiResponse = requests.request("GET", urlGetLookup, headers=headers, data=payload)
  httpApiResponse.raise_for_status()
  #------------------------------

  #------------------------------
  # Parsing JSON data for lookup values
  responseJson = httpApiResponse.json() if httpApiResponse and httpApiResponse.status_code == 200 else None
  if responseJson and 'field' in responseJson:
    for fieldInformation in responseJson['field']:
      if fieldInformation['key'] == "__values":
        lookupValueXml = fieldInformation['value']
        # print(lookupValueXml)
  #------------------------------

  #------------------------------
  # Parsing XML data
  ET.register_namespace('ns', 'http://xml.vidispine.com/schema/vidispine')
  lookupXmlRoot = ET.fromstring(lookupValueXml)
  lookupList = []
  # print(lookupXmlRoot.find('{http://xml.vidispine.com/schema/vidispine}field'))
  for fieldValue in lookupXmlRoot:
    lookupValue = fieldValue.find('{http://xml.vidispine.com/schema/vidispine}key')
    # lookupList += lookupValue.text.lower()+','
    lookupList.append(lookupValue.text.lower())
  # print(lookupList)
  #------------------------------
  return lookupList

def createCantimoLookup(cckFieldName, cckLookupXMLPayload):
  headers = {
  'Authorization': 'Basic YWRtaW46MTBsbXBAc0B0',
  'Cookie': 'csrftoken=HFOqrbk9cGt3qnc6WBIxWPjvCFX0udBdbJnzCv9jECumOjfyG7SS2lgVbFcaHBCc',
  'Content-Type': 'application/xml'
  }
  urlPutLookupValues = f"http://10.1.1.34:8080/API/metadata-field/{cckFieldName}/values"
  httpApiResponse = requests.request("PUT", urlPutLookupValues, headers=headers, data=cckLookupXMLPayload)
  pass

#------------------------------

#------------------------------

try:
  olderFileDayLimit = 14

  cantemoItemId = sys.argv[1]
  # cantemoItemId = os.environ.get("portal_itemId")
  errorReport = ''
  outputFPFile = f"/opt/olympusat/resources/vionlabsReports/{cantemoItemId}_FP.json"
  
  if not os.path.isfile(outputFPFile):
    #------------------------------
    # Making API call to Vionlabs to get fingerprints
    headers = {
      'Accept': 'application/json'
    }
    payload = {}
    urlGetFingerprintPlus = f"https://apis.prod.vionlabs.com/results/fingerprintplus/v1/{cantemoItemId}?&key=kt8cyimHXxUzFNGyhd7c7g"
    # urlGetProfanitySegments = f"https://apis.prod.vionlabs.com/results/fingerprintplus/v1/OLT-003?&key=kt8cyimHXxUzFNGyhd7c7g"
    httpApiResponse = requests.request("GET", urlGetFingerprintPlus, headers=headers, data=payload)
    httpApiResponse.raise_for_status()
    responseJson = httpApiResponse.json()
    #------------------------------
    # Writing response data to a file
    apiResponseJson = json.loads(httpApiResponse.text)
    apiResponseJsonFormat = json.dumps(apiResponseJson, indent=2)
    responseWriting = open(outputFPFile, "w")
    responseWriting.write(apiResponseJsonFormat)
    responseWriting.close()
    #------------------------------
  else:
    outputFPFileCreation = os.path.getctime(outputFPFile)
    timeNow = time.time()
    fileCreationLimitOffset = timeNow - (60 * 60 * 24 * olderFileDayLimit)
    if outputFPFileCreation > fileCreationLimitOffset:
      existingAnalysisRead = open(outputFPFile, "r")
      responseJson = json.loads(existingAnalysisRead.read())
      existingAnalysisRead.close()
    else:
      #------------------------------
      # Making API call to Vionlabs to get fingerprints
      headers = {
        'Accept': 'application/json'
      }
      payload = {}
      urlGetFingerprintPlus = f"https://apis.prod.vionlabs.com/results/fingerprintplus/v1/{cantemoItemId}?&key=kt8cyimHXxUzFNGyhd7c7g"
      # urlGetProfanitySegments = f"https://apis.prod.vionlabs.com/results/fingerprintplus/v1/OLT-003?&key=kt8cyimHXxUzFNGyhd7c7g"
      httpApiResponse = requests.request("GET", urlGetFingerprintPlus, headers=headers, data=payload)
      httpApiResponse.raise_for_status()
      responseJson = httpApiResponse.json()
      #------------------------------
      # Writing response data to a file
      apiResponseJson = json.loads(httpApiResponse.text)
      apiResponseJsonFormat = json.dumps(apiResponseJson, indent=2)
      responseWriting = open(outputFPFile, "w")
      responseWriting.write(apiResponseJsonFormat)
      responseWriting.close()
      #------------------------------

  addingGenreLookup = "false"
  genreLookupXML = f"<SimpleMetadataDocument xmlns=\"http://xml.vidispine.com/schema/vidispine\">"
  genreXML = f"<MetadataDocument xmlns=\"http://xml.vidispine.com/schema/vidispine\"><group>Olympusat</group><timespan start=\"-INF\" end=\"+INF\"><field><name>oly_genreAnalysis</name>"
  moodXML = f"<MetadataDocument xmlns=\"http://xml.vidispine.com/schema/vidispine\"><group>Olympusat</group><timespan start=\"-INF\" end=\"+INF\"><field><name>oly_moodAnalysis</name>"
  keywordXML = f"<MetadataDocument xmlns=\"http://xml.vidispine.com/schema/vidispine\"><group>Olympusat</group><timespan start=\"-INF\" end=\"+INF\"><field><name>oly_keywordAnalysis</name>"
  #------------------------------
  # Parsing JSON and POST XML data

  genreList = readCantimoLookup("oly_genreAnalysis")
  for individualGenre in genreList:
    genreLookupXML += f"<field><key>{individualGenre}</key><value>{individualGenre}</value></field>"
  for individualGenre in responseJson["genre"]:
    genreXML += f"<value>{individualGenre}</value>"
    if individualGenre.lower() not in genreList:
      addingGenreLookup = "true"
      genreLookupXML += f"<field><key>{individualGenre}</key><value>{individualGenre}</value></field>"
  genreLookupXML += "</SimpleMetadataDocument>"
  if addingGenreLookup == 'true':
    parsedGenreLookupXML = xml.dom.minidom.parseString(genreLookupXML)
    genreLookupPayload = parsedGenreLookupXML.toprettyxml()
    createCantimoLookup("oly_genreAnalysis", genreLookupPayload)
  genreXML += "</field></timespan></MetadataDocument>"
  parsedGenreXML = xml.dom.minidom.parseString(genreXML)
  genrePayload = parsedGenreXML.toprettyxml()

  for individualMood in responseJson["mood_tag"]:
    itemValue = responseJson["mood_tag"][individualMood]
    itemValue *= 100
    itemValue = round(itemValue, 2)
    moodTag = str(itemValue) + f": {individualMood}"
    moodXML += f"<value>{moodTag}</value>"
  moodXML += "</field></timespan></MetadataDocument>"
  parsedMoodXML = xml.dom.minidom.parseString(moodXML)
  moodPayload = parsedMoodXML.toprettyxml()

  for individualKeyword in responseJson["keyword"]:
    itemValue = responseJson["keyword"][individualKeyword]
    itemValue *= 100
    itemValue = round(itemValue, 2)
    keywordTag = str(itemValue) + f": {individualKeyword}"
    keywordXML += f"<value>{keywordTag}</value>"
  keywordXML += "</field></timespan></MetadataDocument>"
  parsedKeywordXML = xml.dom.minidom.parseString(keywordXML)
  keywordPayload = parsedKeywordXML.toprettyxml()

  statusRawPayload = f"<MetadataDocument xmlns=\"http://xml.vidispine.com/schema/vidispine\"><timespan start=\"-INF\" end=\"+INF\"><field><name>oly_analysisStatus</name><value>completed - last request - fingerprint</value></field></timespan></MetadataDocument>"
  parsedStatusPayload = xml.dom.minidom.parseString(statusRawPayload)
  statusPayload = parsedStatusPayload.toprettyxml()

  #------------------------------
  # Update Cantemo metadata
  headers = {
  'Authorization': 'Basic YWRtaW46MTBsbXBAc0B0',
  'Cookie': 'csrftoken=HFOqrbk9cGt3qnc6WBIxWPjvCFX0udBdbJnzCv9jECumOjfyG7SS2lgVbFcaHBCc',
  'Content-Type': 'application/xml'
  }
  urlPutAnalysisInfo = f"http://10.1.1.34:8080/API/item/{cantemoItemId}/metadata/"
  # genrePayload = f"<MetadataDocument xmlns=\"http://xml.vidispine.com/schema/vidispine\"><timespan start=\"-INF\" end=\"+INF\"><field><name>oly_analysisReport</name><value>{errorReport}</value></field></timespan></MetadataDocument>"
  httpApiResponse = requests.request("PUT", urlPutAnalysisInfo, headers=headers, data=genrePayload)
  time.sleep(5)
  httpApiResponse = requests.request("PUT", urlPutAnalysisInfo, headers=headers, data=moodPayload)
  time.sleep(5)
  httpApiResponse = requests.request("PUT", urlPutAnalysisInfo, headers=headers, data=keywordPayload)
  time.sleep(5)
  httpApiResponse = requests.request("PUT", urlPutAnalysisInfo, headers=headers, data=statusPayload)
  #------------------------------
  #------------------------------

except HTTPError as http_err:
    print(f'HTTP error occurred: {http_err}')
except Exception as err:
    print(f'Other error occurred: {err}')