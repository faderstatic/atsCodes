#!/opt/cantemo/python/bin/python

#::***************************************************************************************************************************
# This application monitors a source folder and once files are uploaded to it, will move to target folder
# Engineers: Ryan Sims & Tang Kanjanapitak
# Client: Olympusat
# Updated: 10/25/2024
# Rev A: 
# PREREQUISITE: This script must receive watch folder location, destination folder location and delay in seconds.
# 	Usage: ingestWorkflow-fileMoverToIngestFolder.py [watch folder] [destination folder]
#
# Note:
#  System requirements: This script will only run in LINUX but not MacOS (because hash openssl)
#  To be used when running on Cantemo VM - /opt/cantemo/python/bin/python
#::***************************************************************************************************************************

# Set some parameters
import subprocess
import os
import time
import sys
import shutil
from datetime import datetime

watch = sys.argv[1]
destination = sys.argv[2]
files1 = os.listdir(watch)

# print(files1)

while True:
    currentTimeStamp = datetime.now()
    timeStampString = currentTimeStamp.strftime("%Y/%m/%d %H:%M:%S")
    print(f"{timeStampString} - Checking Watch Folder - {watch}")
    time.sleep(30)
    files2 = os.listdir(watch)
    # print(files2)
    # see if there are new files added
    new = [f for f in files2 if all([not f in files1, f.endswith(".jpg")])]
    # if so:
    for f in new:
        # combine paths and file
        trg = os.path.join(destination, f)
        currentTimeStamp = datetime.now()
        timeStampString = currentTimeStamp.strftime("%Y/%m/%d %H:%M:%S")
        print(f"{timeStampString} - New File to Move Found - {trg}")
        time.sleep(5)
        # move the file to destination
        shutil.move(os.path.join(watch, f), trg)
        # log to console
        currentTimeStamp = datetime.now()
        timeStampString = currentTimeStamp.strftime("%Y/%m/%d %H:%M:%S")
        print(f"{timeStampString} - Move to Ingest Watch Folder COMPLETED")
    files1 = files2
