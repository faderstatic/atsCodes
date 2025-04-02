# /opt/cantemo/python/bin/python
#!/usr/local/bin/python3

# This application ingests metadata from Baton XML output file into Cantemo
# PREREQUISITE: -none-
# 	Usage: batonMetadataIngest.py [full file path of the XML file

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
from requests.exceptions import HTTPError
import hashlib
#------------------------------

mondayBoard = "7484684354"
itemName = sys.argv[1]
localFileUrl = sys.argv[2]
mondayApiUrl = "https://api.monday.com/v2"
mondayApiUrlFile = "https://api.monday.com/v2/file"

try:

    executionTime = datetime.datetime.now(timezone.utc)
    # executionTimeUTC = executionTime.replace(tzinfo=timezone.utc)
    currentTimestamp = executionTime.strftime("%Y-%m-%d")
    # print(currentTimestamp)

    payload = f'"{{"query": "mutation {{ create_item (board_id: {mondayBoard}, group_id: "topics", item_name: "{itemName}", column_values: "{{"date4": "{currentTimestamp}"}}") {{ id }} }}","variables":{{}}}}"'
    headers = {
    'Content-Type': 'application/json',
    'API-Version': '2023-07',
    'Authorization': 'eyJhbGciOiJIUzI1NiJ9.eyJ0aWQiOjQxNDI5OTM1OCwiYWFpIjoxMSwidWlkIjo1NTUwMjkzOCwiaWFkIjoiMjAyNC0wOS0yM1QxNDo0NToxMi44NThaIiwicGVyIjoibWU6d3JpdGUiLCJhY3RpZCI6MTk0MTAxNzUsInJnbiI6InVzZTEifQ.iXl1kRu54yQtKTYfaDptUOQpiVZyj4l0HZNrt83l_ao',
    'Cookie': '__cf_bm=cNkEtmHWgpMIYl2MuyPyTZQXgPAfcn39T0xdHxVJegA-1727202889-1.0.1.1-dTAuCH2Y.zUmuj3Xa.rEl_DX0QJfr12wuC_QPDvymecV5hwnlj_iNrGm24i8pwfCCaelnN1eeBV52jLenaVxQId6UQ.akNPEsnNGEeboNi0'
    }

    print(payload)
    print(headers)
    print("--------------------------------------------------")

    response = requests.request("POST", mondayApiUrl, headers=headers, data=payload)
    response.raise_for_status

    print(response.text)

    payload = {'query': 'mutation ($localFile: File!) { add_file_to_column (file: $localFile, item_id: 7491644431, column_id: "files__1") { id } }'}
    # files=[ ('variables[localFile]',('Devices.png',open('/Users/kkanjanapitak/Downloads/Workfront/Projects Documents/@freetvla/Devices.png','rb'),'image/png')) ]
    headers = {
    'Content-Type': 'multipart/form-data',
    'API-Version': '2023-07',
    'Authorization': 'eyJhbGciOiJIUzI1NiJ9.eyJ0aWQiOjQxNDI5OTM1OCwiYWFpIjoxMSwidWlkIjo1NTUwMjkzOCwiaWFkIjoiMjAyNC0wOS0yM1QxNDo0NToxMi44NThaIiwicGVyIjoibWU6d3JpdGUiLCJhY3RpZCI6MTk0MTAxNzUsInJnbiI6InVzZTEifQ.iXl1kRu54yQtKTYfaDptUOQpiVZyj4l0HZNrt83l_ao'
    }

    # response = requests.request("POST", mondayApiUrlFile, headers=headers, data=payload, files=files)

    # print(response.text)


except HTTPError as http_err:
    print(f'HTTP error occurred: {http_err}')
except Exception as err:
    print(f'Other error occurred: {err}')