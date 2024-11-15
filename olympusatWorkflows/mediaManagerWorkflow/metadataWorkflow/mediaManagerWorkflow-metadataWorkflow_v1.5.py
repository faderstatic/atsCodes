# /opt/cantemo/python/bin/python
# /usr/local/bin/python3
#!/usr/bin/python3

# This application ingests metadata from an XML API response into Cantemo
# PREREQUISITE: -none-
# 	Usage: mediaManagerWorkflow-metadataWorkflow_v1.0.py [Cantemo ItemID]

#------------------------------
# Libraries
import os
import os.path
import glob
import sys
from datetime import datetime
import time
import subprocess
import xml.dom.minidom
import xml.etree.ElementTree as ET
import requests
import json
from requests.exceptions import HTTPError
from array import *
#------------------------------

#------------------------------
# Internal Functions

#------------------------------

#------------------------------

try:
  cantemoItemId = sys.argv[1]
  userName = sys.argv[2]
  metadataAction = sys.argv[3]
  assignedTo = sys.argv[4]
  maximumArraySize = 50
  assignmentName = []
  assignmentName = [ 0 for i in range(maximumArraySize)]
  assignmentNameStatus = []
  assignmentNameStatus = [ 0 for i in range(maximumArraySize)]
  assignmentNameUuid = []
  assignmentNameUuid = [ 0 for i in range(maximumArraySize)]
  metadataFields = 'oly_metadataAssignedTo,oly_metadataStatus,oly_metadataBy,oly_metadataDate'
  metadataGroupName = 'Ingest'

  headers = {
    'Authorization': 'Basic YWRtaW46MTBsbXBAc0B0',
    'Cookie': 'csrftoken=OtjDQ4lhFt2wJjGaJhq3xi05z3uA6D8F7wCWNVXxMuJ8A9jw7Ri7ReqSNGLS2VRR',
    'Accept': 'application/json'
  }
  urlGetSubgroupInfo = f"http://10.1.1.34:8080/API/item/{cantemoItemId}/metadata?field={metadataFields}&group={metadataGroupName}"
  payload = {}
  httpApiResponse = requests.request("GET", urlGetSubgroupInfo, headers=headers, data=payload)
  httpApiResponse.raise_for_status()
  #------------------------------
  headers = {
    'Authorization': 'Basic YWRtaW46MTBsbXBAc0B0',
    'Cookie': 'csrftoken=HFOqrbk9cGt3qnc6WBIxWPjvCFX0udBdbJnzCv9jECumOjfyG7SS2lgVbFcaHBCc',
    'Content-Type': 'application/xml'
  }
  urlPutMetadataInfo = f"http://10.1.1.34:8080/API/item/{cantemoItemId}/metadata/"
  #------------------------------
  # Parsing JSON data for subgroup metadata values
  responseJson = httpApiResponse.json() if httpApiResponse and httpApiResponse.status_code == 200 else None
  if responseJson and 'item' in responseJson:
    for itemInformation in responseJson['item']:
      metadataInformation = itemInformation['metadata']
      #print(f"Entered metadataInformation - {metadataInformation}")
      if metadataInformation['timespan']:
        for timespanInformation in metadataInformation['timespan']:
          #print(f"Entered timespanInformation - {timespanInformation}")
          if not timespanInformation['group']:
            print("NO Subgroup Metadata Found")
            createNewRecord = 1
          else:
            i = 1
            for groupInformation in timespanInformation['group']:
              # print("Entered groupInformation")
              assignmentNameUuid[i] = groupInformation['uuid']
              if groupInformation['name'] == 'Ingest':
                # print("Ingest Subgroup Metadata Found")
                for fieldInformation in groupInformation['field']:
                  if fieldInformation['name'] == 'oly_metadataAssignedTo':
                    for assignmentInformation in fieldInformation['value']:
                      assignmentName[i] = assignmentInformation['value']
                  if fieldInformation['name'] == 'oly_metadataStatus':
                    for assignmentInformation in fieldInformation['value']:
                      assignmentNameStatus[i] = assignmentInformation['value']
                print(f"{assignmentName[i]} - {assignmentNameStatus[i]} - {assignmentNameUuid[i]}")
                i += 1
            #------------------------------
            # Check assignmentNameStatus variable
            createNewRecord = 1
            for assignmentIndex in range(i):
              #------------------------------
              # For action "assigned"
              if metadataAction == "assigned":
                if (assignmentNameStatus[assignmentIndex] == "inProgress") or (assignmentNameStatus[assignmentIndex] == "pending"):
                  if assignmentName[assignmentIndex] == assignedTo:
                    print(f"Action already assigned to {assignedTo}")
                    createNewRecord = 0
                  else:
                    print(f"{assignmentName[assignmentIndex]} does not match {assignedTo}")
              #------------------------------
              
              #------------------------------
              # For action "inProgress"
              elif metadataAction == "inProgress":
                if assignmentName[assignmentIndex] == userName:
                  if assignmentNameStatus[assignmentIndex] == "pending":
                    print(f"Update metadata to inProgress for {userName}")
                    createNewRecord = 0
                    payload = f"<MetadataDocument xmlns=\"http://xml.vidispine.com/schema/vidispine\"><timespan start=\"-INF\" end=\"+INF\"><group uuid=\"{assignmentNameUuid[assignmentIndex]}\"><name>Ingest</name><field><name>oly_metadataBy</name><value>{userName}</value></field><field><name>oly_metadataStatus</name><value>{metadataAction}</value></field></group></timespan></MetadataDocument>"
                    httpApiResponse = requests.request("PUT", urlPutMetadataInfo, headers=headers, data=payload)
                    httpApiResponse.raise_for_status()
                  elif assignmentNameStatus[assignmentIndex] == "inProgress":
                    print(f"Status is Already In Progress - Not Doing Shit for {userName}")
                    createNewRecord = 0
              #------------------------------
              
              #------------------------------
              # For action "completed"
              elif metadataAction == "completed":
                if assignmentName[assignmentIndex] == userName:
                  if (assignmentNameStatus[assignmentIndex] == "inProgress") or (assignmentNameStatus[assignmentIndex] == "pending"):
                    print(f"Update metadata to completed for {userName}")
                    statusDateTime = datetime.now().strftime("%Y-%m-%dT%H:%M:%S")
                    createNewRecord = 0
                    payload = f"<MetadataDocument xmlns=\"http://xml.vidispine.com/schema/vidispine\"><timespan start=\"-INF\" end=\"+INF\"><group uuid=\"{assignmentNameUuid[assignmentIndex]}\"><name>Ingest</name><field><name>oly_metadataBy</name><value>{userName}</value></field><field><name>oly_metadataStatus</name><value>{metadataAction}</value></field><field><name>oly_metadataDate</name><value>{statusDateTime}</value></field></group></timespan></MetadataDocument>"
                    httpApiResponse = requests.request("PUT", urlPutMetadataInfo, headers=headers, data=payload)
                    httpApiResponse.raise_for_status()
                  elif assignmentNameStatus[assignmentIndex] == "completed":
                    print(f"Status is Already Completed - Not Doing Shit for {userName}")
                    createNewRecord = 0
              #------------------------------

              else:
                print("metadataAction type NOT Supported")

              #print(f"createNewRecord = {createNewRecord}")
      else:
        print("NO Subgroup Metadata Found")
        createNewRecord = 1

      if createNewRecord == 1:
        print("Create New Record for User")
        #print(f"{metadataAction} - {userName}")
        if metadataAction == "assigned":
          assignedDateTime = datetime.now().strftime("%Y-%m-%dT%H:%M:%S")
          payload = f"<MetadataDocument xmlns=\"http://xml.vidispine.com/schema/vidispine\"><timespan start=\"-INF\" end=\"+INF\"><group mode=\"add\"><name>Ingest</name><field><name>oly_metadataAssignedTo</name><value>{assignedTo}</value></field><field><name>oly_metadataAssignedDate</name><value>{assignedDateTime}</value></field><field><name>oly_metadataBy</name><value>{assignedTo}</value></field><field><name>oly_metadataStatus</name><value>pending</value></field></group></timespan></MetadataDocument>"
          httpApiResponse = requests.request("PUT", urlPutMetadataInfo, headers=headers, data=payload)
          httpApiResponse.raise_for_status()
        elif metadataAction == "pending":
          statusDateTime = datetime.now().strftime("%Y-%m-%dT%H:%M:%S")
          payload = f"<MetadataDocument xmlns=\"http://xml.vidispine.com/schema/vidispine\"><timespan start=\"-INF\" end=\"+INF\"><group mode=\"add\"><name>Ingest</name><field><name>oly_metadataAssignedTo</name><value>{userName}</value></field><field><name>oly_metadataAssignedDate</name><value>{statusDateTime}</value></field><field><name>oly_metadataBy</name><value>{userName}</value></field><field><name>oly_metadataStatus</name><value>{metadataAction}</value></field></group></timespan></MetadataDocument>"
          httpApiResponse = requests.request("PUT", urlPutMetadataInfo, headers=headers, data=payload)
          httpApiResponse.raise_for_status()
        elif metadataAction == "inProgress":
          statusDateTime = datetime.now().strftime("%Y-%m-%dT%H:%M:%S")
          payload = f"<MetadataDocument xmlns=\"http://xml.vidispine.com/schema/vidispine\"><timespan start=\"-INF\" end=\"+INF\"><group mode=\"add\"><name>Ingest</name><field><name>oly_metadataAssignedTo</name><value>{userName}</value></field><field><name>oly_metadataAssignedDate</name><value>{statusDateTime}</value></field><field><name>oly_metadataBy</name><value>{userName}</value></field><field><name>oly_metadataStatus</name><value>{metadataAction}</value></field></group></timespan></MetadataDocument>"
          httpApiResponse = requests.request("PUT", urlPutMetadataInfo, headers=headers, data=payload)
          httpApiResponse.raise_for_status()
        elif metadataAction == "completed":
          statusDateTime = datetime.now().strftime("%Y-%m-%dT%H:%M:%S")
          payload = f"<MetadataDocument xmlns=\"http://xml.vidispine.com/schema/vidispine\"><timespan start=\"-INF\" end=\"+INF\"><group mode=\"add\"><name>Ingest</name><field><name>oly_metadataAssignedTo</name><value>{userName}</value></field><field><name>oly_metadataAssignedDate</name><value>{statusDateTime}</value></field><field><name>oly_metadataBy</name><value>{userName}</value></field><field><name>oly_metadataStatus</name><value>{metadataAction}</value></field><field><name>oly_metadataDate</name><value>{statusDateTime}</value></field></group></timespan></MetadataDocument>"
          httpApiResponse = requests.request("PUT", urlPutMetadataInfo, headers=headers, data=payload)
          httpApiResponse.raise_for_status()
      else:
        print("NOT Creating a New Record")
  #------------------------------

except HTTPError as http_err:
    print(f'HTTP error occurred: {http_err}')
except Exception as err:
    print(f'Other error occurred: {err}')