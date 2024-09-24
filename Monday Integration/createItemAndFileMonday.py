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
import hashlib
#------------------------------

import requests

mondayApiUrl = "https://api.monday.com/v2"

payload = "{\"query\":\"mutation { create_item (board_id: 7484684354, group_id: \"topics\", item_name: \"Created by API 05 with Date Stamp - date4\", column_values: \"{\"date4\": \"2024-09-24\"}\") { id } }\",\"variables\":{}}"
headers = {
  'Content-Type': 'application/json',
  'API-Version': '2023-07',
  'Authorization': 'eyJhbGciOiJIUzI1NiJ9.eyJ0aWQiOjQxNDI5OTM1OCwiYWFpIjoxMSwidWlkIjo1NTUwMjkzOCwiaWFkIjoiMjAyNC0wOS0yM1QxNDo0NToxMi44NThaIiwicGVyIjoibWU6d3JpdGUiLCJhY3RpZCI6MTk0MTAxNzUsInJnbiI6InVzZTEifQ.iXl1kRu54yQtKTYfaDptUOQpiVZyj4l0HZNrt83l_ao',
  'Cookie': '__cf_bm=TJwql7dSQhY3Er9npxZ755UAJ5HZIUZ5UtP7zmaSjcg-1727180088-1.0.1.1-6mHYFAnqF1PjVgUC4JyOJennwFJ_obb8unNOjOjst1WRXpgddZMG4gO3rW1ZAtHcjOQ9nqWT1d_90HnjojGJmcpgrcDOG0bznmfR9RRTrFs'
}

response = requests.request("POST", mondayApiUrl, headers=headers, data=payload)

print(response.text)

payload = {'query': 'mutation ($localFile: File!) { add_file_to_column (file: $localFile, item_id: 7491644431, column_id: "files__1") { id } }'}
files=[
  ('variables[localFile]',('Devices.png',open('/Users/kkanjanapitak/Downloads/Workfront/Projects Documents/@freetvla/Devices.png','rb'),'image/png'))
]
headers = {
  'Content-Type': 'multipart/form-data',
  'API-Version': '2023-07',
  'Authorization': 'eyJhbGciOiJIUzI1NiJ9.eyJ0aWQiOjQxNDI5OTM1OCwiYWFpIjoxMSwidWlkIjo1NTUwMjkzOCwiaWFkIjoiMjAyNC0wOS0yM1QxNDo0NToxMi44NThaIiwicGVyIjoibWU6d3JpdGUiLCJhY3RpZCI6MTk0MTAxNzUsInJnbiI6InVzZTEifQ.iXl1kRu54yQtKTYfaDptUOQpiVZyj4l0HZNrt83l_ao'
}

response = requests.request("POST", mondayApiUrl, headers=headers, data=payload, files=files)

print(response.text)


except HTTPError as http_err:
    print(f'HTTP error occurred: {http_err}')
except Exception as err:
    print(f'Other error occurred: {err}')