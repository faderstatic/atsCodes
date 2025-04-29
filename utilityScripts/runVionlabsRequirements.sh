#!/bin/bash

# Define the full path to your script and a unique name pattern
SCRIPT_PATH="/path/to/your_script.py"
LOG_PATH="/path/to/your_log.log"
PROCESS_NAME="your_script.py"

# Check if the script is running
if ! pgrep -f "$PROCESS_NAME" > /dev/null
then
    echo "$(date): Script not running. Starting..." >> $LOG_PATH
    nohup python3 $SCRIPT_PATH >> $LOG_PATH 2>&1 &
else
    echo "$(date): Script is already running." >> $LOG_PATH
fi
