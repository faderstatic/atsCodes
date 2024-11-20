# /opt/cantemo/python/bin/python
# /usr/local/bin/python3
#!/usr/bin/python3

# This application ingests metadata from an XML API response into Cantemo
# PREREQUISITE: -none-
# 	Usage: s3DownloadRequest.py [Cantemo ItemID]

#------------------------------
# Libraries
import os
import os.path
import glob
import sys
# import datetime
from datetime import datetime, timezone
import hashlib
import hmac
import time
import subprocess
import xml.dom.minidom
import xml.etree.ElementTree as ET
import requests
import json
import smtplib
from email.message import EmailMessage
from requests.exceptions import HTTPError
#------------------------------

#------------------------------
# Internal Functions

def calculate_amz_content_sha256(cacsPayload):
    if isinstance(cacsPayload, str):
        cacsPayload = cacsPayload.encode('utf-8')
    # Compute the SHA-256 hash of the payload
    sha256Hash = hashlib.sha256(cacsPayload).hexdigest()
    return sha256Hash

def signString(sskey, ssmsg):
    return hmac.new(sskey, ssmsg.encode('utf-8'), hashlib.sha256).digest()

#------------------------------

try:
    itemId = sys.argv[1]
    awsCustomerId = "500844647317"
    awsBucketName="olympusatdeeparch"
    awsAccessKey = "AKIAXJHFK2OK2BYMFAGT"
    awsSecretKey = "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"
    awsHashAlgorithm = "AWS4-HMAC-SHA256"
    awsRegion = "us-east-1"
    awsService = "s3"
    apiMethod = "GET"
    apiUri = "/"
    # apiQueryString = f"?list-type=2&prefix={itemId}&delimiter=/"
    apiQueryString = ""
    currentTime = datetime.now(timezone.utc)
    awsDateTime = currentTime.strftime('%Y%m%dT%H%M%SZ')
    awsDate = awsDateTime[:8]
    #------------------------------
    # Request S3 Deep Archive Restore
    # url = "olympusatdeeparch.s3.us-east-1.amazonaws.com/test1600KBFile?restore"
    # payload = "<RestoreRequest>\n    <Days>1</Days>\n    <GlacierJobParameters>\n        <Tier>Bulk</Tier>\n    </GlacierJobParameters>\n</RestoreRequest>"
    # s3ObjectRequestUrl = f"https://{awsBucketName}.s3.us-east-1.amazonaws.com/?list-type=2&prefix={itemId}&delimiter=/"
    payload=""
    xAmzContentSha256 = calculate_amz_content_sha256(payload)
    '''
    headers = {
        'host': f'{awsBucketName}.s3.us-east-1.amazonaws.com',
        'X-Amz-Content-Sha256': f'{xAmzContentSha256}',
        'X-Amz-Date': f'{awsDateTime}',
        'Content-Type': 'application/xml'
    }
    '''
    headers = {
        'host': f'{awsBucketName}.s3.us-east-1.amazonaws.com',
        'X-Amz-Date': f'{awsDateTime}',
        'X-Amz-Content-Sha256': f'{xAmzContentSha256}'
    }

    #------------------------------
    # Create canonical request
    canonicalHeaders = "".join(f"{k}:{v}\n" for k, v in headers.items())
    signedHeaders = ";".join(headers.keys())
    canonicalRequest = f"{apiMethod}\n{apiUri}\n{apiQueryString}\n{canonicalHeaders}\n{signedHeaders}\n{xAmzContentSha256}"
    #------------------------------

    #------------------------------
    # Create string to sign
    credentialScope = f"{awsDate}/{awsRegion}/{awsService}/aws4_request"
    hashedCanonicalRequest = hashlib.sha256(canonicalRequest.encode('utf-8')).hexdigest()
    stringToSign = f"{awsHashAlgorithm}\n{awsDateTime}\n{credentialScope}\n{hashedCanonicalRequest}"
    #------------------------------

    #------------------------------
    # Generate signing key
    keyDate = signString(("AWS4" + awsSecretKey).encode('utf-8'), awsDate)
    keyRegion = signString(keyDate, awsRegion)
    keyService = signString(keyRegion, awsService)
    signingKey = signString(keyService, "aws4_request")
    # print(f"Signing key string: {signingKey}\nString to Sign: {stringToSign}")
    signatureString = hmac.new(signingKey, stringToSign.encode('utf-8'), hashlib.sha256).hexdigest()
    # print(f"Signature String: {signatureString}")

    #------------------------------
    # Construct headers
    authorizationHeader = (
        f"{awsHashAlgorithm} "
        f"Credential={awsAccessKey}/{credentialScope}, "
        f"SignedHeaders={signedHeaders}, "
        f"Signature={signatureString}"
    )
    print(f"My authorization header is {authorizationHeader}\n")
    headers["Authorization"] = authorizationHeader
    print(f"My header is:\n{headers}\n")
    #------------------------------
    s3ObjectRequestUrl = f"https://{awsBucketName}.{awsService}.{awsRegion}.amazonaws.com{apiUri}{apiQueryString}"
    response = requests.request(apiMethod, s3ObjectRequestUrl, headers=headers, data=payload)
    print(response.text)
    #------------------------------


except HTTPError as http_err:
    print(f'HTTP error occurred: {http_err}')
except Exception as err:
    print(f'Other error occurred: {err}')