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
import subprocess
import xml.dom.minidom
import xml.etree.ElementTree as ET
import requests
import json
import smtplib
from email.message import EmailMessage
from requests.exceptions import HTTPError
#------------------------------

#------------------------------
# Internal Functions

def readCantemoMetadata(rcmItemId, rcmFieldName):
  #------------------------------
  # Making API to Cantemo to get lookup values
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
      for titleInformation in itemInformation[rcmFieldName]:
        metadataValue = titleInformation['value']
        if metadataValue == '':
          metadataValue = '<none>'
  #------------------------------
  return metadataValue

#------------------------------

try:

  cantemoItemId = sys.argv[1]
  cantemoUsername = sys.argv[2]
  analysisType = sys.argv[3]
  customerKey = 'kt8cyimHXxUzFNGyhd7c7g'
  # smtpHost = "smtp://smtp-mail.outlook.com:587"
  smtpHost = 'smtp-mail.outlook.com'
  smtpUsername = 'notify@olympusat.com'
  smtpPassword = '6bOblVsLg9bPQ8WG7JC7f8Zump'
  errorReport = ''
  olderFileDayLimit = 30

  if analysisType == "fingerprint":
    resultFile = f"/opt/olympusat/resources/vionlabsReports/{cantemoItemId}_FP.json"
    resultFilename = f"{cantemoItemId}_FP.json"
  elif analysisType == "bingemarkers":
    resultFile = f"/opt/olympusat/resources/vionlabsReports/{cantemoItemId}_BM.json"
    resultFilename = f"{cantemoItemId}_BM.json"
  elif analysisType == "adbreaks":
    resultFile = f"/opt/olympusat/resources/vionlabsReports/{cantemoItemId}_AB.json"
    resultFilename = f"{cantemoItemId}_AB.json"
  
  if os.path.isfile(resultFile):
    resultFileCreation = os.path.getctime(resultFile)
    timeNow = time.time()
    fileCreationLimitOffset = timeNow - (60 * 60 * 24 * olderFileDayLimit)
    
    if resultFileCreation > fileCreationLimitOffset:
      existingAnalysisRead = open(resultFile, "r")
      responseJson = json.loads(existingAnalysisRead.read())
      existingAnalysisRead.close()
    else:
      #------------------------------
      # Making API call to Vionlabs to get new result
      headers = {
        'Accept': 'application/json'
      }
      payload = {}
      if analysisType == "fingerprint":
        urlGetVionlabsResult = f"https://apis.prod.vionlabs.com/results/fingerprintplus/v1/{cantemoItemId}?&key={customerKey}"
      elif analysisType == "bingemarkers":
        urlGetVionlabsResult = f"https://apis.prod.vionlabs.com/results/markers/v1/asset/{cantemoItemId}?&key={customerKey}"
      elif analysisType == "adbreaks":
        urlGetVionlabsResult = f"https://apis.prod.vionlabs.com/results/adbreaks/v2/filter/frame/{cantemoItemId}?&key={customerKey}"
      httpApiResponse = requests.request("GET", urlGetVionlabsResult, headers=headers, data=payload)
      httpApiResponse.raise_for_status()
      responseJson = httpApiResponse.json()
      #------------------------------
      # Writing response data to a file
      apiResponseJson = json.loads(httpApiResponse.text)
      apiResponseJsonFormat = json.dumps(apiResponseJson, indent=2)
      responseWriting = open(resultFile, "w")
      responseWriting.write(apiResponseJsonFormat)
      responseWriting.close()
      time.sleep(5)
      resultFileCreation = os.path.getctime(resultFile)
      #------------------------------
    if cantemoUsername == "iarenas":
      requesterEmail = "ivan@olympusat.com"
    elif cantemoUsername == "standardpractices":
      requesterEmail = "censorship@olympusat.com"
    elif cantemoUsername == "scopenhaver":
      requesterEmail = "shawn@olympusat.com"
    elif cantemoUsername == "ldalton":
      requesterEmail = "larry@olympusat.com"
    elif cantemoUsername == "jdaly":
      requesterEmail = "jasondaly@olympusat.com"
    elif cantemoUsername == "aolabarria":
      requesterEmail = "andrea@olympusat.com"
    else:
      requesterEmail = f"{cantemoUsername}@olympusat.com"

    cantemoTitle = readCantemoMetadata(cantemoItemId, 'title')
    time.sleep(1)
    cantemoTitleCode = readCantemoMetadata(cantemoItemId, 'oly_titleCode')
    # time.sleep(1)
    # cantemoRightslineId = readCantemoMetadata(cantemoItemId, 'oly_rightslineItemId')

    resultFileCreationStr = datetime.datetime.fromtimestamp(resultFileCreation).strftime('%m-%d-%Y %H:%M:%S')
    msg = EmailMessage()
    msg['Subject'] = f"MAM - Result file for {analysisType} analysis"
    msg['To'] = requesterEmail
    msg['From'] = "notify@olympusat.com"
    msg.set_content(f"Attachment - result file for {analysisType} created on {resultFileCreationStr}\nTitle: {cantemoTitle}\nTitle Code: {cantemoTitleCode}")
    with open(resultFile, 'rb') as f:
      file_data = f.read()
    msg.add_attachment(file_data, maintype='text', subtype='plain', filename=resultFilename)

    #------------------------------
    # Email file to initiating user
    s = smtplib.SMTP(smtpHost, 587)
    s.connect(smtpHost, 587)
    s.ehlo()
    s.starttls()
    s.ehlo()
    # s.set_debuglevel(1)
    s.login(smtpUsername, smtpPassword)
    s.send_message(msg)
    s.quit()
    #------------------------------

    #------------------------------
    # Update The User
    print(f"{resultFile} (created on {resultFileCreationStr}) has been emailed to {requesterEmail}")
    #------------------------------
    #------------------------------

except HTTPError as http_err:
    print(f'HTTP error occurred: {http_err}')
except Exception as err:
    print(f'Other error occurred: {err}')