#! /bin/bash

#--------------------------------------------------
# External funtions to include
#--------------------------------------------------

saveIFS=$IFS
IFS=$(echo -e "\n\b")

#--------------------------------------------------
# Set some parameters
export myDate=$(date "+%Y-%m-%d")
export logArchiveDate=$(date -d "14 day ago" +"%s")
export logTarDate=$(date -d "28 day ago" +"%s")
#--------------------------------------------------
logFolder="/opt/olympusat/logs"
logsArchiveFolder="/opt/olympusat/logs/logsArchive"
moreLogsToTar="false"
# logPattern="glacier-"
#--------------------------------------------------

# echo "$myDate - $logArchiveDate"
#--------------------------------------------------
# Move older log files into an archive folder
mkdir -p "$logsArchiveFolder"
# for logFile in $(find "$logFolder" -name "$logPattern"'*.log');
for logFile in $(find "$logFolder" -type f -name "*.log");
do
    creationDateString=$(stat -c '%w' $logFile | awk '{ print $1 }')
    creationDate=$(date -d "$creationDateString" +"%s")
    if [[ "$creationDate" -lt "$logArchiveDate" ]];
    then
        logBaseName=$(basename "$logFile")
        if [[ ! -z "$logsArchiveFolder/$logBaseName" ]]
        then
            mv "$logFile" "$logsArchiveFolder"
        fi
    fi
done
#--------------------------------------------------

#--------------------------------------------------
# Create a tar gzip of older older log files
tarFolder="/opt/olympusat/logs/logs_$myDate"
mkdir -p "$tarFolder"
for logFile in $(find "$logsArchiveFolder" -type f -name "*.log");
do
    creationDateString=$(stat -c '%w' $logFile | awk '{ print $1 }')
    creationDate=$(date -d "$creationDateString" +"%s")
    if [[ "$creationDate" -lt "$logTarDate" ]];
    then
        mv "$logFile" "$tarFolder"
        moreLogsToTar="true"
    fi
done
if [[ "$moreLogsToTar" == "true" ]];
then
    tarName="/opt/olympusat/logs/logsArchive_$myDate.tar.gz"
    tar -czf "$tarName" "$tarFolder"
    rm -fR "$tarFolder"
fi
#--------------------------------------------------

IFS=$saveIFS