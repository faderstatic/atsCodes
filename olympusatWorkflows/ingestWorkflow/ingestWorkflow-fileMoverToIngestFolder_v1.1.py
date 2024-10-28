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
import logging

watch = sys.argv[1]
destination = sys.argv[2]
files1 = os.listdir(watch)

# Setup the path and filename for the log file
#---------------------------------------------------------
logpath = "/opt/olympusat/logs"
logfilename= f"ingestWorkflow-fileMover-{datetime.now().strftime('%Y-%m-%d')}.log"
logfile = os.path.join(logpath, logfilename)
# Setup logging configuration
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(message)s",
    datefmt="%Y/%m/%d_%H:%M:%S",
    handlers=[
        logging.FileHandler(logfile),
        logging.StreamHandler(sys.stdout)
    ]
)
#---------------------------------------------------------

while True:
    logging.info(f"Checking Watch Folder - {watch}")
    time.sleep(60)
    files2 = os.listdir(watch)
    # See if there are new files added
    new = [f for f in files2 if all([not f in files1, f.endswith(".jpg")])]
    # if so:
    for f in new:
        # Combine paths and file
        trg = os.path.join(destination, f)
        logging.info(f"New File to Move Found - {trg}")
        time.sleep(5)
        # Move the file to destination
        shutil.move(os.path.join(watch, f), trg)
        # Log to console and file
        logging.info(f"Move to Ingest Watch Folder COMPLETED")
    files1 = files2
