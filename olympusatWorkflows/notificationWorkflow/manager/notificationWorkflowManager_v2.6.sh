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
	# Get the current minute in 24-hour format
	currentMinute=$(date +%M)

	echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflowManager) - Script Triggered - Checking Current Minute [$currentMinute]" >> "$logfile"

	if [ "$currentMinute" -lt 30 ];
	then
		sleepTime=$(( (30 - currentMinute) * 60 ))
		sleepTimeMinutes=$(( sleepTime / 60 ))
		echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflowManager) - Current Minute is less than 30 - waiting [$sleepTime] seconds or [$sleepTimeMinutes] minutes"
		echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflowManager) - Current Minute is less than 30 - waiting [$sleepTime] seconds or [$sleepTimeMinutes] minutes" >> "$logfile"
		sleep $sleepTime
	#elif [ "$currentMinute" -ge 46 ];
	else
		if [ "$currentMinute" -ge 46 ];
		then
			sleepTime=$(( (60 - currentMinute + 30) * 60 ))
			sleepTimeMinutes=$(( sleepTime / 60 ))
			echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflowManager) - Current Minute is more than 46 - waiting [$sleepTime] seconds or [$sleepTimeMinutes] minutes"
			echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflowManager) - Current Minute is more than 46 - waiting [$sleepTime] seconds or [$sleepTimeMinutes] minutes" >> "$logfile"
			sleep $sleepTime
		#elif [ "$currentMinute" -ge 30 ] && [ "$currentMinute" -lt 46 ];
		else
			if [ "$currentMinute" -ge 30 ] && [ "$currentMinute" -lt 46 ];
			then
				echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflowManager) - Current Minute is between 30 & 45 - Continuing with process"
				echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflowManager) - Current Minute is between 30 & 45 - Continuing with process" >> "$logfile"

				#--------------------------------------------------
				# Get the current hour in 24-hour format
				currentHour=$(date +%H)

				echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflowManager) - Script Triggered - Checking Current Hour [$currentHour]" >> "$logfile"

				# Check if the current hour is between 23 (11pm) and 23 (11:59pm)
				if [ "$currentHour" -ge 23 ] && [ "$currentHour" -lt 24 ];
				then
					# Current hour is between 23 & 24 - trigger script to send email(s)
					echo "$(date +%Y/%m/%d_%H:%M:%S) - Current Hour IS between 23 (11pm) & 24 (11:59pm) - Trigger Send Email Script"
					echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflowManager) - Current Hour IS between 23 (11pm) & 24 (11:59pm) - Trigger Send Email Script" >> "$logfile"

					# Trigger Send Email for newItem Workflow
					bash -c "sudo /opt/olympusat/scriptsActive/notificationWorkflow-sendEmailWithReport_v2.4.sh newItem > /dev/null 2>&1 &"

					# Trigger Send Email for originalContentQCPending Workflow
					bash -c "sudo /opt/olympusat/scriptsActive/notificationWorkflow-sendEmailWithReport_v2.4.sh originalContentQCPending > /dev/null 2>&1 &"

					# Trigger Send Email for finalQCPending Workflow
					bash -c "sudo /opt/olympusat/scriptsActive/notificationWorkflow-sendEmailWithReport_v2.4.sh finalQCPending > /dev/null 2>&1 &"

					# Trigger Send Email for finalQCPending Workflow
					bash -c "sudo /opt/olympusat/scriptsActive/notificationWorkflow-sendEmailWithReport_v2.4.sh markedToBeDeleted > /dev/null 2>&1 &"
					
					# Trigger Send Email for rtcMexicoQcPending Workflow
					bash -c "sudo /opt/olympusat/scriptsActive/notificationWorkflow-sendEmailWithReport_v2.4.sh rtcReviewPending > /dev/null 2>&1 &"
					
					# Trigger Send Email for rtcMexicoQc Workflow
					bash -c "sudo /opt/olympusat/scriptsActive/notificationWorkflow-sendEmailWithReport_v2.4.sh rtcReviewCompleted > /dev/null 2>&1 &"
					
					currentDay=$(date +'%A')

					echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflowManager) - Check Current Day value - [$currentDay]" >> "$logfile"

					if [[ "$currentDay" == "Friday" ]];
					then
						echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflowManager) - Current Day is Friday - continue with triggering Weekly Report Email" >> "$logfile"
						# Trigger Send Email for contentMissingMetadata Workflow
						bash -c "sudo /opt/olympusat/scriptsActive/notificationWorkflow-addToWeeklyReport_v1.2.sh contentMissingMetadata > /dev/null 2>&1 &"
					else
						echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflowManager) - Current Day is NOT Friday - do nothing" >> "$logfile"
					fi

					sleep $checkInterval
				else
					# Current hour is NOT between 23 & 24 - sleep 1 hr & trigger script again
					echo "$(date +%Y/%m/%d_%H:%M:%S) - Current Hour is NOT between 23 (11pm) & 24 (11:59pm) - Sleep 1 hour and trigger script again"
					echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflowManager) - Current Hour is NOT between 23 (11pm) & 24 (11:59pm) - Sleep 1 hour and trigger script again" >> "$logfile"
					# Trigger Send Email for rtcMexicoQc Workflow
					bash -c "sudo /opt/olympusat/scriptsActive/notificationWorkflow-sendEmailWithReport_v2.5.sh prepareForReload > /dev/null 2>&1 &"
					echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflowManager) - Triggered PrepareForReload Notification" >> "$logfile"

					sleep $checkInterval
				fi
				#--------------------------------------------------
			fi
		fi
	fi
done

exit 0