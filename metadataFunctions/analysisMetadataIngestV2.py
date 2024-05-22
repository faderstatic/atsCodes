# /opt/cantemo/python/bin/python
#!/usr/bin/python3

# This application ingests metadata from an XML output file into Cantemo
# PREREQUISITE: -none-
# 	Usage: analysisMetadataIngest.py [Cantemo ItemId] [full file path of the XML file]

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
import urllib.parse
#------------------------------

cantemoItemId = sys.argv[1]
# cantemoItemId = os.environ.get("portal_itemId")
errorReport = ''

#------------------------------
# Making API call to Cantemo to get file name
headers = {
  'Authorization': 'Basic YWRtaW46MTBsbXBAc0B0',
  'Cookie': 'csrftoken=HFOqrbk9cGt3qnc6WBIxWPjvCFX0udBdbJnzCv9jECumOjfyG7SS2lgVbFcaHBCc'
}
payload = {}
urlGetSourceFile = f"http://10.1.1.34:8080/API/item/{cantemoItemId}/uri?tag=original"
httpApiResponse = requests.request("GET", urlGetSourceFile, headers=headers, data=payload)
#------------------------------

#------------------------------
# Parsing XML data
ET.register_namespace('ns', 'http://xml.vidispine.com/schema/vidispine')
responseXml = httpApiResponse.text
responseXmlRoot = ET.fromstring(responseXml)
fileLocation = responseXmlRoot.find('{http://xml.vidispine.com/schema/vidispine}uri')
#------------------------------

#------------------------------
# Formatting sorce filename
baseFileName = os.path.basename(fileLocation.text)
justFileName, justFileExtension = os.path.splitext(baseFileName)
modFileName = urllib.parse.unquote(justFileName)
justFileExtensionTrimmed = justFileExtension.replace('.', '')
# print(f"Filename: {justFileName} - File Extension: {justFileExtension}")
# sourceXmlFile = f"/Volumes/creative/MAM/_autoIngest/staging/zAdminTestFiles/xmlIngestTests/{justFileName}_{justFileExtensionTrimmed}.xml"
# sourceXmlFile = f"/Volumes/creative/MAM/zSoftware/batonReports/05212024 vantage test_mxf.xml"
sourceXmlFile = f"/Volumes/creative/MAM/zSoftware/batonReports/{modFileName}.xml"
#------------------------------

tree = ET.parse(sourceXmlFile)
root = tree.getroot()

#------------------------------
# Gather metadata from the report
topLevelInfo = root.find('toplevelinfo')
analysisSummary = topLevelInfo.get('Summary')
errorReport = f"Summary - {analysisSummary}\n\n"
for errorResults in root.iter('error'):
    errorMessage = errorResults.get('synopsis')
    errorDescription = errorResults.get('description')
    errorTimecode = errorResults.get('timecode')
    errorReport = errorReport + f"  Timecode: {errorTimecode} - {errorMessage} ({errorDescription})\n"
#------------------------------

#------------------------------
# Update Cantemo metadata
headers = {
  'Authorization': 'Basic YWRtaW46MTBsbXBAc0B0',
  'Cookie': 'csrftoken=HFOqrbk9cGt3qnc6WBIxWPjvCFX0udBdbJnzCv9jECumOjfyG7SS2lgVbFcaHBCc',
  'Content-Type': 'application/xml'
}
cantemoItemId = 'OLY-4463'
urlPutAnalysisInfo = f"http://10.1.1.34:8080/API/item/{cantemoItemId}/metadata/"
payload = f"<MetadataDocument xmlns=\"http://xml.vidispine.com/schema/vidispine\"><timespan start=\"-INF\" end=\"+INF\"><field><name>oly_analysisReport</name><value>{errorReport}</value></field></timespan></MetadataDocument>"
httpApiResponse = requests.request("PUT", urlPutAnalysisInfo, headers=headers, data=payload)
#------------------------------
