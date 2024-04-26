#!/opt/cantemo/python/bin/python

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
import xml.etree.ElementTree as ET
#------------------------------

tree = ET.parse('C:\Users\kkanjanapitak\Documents\atsCodes\sampleFiles\Baton\Grand_HD_RU_SGRAND1_S5E1_Master_mxf.xml')
root = tree.getroot()

print(root.tag)