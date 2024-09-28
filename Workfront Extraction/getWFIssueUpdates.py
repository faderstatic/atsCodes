# /opt/cantemo/python/bin/python
#!/usr/local/bin/python3

# This application ingests metadata from Baton XML output file into Cantemo
# PREREQUISITE: -none-
# 	Usage: /usr/local/bin/python3 getWFIssueUpdates.py [a text file with list of updateObjIDs]

#------------------------------
# Libraries
import os
import glob
import sys
import datetime
from datetime import timezone
import time
import subprocess
import requests
import json
import xml.etree.ElementTree as ET
import hashlib
#------------------------------

wfIdListFile = sys.argv[1]

try:

    executionTime = datetime.datetime.now(timezone.utc)
    currentTimestamp = executionTime.strftime("%Y%m%d%H%M")
    issueIdFile = open(wfIdListFile, 'r')
    issueIdList = issueIdFile.readlines()
    # print(f"Script starts on {currentTimestamp}")
    payload = {}
    headers = {
    'apiKey': 't8oaszf4nnqe21711r7jaayq6y4vtzpn',
    }
    for issueId in issueIdList:
        print(f"Calling to get info on {issueId}")
        issueIdNew = issueId.rstrip("\n")
        issueUpdatesUrl = f"https://olympusat.my.workfront.adobe.com/attask/api/v18.0/issue/{issueIdNew}/?fields=updates,updates:entryDate,updates:enteredByName,entryDate,lastUpdateDate,ownerID,enteredBy"
        # print(issueUpdatesUrl)
        httpApiResponse = requests.request("GET", issueUpdatesUrl, headers=headers, data=payload)
        httpApiResponse.raise_for_status()
        responseJson = httpApiResponse.json() if httpApiResponse and httpApiResponse.status_code == 200 else None
        resultData = responseJson['data']
        print(f"Clip name: {resultData['name']}")
        if not resultData['updates']:
            print(' -- skipping --')
        else:
            uniqueUpdateFile = f"{resultData['name']}_{issueIdNew}.txt"
            print(f"Writing updates to file {uniqueUpdateFile}")
            issueWithUpdatesFile = open(uniqueUpdateFile, 'a')
            # print(resultData['updates'])
            issueWithUpdatesFile.write(json.dumps(resultData['updates']))
            issueWithUpdatesFile.close()

    issueIdFile.close()

except HTTPError as http_err:
    print(f'HTTP error occurred: {http_err}')
except Exception as err:
    print(f'Other error occurred: {err}')