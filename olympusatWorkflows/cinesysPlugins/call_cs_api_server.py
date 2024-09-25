#!/opt/cantemo/python/bin/python
import sys
import logging
import argparse
import os
import time
from requests.exceptions import HTTPError

src_directory = os.path.dirname(
    os.path.dirname(os.path.dirname(os.path.realpath(__file__)))
)
if not src_directory in sys.path:
    sys.path.append(src_directory)

from cs_plugin_service.api_server.api_server import ApiServer


log = logging.getLogger("cinesys.plugin.cs_api_server.scripts.call_cs_api_server")


parser = argparse.ArgumentParser()
parser.add_argument("path")
parser.add_argument("--item_id", default="")

args = parser.parse_args()

item_id = args.item_id
if item_id == "":
    item_id = os.environ.get("portal_itemId")

api = ApiServer()

retry_count = 3
do_retry = True
wait = 1
while do_retry:
    do_retry = False
    try:
        path = os.path.join("/", args.path)
        response = api.fetch("POST", path, {"itemId": item_id})
        print("Success")
    except Exception as e:

        if retry_count > 0:
            do_retry = True
            retry_count -= 1
            time.sleep(wait)
            wait *= 2
        else:
            if isinstance(e, HTTPError):
                print("Failed: " + e.response.text)
            else:
                print("Failed: " + str(e))
            exit(1)
