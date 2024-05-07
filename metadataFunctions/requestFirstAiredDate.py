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
import json
from requests.exceptions import HTTPError
#------------------------------

try:
  cantemoItemId = sys.argv[1]
  # cantemoItemId = os.environ.get("portal_itemId")
  ns = {'vidispine': 'http://xml.vidispine.com/schema/vidispine'}

  #------------------------------
  # Making API call to Cantemo to get content flag
  headersCantemo = {
    'Authorization': 'Basic YWRtaW46MTBsbXBAc0B0',
    'Cookie': 'csrftoken=HFOqrbk9cGt3qnc6WBIxWPjvCFX0udBdbJnzCv9jECumOjfyG7SS2lgVbFcaHBCc'
  }
  payloadCantemo = {}
  urlGetContentFlags = f"http://10.1.1.34:8080/API/item/{cantemoItemId}/metadata?field=oly_contentFlags&includeConstraintValue=all&terse=yes"
  httpApiResponse = requests.request("GET", urlGetContentFlags, headers=headersCantemo, data=payloadCantemo)
  httpApiResponse.raise_for_status()
  #------------------------------

  #------------------------------
  # Parsing XML data to get content Flags (cantemoContentFlag)
  responseXml = httpApiResponse.text
  flagRoot = ET.XML(responseXml)
  legacyContentFlag = 'false'
  contentEmptyFlag = 'false'

  for child in flagRoot.findall('vidispine:item', ns):
    for cantemoContentFlags in child.findall('oly_contentFlags'):
      if not cantemoContentFlags.text:
        contentEmptyFlag = 'true'
      elif cantemoContentFlags.text == 'legacycontent':
        legacyContentFlag = 'true'

  if contentEmptyFlag == 'false':
    if legacyContentFlag == 'true':
      #------------------------------
      # Making API call to Cantemo to get contract code
      payloadCantemo = {}
      urlGetContractCode = f"http://10.1.1.34:8080/API/item/{cantemoItemId}/metadata?field=oly_contractCode&terse=yes"
      httpApiResponse = requests.request("GET", urlGetContractCode, headers=headersCantemo, data=payloadCantemo)
      httpApiResponse.raise_for_status()
      #------------------------------

      #------------------------------
      # Parsing XML data to get Rightsline contract Code (contractCode))
      responseXml = httpApiResponse.text
      root = ET.XML(responseXml)
      for child in root.findall('vidispine:item', ns):
        for cantemoContractCode in child.findall('oly_contractCode'):
          rightslineContractId = cantemoContractCode.text

      #------------------------------
      # Making API call to Cantemo to get Rightsline title code
      urlGetTitleCode = f"http://10.1.1.34:8080/API/item/{cantemoItemId}/metadata?field=oly_titleCode&terse=yes"
      httpApiResponse = requests.request("GET", urlGetTitleCode, headers=headersCantemo, data=payloadCantemo)
      httpApiResponse.raise_for_status()
      #------------------------------

      #------------------------------
      # Parsing XML data to get Rightsline title code (titleCode)
      responseXml = httpApiResponse.text
      root = ET.XML(responseXml)
      for child in root.findall('vidispine:item', ns):
        for cantemoTitleCode in child.findall('oly_titleCode'):
          rightslineItemId = cantemoTitleCode.text
      #------------------------------
    else:
      #------------------------------
      # Making API call to Cantemo to get contract ID
      payloadCantemo = {}
      urlGetContractId = f"http://10.1.1.34:8080/API/item/{cantemoItemId}/metadata?field=oly_rightslineContractId&terse=yes"
      httpApiResponse = requests.request("GET", urlGetContractId, headers=headersCantemo, data=payloadCantemo)
      httpApiResponse.raise_for_status()
      #------------------------------

      #------------------------------
      # Parsing XML data to get Rightsline contract ID (rightslineContractId)
      responseXml = httpApiResponse.text
      root = ET.XML(responseXml)
      # print(root.tag, root.attrib, root.text)
      for child in root.findall('vidispine:item', ns):
        for cantemoContractId in child.findall('oly_rightslineContractId'):
          rightslineContractId = cantemoContractId.text

      #------------------------------
      # Making API call to Cantemo to get Rightsline Item ID
      urlGetRightslineItemId = f"http://10.1.1.34:8080/API/item/{cantemoItemId}/metadata?field=oly_rightslineItemId&terse=yes"
      httpApiResponse = requests.request("GET", urlGetRightslineItemId, headers=headersCantemo, data=payloadCantemo)
      httpApiResponse.raise_for_status()
      #------------------------------

      #------------------------------
      # Parsing XML data to get Rightsline item ID (rightslineItemId)
      # ET.register_namespace('ns', 'http://xml.vidispine.com/schema/vidispine')
      responseXml = httpApiResponse.text
      root = ET.XML(responseXml)
      # print(root.tag, root.attrib, root.text)
      for child in root.findall('vidispine:item', ns):
        for cantemoRightslineId in child.findall('oly_rightslineItemId'):
          rightslineItemId = cantemoRightslineId.text
      #------------------------------
    #------------------------------
    # print(f'{rightslineContractId} - {rightslineItemId}')
    #------------------------------
    # Making API call to Mira to get First Aired Date
    headersMira = {
      'Cotent-Type': 'text/plain'
    }
    payloadMira = {}
    rightslineContractId = 'C000000' # this is only for testing
    rightslineItemId = 'MMFQEM1' # this is only for testing
    urlGetFAD = f"http://10.1.1.22:83/Service1.svc/first_aired_date/{rightslineContractId}-{rightslineItemId}"
    httpFADResponse = requests.request("GET", urlGetFAD, headers=headersMira, data=payloadMira)
    httpFADResponse.raise_for_status()
    responseJson = httpFADResponse.json()
    itemFAD = json.loads(httpFADResponse.text)
    for lineValue in responseJson:
      itemFAD = lineValue["first_aired_Date"]
    # print(itemFAD)

    itemFAD = '2022-02-16T21:12:28' # this is only for testing
    payloadCantemo = f'<MetadataDocument xmlns="http://xml.vidispine.com/schema/vidispine"><timespan start="-INF" end="+INF"><field><name>oly_firstUseDate</name><value>{itemFAD}</value></field></timespan></MetadataDocument>'
    urlPutFirstUseDate = f"http://10.1.1.34:8080/API/item/{cantemoItemId}/metadata?field=oly_firstUseDate&terse=yes"
    requests.request("PUT", urlPutFirstUseDate, headers=headersCantemo, data=payloadCantemo)

except HTTPError as http_err:
    print(f'HTTP error occurred: {http_err}')
except Exception as err:
    print(f'Other error occurred: {err}')