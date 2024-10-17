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
from email.mime.text import MIMEText
from requests.exceptions import HTTPError
#------------------------------

#------------------------------
# Internal Functions
#------------------------------

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
  olderFileDayLimit = 14

  if analysisType == "fingerprint":
    resultFile = f"/opt/olympusat/resources/vionlabsReports/{cantemoItemId}_FP.json"
  elif analysisType == "bingemarkers":
    resultFile = f"/opt/olympusat/resources/vionlabsReports/{cantemoItemId}_BM.json"
  elif analysisType == "adbreaks":
    resultFile = f"/opt/olympusat/resources/vionlabsReports/{cantemoItemId}_AB.json"
  
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
        urlGetVionlabResult = f"https://apis.prod.vionlabs.com/results/fingerprintplus/v1/{cantemoItemId}?&key={customerKey}"
      elif analysisType == "bingemarkers":
        urlGetVionlabResult = f"https://apis.prod.vionlabs.com/results/markers/v1/asset/{cantemoItemId}?&key={customerKey}"
      elif analysisType == "adbreaks":
        urlGetVionlabResult = f"https://apis.prod.vionlabs.com/results/adbreaks/v2/filter/frame/{cantemoItemId}?&key={customerKey}"
      httpApiResponse = requests.request("GET", urlGetVionlabResult, headers=headers, data=payload)
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

    msg = f"Attachment - result file for {analysisType} created on {resultFileCreation}"
    msg['Subject'] = f"Result file for {analysisType}"
    msg['To'] = requesterEmail
    msg['From'] = "cantemo@olympusat.com"

    #------------------------------
    # Email file to initiating user
    s = smtplib.SMTP(smtpHost)
    s.login(smtpUsername, smtpPassword)
    s.send_message(msg)
    s.quit()
    #------------------------------

    #------------------------------
    # Update The User
    print(f"{resultFile} (created on {resultFileCreation}) has been emailed to {requesterEmail}")
    #------------------------------
    #------------------------------

except HTTPError as http_err:
    print(f'HTTP error occurred: {http_err}')
except Exception as err:
    print(f'Other error occurred: {err}')