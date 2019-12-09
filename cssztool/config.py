import os
import sys
import platform
import time
import datetime
import shutil
import argparse
import hashlib
from decimal import Decimal

DICT_CONFIG = {}
F_CONFIG = "cssztool.conf"
class Config:
	def __init__(self):
		self.conf = self.read_conf(F_CONFIG)

	def get_conf(self):
		return self.conf

	def conf(self, args):
		model = "@EXE @CONFIG"
		if (OS_SYSTEM == "Windows"):
			model = model.replace("@EXE", "notepad.exe").replace("@CONFIG", F_CONFIG)
		else:
			model = model.replace("@EXE", "vim").replace("@CONFIG", F_CONFIG)
		print(model)
		os.system(model)
	
		return
	
	def read_conf(self, f_conf):
		with open(f_conf, "r") as cfr:
			lines = cfr.readlines()
			for line in lines:
				# Skip comment lines
				if(line.startswith("#") or not len(line.strip())):
					continue
	
				kv = line.split("=")
				DICT_CONFIG[kv[0].strip()] = kv[1].strip()
		print(DICT_CONFIG)	
		return DICT_CONFIG
