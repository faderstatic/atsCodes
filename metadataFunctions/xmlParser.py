# /opt/cantemo/python/bin/python
#!/usr/bin/python3

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
#------------------------------

tree = ET.parse('/mnt/c/Users/kkanjanapitak/Desktop/Repositories/atsCodes/sampleFiles/Baton/Grand_HD_RU_SGRAND1_S5E1_Master_mxf.xml')
root = tree.getroot()

# print(root.tag)
# print(root.attrib)

# for child in root:
#     print(child.tag, child.attrib)

for errorResults in root.iter('error'):
#     print(errorResults.attrib)
    errorMessage = errorResults.get('synopsis')
    errorDescription = errorResults.get('description')
    errorTimecode = errorResults.get('timecode')
    print(f"{errorTimecode} - {errorMessage} ({errorDescription})")