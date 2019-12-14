#!/usr/bin/python3
import os
import sys
import platform
import time
import datetime
import shutil
import argparse
import hashlib
from decimal import Decimal
import subprocess
from amps import Amps
from playback import Playback
from conf import Conf
from andevice import Andevice
from tool import Tool

CTAG_DICT = {
       "kernel" : ["sound",
                   "include",
                   "drivers/misc",
                   "drivers/base",
                   "drivers/mfd",
                   ],
       "all" : ["."],
}
class Ctags:
	def __init__(self):
		self.conf = CTAG_DICT
		pass
	def create_ctags(self, args):
		model = "ctags -R @DIRS"
		paths = " ".join(self.conf[args])
		model = model.replace("@DIRS", paths)
		print(model)
		os.system(model)
		os.system("ls -l tags")
