#!/opt/cantemo/python/bin/python
# /usr/bin/python3

# This application ingests metadata from an XML output file into Cantemo
# PREREQUISITE: -none-
# 	Usage: analysisMetadataIngest.py [Cantemo ItemId] [full file path of the XML file]

#------------------------------
# Libraries
import os
import os.path
import glob
import sys
import datetime
import time
import subprocess
import requests
from pathlib import Path
import shutil
import xml.etree.ElementTree as ET
import urllib.parse
# Cantemo Library
import django
import logging
#------------------------------

#------------------------------
# Cantemo Rulesengione3 Environment
# sys.path.append("/opt/cantemo/portal")
# os.environ["DJANGO_SETTINGS_MODULE"] = "portal.settings"

# django.setup()
# Now Portal/Django environment is setup and helper classes are available

# Logging through standard Portal logging, i.e. to /var/log/cantemo/portal/portal.log
# log = logging.getLogger("portal.plugins.rulesengine3.shellscripts")

# Access variables from the Rules Engine through os.environ
# log.info("All script variables:")
# for key, value in os.environ.items():
#     if key.startswith("portal_"):
#         log.info(" %s=%r", key, value)

# Access command line arguments from Rules Engine through sys.argv
# log.info("All script command line arguments (%i):", len(sys.argv))
# for i, arg in enumerate(sys.argv):
#     log.info(" sys.argv[%i]=%s", i, arg)

# item_id = os.environ.get("portal_itemId")
# if item_id:
#     from portal.vidispine.iitem import ItemHelper

#     ith = ItemHelper()
#     log.info("Item title: %s", ith.getItem(item_id).getTitle())
# else:
#     log.info("portal_itemId not set")

cantemoItemId = sys.argv[1]
# cantemoItemId = os.environ.get("portal_itemId")
errorReport = ''

#------------------------------
# Making API call to Cantemo to get file name
# headers = {
#   'Authorization': 'Basic YWRtaW46MTBsbXBAc0B0',
#   'Cookie': 'csrftoken=HFOqrbk9cGt3qnc6WBIxWPjvCFX0udBdbJnzCv9jECumOjfyG7SS2lgVbFcaHBCc'
# }
# payload = {}
# urlGetSourceFile = f"http://10.1.1.34:8080/API/item/{cantemoItemId}/uri?tag=original"
# httpApiResponse = requests.request("GET", urlGetSourceFile, headers=headers, data=payload)
#------------------------------

#------------------------------
# Parsing XML data
# ET.register_namespace('ns', 'http://xml.vidispine.com/schema/vidispine')
# responseXml = httpApiResponse.text
# responseXmlRoot = ET.fromstring(responseXml)
# fileLocation = responseXmlRoot.find('{http://xml.vidispine.com/schema/vidispine}uri')
#------------------------------

#------------------------------
# Formatting source filename
# baseFileName = os.path.basename(fileLocation.text)
# justFileName, justFileExtension = os.path.splitext(baseFileName)
# modFileName = urllib.parse.unquote(justFileName)
# justFileExtensionTrimmed = justFileExtension.replace('.', '')
# print(f"Filename: {justFileName} - File Extension: {justFileExtension}")
# sourceXmlFile = f"/Volumes/creative/MAM/zSoftware/batonReports/{modFileName}.xml"
sourceXmlFile = Path(f"/Volumes/creative/MAM/zSoftware/batonReports/{cantemoItemId}.xml")
completedXmlFolder = Path("/Volumes/creative/MAM/zSoftware/batonReports/zCompleted")
#------------------------------

#------------------------------
# Making API call to Cantemo to get existing oly_analysisReport metadata
headers = {
  'Authorization': 'Basic YWRtaW46MTBsbXBAc0B0',
  'Cookie': 'csrftoken=HFOqrbk9cGt3qnc6WBIxWPjvCFX0udBdbJnzCv9jECumOjfyG7SS2lgVbFcaHBCc'
}
payload = {}
urlGetReport = f"http://10.1.1.34:8080/API/item/{cantemoItemId}/metadata?field=oly_analysisReport&terse=yes"
httpApiResponse = requests.request("GET", urlGetReport, headers=headers, data=payload)
#------------------------------

#------------------------------
# Parsing XML data
ET.register_namespace('ns', 'http://xml.vidispine.com/schema/vidispine')
responseXml = httpApiResponse.text
responseXmlRoot = ET.fromstring(responseXml)
itemInformation = responseXmlRoot.find('{http://xml.vidispine.com/schema/vidispine}item')
analysisReport = itemInformation.find('oly_analysisReport')
#------------------------------

if analysisReport is not None:

  print(analysisReport.text)

else:

  if sourceXmlFile.is_file():

    tree = ET.parse(sourceXmlFile)
    root = tree.getroot()

    #------------------------------
    # Gather metadata from the report
    topLevelInfo = root.find('toplevelinfo')
    analysisSummary = topLevelInfo.get('Summary')
    errorReport = f"Summary - {analysisSummary}\n\n"
    for errorResults in root.iter('error'):
      if errorResults is not None:
        errorMessage = errorResults.get('synopsis')
        errorDescription = errorResults.get('description')
        errorTimecode = errorResults.get('timecode')
        errorReport = errorReport + f"  Timecode: {errorTimecode} - {errorMessage} ({errorDescription})\n"
      else:
         errorReport = "There was no error reported in the analysis report XML"
    #------------------------------
    shutil.move(sourceXmlFile,completedXmlFolder)
  else:
    errorReport = f"Analysis report XML file does not exist - (missing) {sourceXmlFile}"

  #------------------------------
  # Update Cantemo metadata
  headers = {
    'Authorization': 'Basic YWRtaW46MTBsbXBAc0B0',
    'Cookie': 'csrftoken=HFOqrbk9cGt3qnc6WBIxWPjvCFX0udBdbJnzCv9jECumOjfyG7SS2lgVbFcaHBCc',
    'Content-Type': 'application/xml'
  }
  urlPutAnalysisInfo = f"http://10.1.1.34:8080/API/item/{cantemoItemId}/metadata/"
  payload = f"<MetadataDocument xmlns=\"http://xml.vidispine.com/schema/vidispine\"><timespan start=\"-INF\" end=\"+INF\"><field><name>oly_analysisReport</name><value>{errorReport}</value></field></timespan></MetadataDocument>"
  httpApiResponse = requests.request("PUT", urlPutAnalysisInfo, headers=headers, data=payload)
  #------------------------------