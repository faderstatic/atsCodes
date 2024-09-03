#!/opt/cantemo/python/bin/python
# /usr/bin/python3

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

eventUrl = sys.argv[1]
maxPresets = sys.argv[2]
destinationFolder = sys.argv[3]
apiUserKey = "FbABGpvsgGDkTKUZchLv"
md5ForApiUserKey = hashlib.md5(apiUserKey).hexdigest()

try:
    print(md5ForApiUserKey)