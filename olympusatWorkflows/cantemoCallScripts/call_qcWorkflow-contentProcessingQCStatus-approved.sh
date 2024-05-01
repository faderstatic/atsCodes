#!/bin/bash
echo "start"
bash -c "sudo /opt/olympusat/scriptsActive/qcWorkflow-contentProcessingQCStatus_v3.0.sh $portal_itemId $portal_user approved > /dev/null 2>&1"
echo "bye"

