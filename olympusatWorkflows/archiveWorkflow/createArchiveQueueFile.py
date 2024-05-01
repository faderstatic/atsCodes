#!/opt/cantemo/python/bin/python

# This application creates archive queue file in a folder determined by the argument
#	customer-id 500844647317
#	vault-name olympusatMamGlacier
# PREREQUISITE: This script must receive item ID as an argument and source file location.
# 	Usage: createArchiveQueueFile.py [folder location of queue] [Cantemo item ID]
#                                    [text to insert into the file, ex. archiveIdAWS]
#                                    [prefix of the log file]
#
# Note:
#   Files in queue folder are named with item ID's from Cantemo - empty file content.
#
# System requirements: This script will only run in LINUX but not MacOS (because hash openssl)
#                      It calls glacierMultiPartV3.sh and referenced libraries

#------------------------------
# Set some parameters
import os
import sys
import datetime
import time

executionDate = datetime.date.today()
queueFolder = "/opt/olympusat/glacierArchive/archiveJobs"
assetItemId = os.environ.get("portal_itemId")
textContent = "no archiveIdAWS"
logFilePrefix = "glacierArchive"
logFile = open(f"/opt/olympusat/logs/{logFilePrefix}-{executionDate}.log", 'a')
archiveQueueFile = open(f"{queueFolder}/{assetItemId}", 'a')

#------------------------------
# Let's start with some logging
executionTime = datetime.datetime.now().strftime("%H:%M:%S")
logFile.write(f"{executionTime} (createArchiveQueue) - Adding archive queue file for {assetItemId}\n")
#------------------------------

#------------------------------
# Creating queue file
archiveQueueFile.write(f"{textContent}")
#------------------------------

logFile.close()
archiveQueueFile.close()