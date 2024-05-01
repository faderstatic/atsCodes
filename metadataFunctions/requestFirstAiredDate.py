# /opt/cantemo/python/bin/python
#!/usr/bin/python3

# This application ingests First Aired Date property from Mira
# PREREQUISITE: -none-
# 	Usage: requestFirstAiredDate.py [Cantemo Item Id] [contract ID]

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
#------------------------------

cantemoItemId = sys.argv[1]
# cantemoItemId = os.environ.get("portal_itemId")

#------------------------------
# Making API call to Cantemo to get contract ID
headersCantemo = {
  'Authorization': 'Basic YWRtaW46MTBsbXBAc0B0',
  'Cookie': 'csrftoken=HFOqrbk9cGt3qnc6WBIxWPjvCFX0udBdbJnzCv9jECumOjfyG7SS2lgVbFcaHBCc'
}
payloadCantemo = {}
urlGetContractId = f"http://10.1.1.34:8080/API/item/{cantemoItemId}/metadata?field=oly_rightslineContractId&terse=yes"
httpApiResponse = requests.request("GET", urlGetContractId, headers=headersCantemo, data=payloadCantemo)
#------------------------------

#------------------------------
# Parsing XML data
ET.register_namespace('ns', 'http://xml.vidispine.com/schema/vidispine')
responseXml = httpApiResponse.text
print(responseXml)
responseXmlRoot = ET.fromstring(responseXml)
# print(responseXmlRoot.tag, responseXmlRoot.attrib)
cantemoContractId = responseXmlRoot
for child in cantemoContractId:
    print(child.tag)
# print(cantemoContractId.attrib)
#------------------------------

#------------------------------
# Formatting sorce  filename
# baseFileName = os.path.basename(fileLocation.text)
# justFileName, justFileExtension = os.path.splitext(baseFileName)
# justFileExtensionTrimmed = justFileExtension.replace('.', '')
# print(f"Filename: {justFileName} - File Extension: {justFileExtension}")
# sourceXmlFile = f"/Volumes/creative/MAM/_autoIngest/staging/zAdmin/xmlImport/{justFileName}_{justFileExtensionTrimmed}.xml"
# sourceXmlFile = f"/mnt/c/Users/kkanjanapitak/Desktop/Repositories/atsCodes/sampleFiles/Baton/Grand_HD_RU_SGRAND1_S5E1_Master_mxf.xml"
#------------------------------

# tree = ET.parse(sourceXmlFile)
# root = tree.getroot()

#------------------------------
# Gather metadata from the report
# for errorResults in root.iter('error'):
#     errorMessage = errorResults.get('synopsis')
#     errorDescription = errorResults.get('description')
#     errorTimecode = errorResults.get('timecode')
#     errorReport = errorReport + f"{errorTimecode} - {errorMessage} ({errorDescription})\n"
#------------------------------

#------------------------------
# Update Cantemo metadata
# headers = {
#   'Authorization': 'Basic YWRtaW46MTBsbXBAc0B0',
#   'Cookie': 'csrftoken=HFOqrbk9cGt3qnc6WBIxWPjvCFX0udBdbJnzCv9jECumOjfyG7SS2lgVbFcaHBCc',
#   'Content-Type': 'application/xml'
# }
# cantemoItemId = 'OLY-203'
# urlPutAnalysisInfo = f"http://10.1.1.34:8080/API/item/{cantemoItemId}/metadata/"
# payload = f"<MetadataDocument xmlns=\"http://xml.vidispine.com/schema/vidispine\"><timespan start=\"-INF\" end=\"+INF\"><field><name>oly_analysisReport</name><value>{errorReport}</value></field></timespan></MetadataDocument>"
# httpApiResponse = requests.request("PUT", urlPutAnalysisInfo, headers=headers, data=payload)