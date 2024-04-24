#!/bin/bash
echo "start"
bash -c "sudo /opt/olympusat/scriptsActive/importRightslineLegacyInfo_v2.0.sh $portal_itemId oly_rightslineItemId /opt/olympusat/resources/RIGHTSLINE_CATALOG-ITEM_DATABASE_2024-04-16_v2.1.csv > /dev/null 2>&1 &"
echo "bye"

