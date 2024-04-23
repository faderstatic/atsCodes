#!/opt/cantemo/python/bin/python

# This application maintains archive queue and execute archive jobs for S3 Glacier for the following account
#	customer-id 500844647317
#	vault-name olympusatMamGlacier
# PREREQUISITE: This script must receive item ID as an argument and source file location.
# 	Usage: glacierQueue.py [script to execute - full path] [folder location of queue]
#                                 [folder location items being worked on] [log file name prefix] [queue limit]
# Note:
#   Files in queue folder are named with item ID's from Cantemo - empty file content.

# System requirements: This script will only run in LINUX but not MacOS (because hash openssl)
#                      It calls glacierMultiPartV3.sh and referenced libraries

#------------------------------
# Set some parameters
import os
import glob
import sys
import datetime
import time
import subprocess

executionDate = datetime.date.today()
scriptToExecute = sys.argv[1]
queueFolder = sys.argv[2]
activeFolder = sys.argv[3]
logFilePrefix = sys.argv[4]
concurrentLimit = int(sys.argv[5])
logFile = open(f"/opt/olympusat/logs/{logFilePrefix}-{executionDate}.log", 'a')
iCounter = 0
queueCount = 0
lastQueueCount = 0
pendingJobCount = 0
queueListEmpty = "false"
#------------------------------

#------------------------------
# Let's start with some logging
executionTime = datetime.datetime.now().strftime("%H:%M:%S")
logFile.write(f"{executionTime} (glacierQueue) - Start processing queue for {scriptToExecute}\n")
#------------------------------

#------------------------------
# Read the queue files into a variable
while ( queueListEmpty in "false" ):
    queuedFileList = filter(os.path.isfile, glob.glob(queueFolder + "/*"))
    queuedFileList = sorted(queuedFileList, key=os.path.getctime, reverse=True)
    for fileListItem in queuedFileList:
        justFileName=os.path.basename(fileListItem)
        # floatCreationTime = os.path.getctime(fileListItem)
        # timestampString = datetime.datetime.fromtimestamp(floatCreationTime).strftime("%H:%M:%S")
        # print(timestampString, ' -->', fileListItem)
        activeList = filter(os.path.isfile, glob.glob(activeFolder + "/*"))
        activeList = sorted(activeList, key=os.path.getctime)
        queueCount = len(activeList)
        #------------------------------
        while ( queueCount == concurrentLimit ):
            time.sleep(600)
            activeList = filter(os.path.isfile, glob.glob(activeFolder + "/*"))
            activeList = sorted(activeList, key=os.path.getctime)
            queueCount = len(activeList)
        # Log item being processed
        executionTime = datetime.datetime.now().strftime("%H:%M:%S")
        logFile.write(f"{executionTime} (glacierQueue) - Start archiving process for {fileListItem}\n")
        #------------------------------
        # Start action
        logFile.write("++++++++++ THIS WILL BE FILLED WITH ARCHIVAL/RETRIEVAL PROCESS ++++++++++\n")
        shellCommandArguments = f"/opt/olympusat/scriptsActive/glacierMultipartV4.sh {fileListItem} {activeFolder}"
        subprocess.run(['sh', shellCommandArguments], capture_output=True)
        destinationFile=f"{activeFolder}/{justFileName}"
        print(destinationFile)
        os.rename(fileListItem, destinationFile)
        queueCount+=1
        # Wait until action queue becomes available
        #------------------------------
    queuedFileList = filter(os.path.isfile, glob.glob(queueFolder + "/*"))
    queuedFileList = sorted(queuedFileList, key=os.path.getctime, reverse=True)
    pendingJobCount = len(queuedFileList)
    if ( pendingJobCount == 0 ):
        queueListEmpty = "true"
    #------------------------------

logFile.close()
