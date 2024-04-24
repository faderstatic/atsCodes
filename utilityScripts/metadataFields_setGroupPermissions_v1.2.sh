#!/bin/bash

saveIFS=$IFS
IFS=$(echo -e "\n\b\015")

inputFile=$1

columnCounts=3
rowCounter=1

#export columnCounts=$(/usr/bin/head -n 1 "$1" | awk '{print NF}')
export rowCounts=$(cat "$inputFile" | wc -l)
rowCounts=$(($rowCounts + 1))
echo "Row Counts: $rowCounts"
echo "" >> $inputFile

while read line;
do
    if [ "$line" != "" ];
    then
        echo $line
        # Reading the CSV Values
        fieldName=$(echo $line | awk -F "," '{print $1}')
        groupName=$(echo $line | awk -F "," '{print $2}')
        permission=$(echo $line | awk -F "," '{print $3}')

        echo "Field Name - $fieldName"
        echo "Group Name - $groupName"
        echo "Permission - $permission"

        bodyData=$(echo "<MetadataFieldAccessControlDocument xmlns=\"http://xml.vidispine.com/schema/vidispine\"><group>$groupName</group><permission>$permission</permission></MetadataFieldAccessControlDocument>")
        export url="http://10.1.1.34:8080/API/metadata-field/$fieldName/access"
        echo "URL - $url"
        echo "Body Data - $bodyData"
        curl --location --request POST $url --header 'Content-Type: application/xml' --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=xZqBrKBPBOUANsWFnMC3aF90S52Ip3tgXdUHwWZvhNnu9aLl9j4rdrxRhV9nSQx9' --data "$bodyData"

        sleep 3
    fi

rowCounter=$(($rowCounter + 1))
done < "$inputFile"

IFS=$saveIFS

exit 0