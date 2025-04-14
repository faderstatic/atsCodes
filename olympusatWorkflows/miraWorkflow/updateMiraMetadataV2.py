# /opt/cantemo/python/bin/python
# /usr/local/bin/python3
#!/usr/bin/python3

# This application ingests metadata from an XML API response into Cantemo
# PREREQUISITE: -none-
# 	Usage: aiEmailResult.py [Cantemo ItemID] [Cantemo Username] [analysis type]

#------------------------------
# Libraries
import sys
import time
import xml.etree.ElementTree as ET
import requests
import uuid
from email.message import EmailMessage
from requests.exceptions import HTTPError
from urllib.parse import quote_plus
from pymongo import MongoClient
# import traceback
#------------------------------

#------------------------------
# Set up Catalog Service MongoDB variables
# uriProd1 = "mongodb+srv://mamadmin:YOzHzj5EAhAJ4u7T@prod-1.4g3ic.mongodb.net/?retryWrites=true&w=majority&appName=Prod-1&tls=true"
uriOdev = "mongodb+srv://mamadmin:YOzHzj5EAhAJ4u7T@olympusatdev.4g3ic.mongodb.net/?retryWrites=true&w=majority&appName=OlympusatDev&tls=true"
uriCluster0 = "mongodb+srv://mamadmin:YOzHzj5EAhAJ4u7T@cluster0.ld2wjpj.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0&tls=true"
# uri = "mongodb+srv://mamadmin:YOzHzj5EAhAJ4u7T@prod-1.4g3ic.mongodb.net/admin"
# Create a new client and connect to the server
# clientProd1 = MongoClient(uriProd1)
clientOdev = MongoClient(uriOdev)
clientCluster0 = MongoClient(uriCluster0)
#------------------------------

olyplatCatalog = clientOdev["olyplat_catalog"]
cantemoDb = clientCluster0["cantemo"]
refCrewCollection = cantemoDb["refCrew"]
catalogCollection = olyplatCatalog["catalog"]
movieCollection = olyplatCatalog["movie"]
seriesCollection = olyplatCatalog["series"]
genreCollection = olyplatCatalog["genre_type"]

try:

  cantemoItemId = sys.argv[1]
  ns = {'vidispine': 'http://xml.vidispine.com/schema/vidispine'}

  #------------------------------
  # Making API call to Cantemo to get content flag
  headersCantemo = {
    'Authorization': 'Basic YWRtaW46MTBsbXBAc0B0',
    'Cookie': 'csrftoken=HFOqrbk9cGt3qnc6WBIxWPjvCFX0udBdbJnzCv9jECumOjfyG7SS2lgVbFcaHBCc',
    'Accept': 'application/json'
  }
  payloadCantemo = {}
  urlGetContentFlags = f"http://10.1.1.34:8080/API/item/{cantemoItemId}/metadata?field=oly_titleCode,oly_contentFlags&includeConstraintValue=all&terse=yes&interval=generic"
  httpApiResponse = requests.request("GET", urlGetContentFlags, headers=headersCantemo, data=payloadCantemo)
  httpApiResponse.raise_for_status()
  #------------------------------

  #------------------------------
  # Creating Spanish accented characters translation
  accentedCharacters = "áéíóúÁÉÍÓÚñÑ"
  unaccentedCharacters = "aeiouAEIOUnN"
  translationTable = str.maketrans(accentedCharacters, unaccentedCharacters)
  #------------------------------

  #------------------------------
  # Parsing XML data to get content Flags (cantemoContentFlag)
  responseXml = httpApiResponse.text
  responseRoot = ET.XML(responseXml)
  legacyContentFlag = 'false'
  contentEmptyFlag = 'false'

  for child in responseRoot.findall('vidispine:item', ns):
      for titleCodeItem in child.findall('oly_titleCode'):
        cantemoTitleCode = titleCodeItem.text

  for child in responseRoot.findall('vidispine:item', ns):
    for cantemoContentFlags in child.findall('oly_contentFlags'):
      if not cantemoContentFlags.text:
        contentEmptyFlag = 'true'
      elif cantemoContentFlags.text == 'legacycontent':
        legacyContentFlag = 'true'

  if legacyContentFlag == 'true':
    #------------------------------
    # Making API call to Cantemo to get contract code
    payloadCantemo = {}
    urlGetContractCode = f"http://10.1.1.34:8080/API/item/{cantemoItemId}/metadata?field=oly_titleCode,oly_contractCode&terse=yes&interval=generic"
    httpApiResponse = requests.request("GET", urlGetContractCode, headers=headersCantemo, data=payloadCantemo)
    httpApiResponse.raise_for_status()
    #------------------------------

    #------------------------------
    # Parsing XML data to get Rightsline contract Code (contractCode))
    responseXml = httpApiResponse.text
    root = ET.XML(responseXml)
    for child in root.findall('vidispine:item', ns):
      for cantemoContractCode in child.findall('oly_contractCode'):
        rightslineContractId = cantemoContractCode.text

    #------------------------------
    # Making API call to Cantemo to get Rightsline title code
    urlGetTitleCode = f"http://10.1.1.34:8080/API/item/{cantemoItemId}/metadata?field=oly_titleCode&terse=yes"
    httpApiResponse = requests.request("GET", urlGetTitleCode, headers=headersCantemo, data=payloadCantemo)
    httpApiResponse.raise_for_status()
    #------------------------------

    #------------------------------
    # Parsing XML data to get Rightsline title code (titleCode)
    responseXml = httpApiResponse.text
    root = ET.XML(responseXml)
    for child in root.findall('vidispine:item', ns):
      for cantemoTitleCode in child.findall('oly_titleCode'):
        rightslineItemId = cantemoTitleCode.text
    #------------------------------
  else:
    #------------------------------
    # Making API call to Cantemo to get contract ID
    payloadCantemo = {}
    urlGetContractId = f"http://10.1.1.34:8080/API/item/{cantemoItemId}/metadata?field=oly_rightslineContractId&terse=yes"
    httpApiResponse = requests.request("GET", urlGetContractId, headers=headersCantemo, data=payloadCantemo)
    httpApiResponse.raise_for_status()
    #------------------------------

    #------------------------------
    # Parsing XML data to get Rightsline contract ID (rightslineContractId)
    responseXml = httpApiResponse.text
    root = ET.XML(responseXml)
    # print(root.tag, root.attrib, root.text)
    for child in root.findall('vidispine:item', ns):
      for cantemoContractId in child.findall('oly_rightslineContractId'):
        rightslineContractId = cantemoContractId.text

    #------------------------------
    # Making API call to Cantemo to get Rightsline Item ID
    urlGetRightslineItemId = f"http://10.1.1.34:8080/API/item/{cantemoItemId}/metadata?field=oly_rightslineItemId&terse=yes"
    httpApiResponse = requests.request("GET", urlGetRightslineItemId, headers=headersCantemo, data=payloadCantemo)
    httpApiResponse.raise_for_status()
    #------------------------------

    #------------------------------
    # Parsing XML data to get Rightsline item ID (rightslineItemId)
    # ET.register_namespace('ns', 'http://xml.vidispine.com/schema/vidispine')
    responseXml = httpApiResponse.text
    root = ET.XML(responseXml)
    # print(root.tag, root.attrib, root.text)
    for child in root.findall('vidispine:item', ns):
      for cantemoRightslineId in child.findall('oly_rightslineItemId'):
        rightslineItemId = cantemoRightslineId.text
    #------------------------------

    #------------------------------
    # Get existing information from Mira
    urlMira = f"http://10.1.1.22:83/Service1.svc/titles/{cantemoTitleCode}"
    payload = ""
    headers = {
      'Content-Type': 'text/plain; charset=UTF-8',
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
              #------------------------------
              payload = f"{payload}\r\n        {{\r\n            \"id_positions\": 1,\r\n            \"first_name\": \"{metadataValue[iCounter].replace('"', '\\"')}\",\r\n            \"external_ident\": \"{actorUuid[iCounter]}\"\r\n        }},"
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
              #------------------------------
              payload = f"{payload}\r\n        {{\r\n            \"id_positions\": 2,\r\n            \"first_name\": \"{metadataValue[iCounter].replace('"', '\\"')}\",\r\n            \"external_ident\": \"{directorUuid[iCounter]}\"\r\n        }},"
        
      trimmedPayload = payload[:-1]
      urlMiraUpdate = "http://10.1.1.22:83/Service1.svc/titles"
      rawPayload = f"{trimmedPayload}\r\n    ]\r\n}}"
      # print(rawPayload)
      payload = rawPayload.encode('utf-8')
      # payload = json.dumps(rawPayload, ensure_ascii=False).encode('utf-8')
      # print(payload)
      response = requests.request("PUT", urlMiraUpdate, headers=headers, data=payload)
      jsonResponse = response.json()
      if jsonResponse == "null":
        print("Updated crew information in Mira - result: success")
      else:
        print(f" Updated crew information in Mira - result: {jsonResponse}")
      #------------------------------

      del actorUuid
      del directorUuid
      time.sleep(2)
      #------------------------------
      # Update The User
      # print(f"{cantemoOriginalTitleWhite} (without accents: {cantemoOriginalTitle}) - {cantemoTitleCode}")
      #------------------------------
    #------------------------------
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