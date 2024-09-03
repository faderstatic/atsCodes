#!/bin/bash

#::***************************************************************************************************************************
#::This shell script will get metadata from Original Master Episode & copy to other Master Types (textless, dubbed, etc)
#::Engineers: Ryan Sims & Tang Kanjanapitak
#::Client: Olympusat
#::Updated: 05/14/2024
#::Rev A: 
#::System requirements: This script will run in LINUX & MacOS
#::***************************************************************************************************************************

saveIFS=$IFS
IFS=$(echo -e "\n\b")

<<<<<<< HEAD
eventUrl=$1
maxPresets=$2
destinationFolder=$3

export apiKey="FbABGpvsgGDkTKUZchLv"
# export authExpire=$(date -d "+5 minutes" +"%s")
export authUser="admin"
=======
export apiUserKey="FbABGpvsgGDkTKUZchLv"
export authExpire=$(date -v +7d +"%s")
export md5ForApiUserKey=$(echo -n "$apiUserKey" | md5)
>>>>>>> a97eefad0924a2c5a1f08e7c872cc18e988510ed

apiKeyMd5=$(echo $apiKey | md5sum | awk '{print $1}')
apiKeyMd5Dec=$((16#$apiKeyMd5))

for i in {1..10}
do
    authExpire=$(date -d "+2 seconds" +"%s")
    apiParameter="/"$eventUrl"/"$i$authUser$apiKey$authExpire
    apiParameterMd5=$(echo $apiParameter | md5sum | awk '{print $1}')
    apiParameterMd5CAP=$(echo "$apiParameterMd5" | tr '[:lower:]' '[:upper:]')
    apiParameterMd5=$$(($apiParameterMd5CAP))
    apiParameterMd5Dec=$(echo "ibase=16;apiParameter)
    finalAuthenticationDec=$(($apiKeyMd5Dec+$apiParameterMd5Dec))
    printf -v apiParameterMd5Comp "%x" $apiParameterMd5Dec
    echo $apiParameterMd5Comp" compares to original "$apiParameterMd5
    # printf -v finalAuthentication "%x" $finalAuthenticationDec
    # printf -v finalAuthentication "%x\n" $((16#$apiParameterMd5 + 16#$apiKeyMd5))
    finalAuthentication=$(echo "obase=16;ibase=16;$apiParameter+$apiKey" | bc)
    echo $finalAuthentication
    # curl -s -o preset_$i.xml -f http://172.16.1.120/api/$eventUrl/$i.xml?clean=true
done

IFS=$saveIFS
