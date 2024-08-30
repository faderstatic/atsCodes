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

export apiUserKey="FbABGpvsgGDkTKUZchLv"
export authExpire=$(date -v +7d +"%s")
export md5ForApiUserKey=$(echo -n "$apiUserKey" | md5)

for i in {1..10}
    do
        curl -s -o preset_${i}.xml -f http://172.16.1.120/api/presets/${i}.xml?clean=true
    done

IFS=$saveIFS
