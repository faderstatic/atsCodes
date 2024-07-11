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
export checkInterval=3600
export myDate=$(date "+%Y-%m-%d")
#--------------------------------------------------
noProcessExit="false"
logfile="/opt/olympusat/logs/notificationWorkflow-$myDate.log"
#--------------------------------------------------

while [ "$noProcessExit" == "false" ]
do
	#--------------------------------------------------
	# Check to see if we need to start a new log file
	newDate=$(date "+%Y-%m-%d")
	if [ "$myDate" != "$newDate" ];
	then
		logfile="/opt/olympusat/logs/notificationWorkflow-$newDate.log"
	fi
	#--------------------------------------------------

	#--------------------------------------------------
	# Get the current hour in 24-hour format
	currentHour=$(date +%H)

	echo "$(date +%Y/%m/%d_%H:%M:%S) - Script Triggered - Checking Current Hour [$currentHour]"
	echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflowManager) - Script Triggered - Checking Current Hour [$currentHour]" >> "$logfile"

	# Check if the current hour is between 23 (11pm) and 23 (11:59pm)
	if [ "$currentHour" -ge 23 ] && [ "$currentHour" -lt 24 ];
	then
		# Current hour is between 23 & 24 - trigger script to send email(s)
		echo "$(date +%Y/%m/%d_%H:%M:%S) - Current Hour IS between 23 (11pm) & 24 (11:59pm) - Trigger Send Email Script"
		echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflowManager) - Current Hour IS between 23 (11pm) & 24 (11:59pm) - Trigger Send Email Script" >> "$logfile"

		# Trigger Send Email for newItem Workflow
		bash -c "sudo /opt/olympusat/scriptsActive/notificationWorkflow-sendEmailWithReport_v2.0.sh newItem > /dev/null 2>&1 &"

		# Trigger Send Email for originalContentQCPending Workflow
		bash -c "sudo /opt/olympusat/scriptsActive/notificationWorkflow-sendEmailWithReport_v2.0.sh originalContentQCPending > /dev/null 2>&1 &"

		# Trigger Send Email for finalQCPending Workflow
		bash -c "sudo /opt/olympusat/scriptsActive/notificationWorkflow-sendEmailWithReport_v2.0.sh finalQCPending > /dev/null 2>&1 &"
		
		currentDay=$(date +'%A')

		echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflowManager) - Check Current Day value - [$currentDay]" >> "$logfile"

		if [[ "$currentDay" == "Friday" ]];
		then
			echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflowManager) - Current Day is Friday - continue with triggering Weekly Report Email" >> "$logfile"
			# Trigger Send Email for finalQCPending Workflow
			bash -c "sudo /opt/olympusat/scriptsActive/notificationWorkflow-addToWeeklyReport_v1.1.sh contentMissingMetadata > /dev/null 2>&1 &"
		else
			echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflowManager) - Current Day is NOT Friday - do nothing" >> "$logfile"
		fi

		sleep $checkInterval
	else
		# Current hour is NOT between 23 & 24 - sleep 1 hr & trigger script again
		echo "$(date +%Y/%m/%d_%H:%M:%S) - Current Hour is NOT between 23 (11pm) & 24 (11:59pm) - Sleep 1 hour and trigger script again"
		echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflowManager) - Current Hour is NOT between 23 (11pm) & 24 (11:59pm) - Sleep 1 hour and trigger script again" >> "$logfile"

		sleep $checkInterval
	fi
	#--------------------------------------------------
done

exit 0