# /opt/cantemo/python/bin/python
#!/usr/bin/python3

# This application ingests metadata from Baton XML output file into Cantemo
# PREREQUISITE: -none-
# 	Usage: /usr/local/bin/python3 getWFAllIssues.py [project ID]

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

wfProjectId = sys.argv[1]
projectIssuesUrlRoot = f"https://olympusat.my.workfront.adobe.com/attask/api/v18.0/issue/search?projectID={wfProjectId}&entryDate_Sort=desc&method=GET"
# &$$FIRST=0&$$LIMIT=200"
endOfList = False
pageStart = 0
pageIncrement = 100
pageIncrementStr = str(pageIncrement)

try:

    executionTime = datetime.datetime.now(timezone.utc)
    currentTimestamp = executionTime.strftime("%Y%m%d%H%M")
    exportFile = open(f"{wfProjectId}_{currentTimestamp}.txt", 'a')
    issueIdFile = open(f"UpdateID_{wfProjectId}_{currentTimestamp}.txt", 'a')
    print(f"Script starts on {currentTimestamp}")
    # print(f"End of list is {endOfList}")
    payload = {}
    headers = {
    'apiKey': 't8oaszf4nnqe21711r7jaayq6y4vtzpn',
    }
    while not endOfList:
        pageStartStr = str(pageStart)
        print(f"Processing item block starting at {pageStartStr}")
        projectIssuesUrl = projectIssuesUrlRoot + f"&$$FIRST={pageStartStr}&$$LIMIT={pageIncrementStr}"
        httpApiResponse = requests.request("POST", projectIssuesUrl, headers=headers, data=payload)
        httpApiResponse.raise_for_status()
        responseJson = httpApiResponse.json() if httpApiResponse and httpApiResponse.status_code == 200 else None
        if httpApiResponse.text == '{"data":[]}':
            endOfList = True
        else:
            exportFile.write(f"{json.dumps(responseJson)}\n")
            for individualIssue in responseJson['data']:
                updateId = individualIssue['ID']
                issueIdFile.write(f"{updateId}\n")
            pageStart += pageIncrement
    exportFile.close()
    issueIdFile.close()

except HTTPError as http_err:
    print(f'HTTP error occurred: {http_err}')
except Exception as err:
    print(f'Other error occurred: {err}')