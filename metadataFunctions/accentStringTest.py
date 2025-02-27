#------------------------------
# Libraries
import os
import os.path
import glob
import sys
import datetime
import time
import string
import subprocess
import xml.dom.minidom
import xml.etree.ElementTree as ET
import requests
import json
import smtplib
import urllib.request
from email.message import EmailMessage
from requests.exceptions import HTTPError
from urllib.parse import quote_plus
#------------------------------

url = "http://10.1.1.34:8080/API/item/OLY-11696/metadata/"

payload = f"""
<MetadataDocument xmlns=\"http://xml.vidispine.com/schema/vidispine\"> 
  <timespan start=\"-INF\" end=\"+INF\">
    <field>
      <name>oly_omdbCombinedResult</name>
      <value>test 1</value>
    </field>
    <field>
      <name>oly_tmdbCombinedResult</name>
      <value>Cornelio Reyna, Lola Beltrán, Roberto 'Flaco' Guzmán
Overview: Una interesante producción, matizada por la tragi-comedia en la que un hombre rescata al dueño de una taquerÍa, quien se encuentra en una situación de inminente riesgo.</value>
    </field>
  </timespan>
</MetadataDocument>"""
headers = {
  'Authorization': 'Basic YWRtaW46MTBsbXBAc0B0',
  'Cookie': 'csrftoken=HFOqrbk9cGt3qnc6WBIxWPjvCFX0udBdbJnzCv9jECumOjfyG7SS2lgVbFcaHBCc',
  'Accept': 'application/xml',
  'Content-Type': 'application/xml; charset=utf-8'
}
payloadEncoded = payload.encode('utf-8')
response = requests.request("PUT", url, headers=headers, data=payloadEncoded)

print(response.text)

#------------------------------