# /opt/cantemo/python/bin/python
#!/usr/bin/python3

import sys
import logging
import argparse
import os
import time
from requests.exceptions import HTTPError

src_directory = os.path.dirname(
    os.path.dirname(os.path.dirname(os.path.realpath(__file__)))
)

print(f"source directory is {src_directory}")

if not src_directory in sys.path:
    sys.path.append(src_directory)

# from cs_plugin_service.api_server.api_server import ApiServer
print(f"post append source directory is {src_directory}")