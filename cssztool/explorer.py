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
from andevice import Andevice
from tool import Tool
from conf import Conf

DIR_DICT = {
       "doc"    : "C:/work/doc/",
       "cust"   : "C:/work/customer/",
       "src"    : "C:/work/src/",
       "thub"    : "C:/work/src/aus/linux",
       "work"   : "C:/work/",
       "capiv2" : "C:/work/src/aus/amps/playback/CSPL/firmware/workspace_eclipse_for_QCOM_generic/",
       "hvim"   : "C:/cygwin64/home/hhuang/hvim/",
       "chome"  : "C:/cygwin64/home/hhuang/",
       "meizu"  : "C:/work/customer/",
       "xiaomi" : "C:/work/customer/",
       "vivo"   : "C:/work/customer/",
       "huawei" : "C:/work/customer/",
       "datasheet":"C:/work/doc/datasheet/",
       "expense": "C:/work/doc/expense/",
       "train"  : "C:/work/doc/train/"
}
CONFIG="common_dir.json"
class Explorer:
	def __init__(self):
		self.dict = {}
		path = Tool.get_root_path(CONFIG)
		print(path)
		if (os.path.exists(path)==True):
		    self.dict = Conf.read(path)
		else:
		    self.dict = DIR_DICT
		return
	def open(self, args):
		model = "@EXE @PATH"
		print(platform.system())
		if(platform.system()=="Windows"):
			path = self.dict[args].replace("/","\\")
			model = model.replace("@EXE", "explorer").replace("@PATH", path)
			subprocess.Popen(model)
		else:
			model = "cd @PATH ; @EXE . ; cd -"
			model = model.replace("@EXE", "explorer").replace("@PATH", self.dict[args])
			os.system(model)
		print(model)
