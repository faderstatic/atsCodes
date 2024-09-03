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
import time
import subprocess
import requests
import xml.etree.ElementTree as ET
import hashlib
#------------------------------

authUser = sys.argv[1]
eventUrl = sys.argv[2]
maxPresets = int(sys.argv[3]) + 1
destinationFolder = sys.argv[4]
timeOffset = 30
apiUserKey = "FbABGpvsgGDkTKUZchLv"
apiUserKeyEncoded = apiUserKey.encode('utf-8')
apiUserKeyMd5 = hashlib.md5(apiUserKeyEncoded).hexdigest()

try:
    for i in range(1,maxPresets):
        executionTime = datetime.datetime.now()
        # executionTimeUnix = int(round(executionTime.timestamp()))
        authExpiration = executionTime + datetime.timedelta(seconds=timeOffset)
        authExpirationUnix = int(round(authExpiration.timestamp()))
        # print(f"{executionTimeUnix} - {authExpirationUnix}")
        authExpirationStr = str(authExpirationUnix)
        authExpirationEncoded = authExpirationStr.encode("utf-8")
        authExpirationMd5 = hashlib.md5(authExpirationEncoded).hexdigest()
        # print(f"{apiUserKeyMd5} - {authExpirationMd5}")
        apiParameter="/" + eventUrl + "/" + str(i) + authUser + apiUserKey + authExpirationStr
        apiParameterEncoded = apiParameter.encode("utf-8")
        apiParameterMd5 = hashlib.md5(apiParameterEncoded).hexdigest()
        fullParameterMd5 = hex(int(apiUserKeyMd5, 16) + int(apiParameterMd5, 16))[2:]
        # print(fullParameterMd5)
        #------------------------------
        # Making API to AWS directory to xml files
        headers = {
            'X-Auth-User': 'admin',
            'X-Auth-Expires': f'{authExpirationUnix}',
            'X-AuthKey': f'{fullParameterMd5}',
            'Accept': 'application/xml'
        }
        urlGetElement = f"http://172.16.1.120/{eventUrl}/{i}.xml?clean=true"
        payload = {}
        httpApiResponse = requests.request("GET", urlGetElement, headers=headers, data=payload)
        httpApiResponse.raise_for_status()
        #------------------------------

except HTTPError as http_err:
    print(f'HTTP error occurred: {http_err}')
except Exception as err:
    print(f'Other error occurred: {err}')