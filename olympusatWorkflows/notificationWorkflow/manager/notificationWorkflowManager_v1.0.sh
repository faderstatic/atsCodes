#!/bin/bash

#::***************************************************************************************************************************
#::This shell script is the "manager" and will run every hour and check if it is after 11pm and if so trigger another script
#::Engineers: Ryan Sims & Tang Kanjanapitak
#::Client: Olympusat
#::Updated: 07/09/2024
#::Rev A: 
#::System requirements: This script will run in LINUX & MacOS
#::***************************************************************************************************************************

saveIFS=$IFS
IFS=$(echo -e "\n\b")

#--------------------------------------------------
# Set some parameters
export checkInterval=1800
export mydate=$(date +%Y-%m-%d)
export datetime=$(date +%Y/%m/%d_%H:%M)
logfile="/opt/olympusat/logs/notificationWorkflow-$mydate.log"
#--------------------------------------------------

# Get the current hour in 24-hour format
currentHour=$(date +%H)

echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflowManager) - Script Triggered - Checking Current Hour [$currentHour]" >> "$logfile"

# Check if the current hour is between 23 (11pm) and 23 (11:59pm)
if [ "$currentHour" -ge 23 ] && [ "$currentHour" -lt 24 ];
then
	# Current hour is between 23 & 24 - trigger script to send email(s)
	echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflowManager) - Current Hour IS between 23 (11pm) & 24 (11:59pm) - Trigger Send Email Script" >> "$logfile"

	bash -c "sudo /opt/olympusat/scriptsActive/notificationWorkflow-newItem-sendEmailWithReport_v1.2.sh newItem > /dev/null 2>&1 &"

	sleep 3600
	
	bash -c "sudo /opt/olympusat/scriptsActive/notificationWorkflowManager_v1.0.sh > /dev/null 2>&1 &"
else
	# Current hour is NOT between 23 & 24 - sleep 1 hr & trigger script again
	echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflowManager) - Current Hour is NOT between 23 (11pm) & 24 (11:59pm) - Sleep 1 hour and trigger script again" >> "$logfile"

	sleep 3600

	bash -c "sudo /opt/olympusat/scriptsActive/notificationWorkflowManager_v1.0.sh > /dev/null 2>&1 &"
fi

exit 0