#!/usr/bin/python3

import subprocess
import os
import time
import shutil
from datetime import datetime

source = "/mnt/Analysis_Ingest"
target = "/mnt/media/Vionlabs"
files1 = os.listdir(source)

# print(files1)

while True:
    time.sleep(2)
    files2 = os.listdir(source)
    # print(files2)
    # see if there are new files added
    new = [f for f in files2 if all([not f in files1, f.endswith(".mp4")])]
    # if so:
    for f in new:
        # combine paths and file
        trg = os.path.join(target, f)
        # copy the file to target
        shutil.copy(os.path.join(source, f), trg)
        # and run it
        # subprocess.Popen(["/bin/bash", trg])
        currentTimeStamp = datetime.now()
        timeStampString = currentTimeStamp.strftime("%Y/%m/%d %H:%M:%S")
        print(f"{timeStampString} - Synched {trg}")
    files1 = files2
