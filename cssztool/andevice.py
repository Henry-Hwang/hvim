import os
import sys
import platform
import time
import datetime
import shutil
import argparse
import hashlib
from decimal import Decimal
from tool import Tool

class Andevice:
	def __init__(self, conf):
                self.conf = conf

		
	def adb_init(self, op):
		os.system("adb wait-for-device root")
		os.system("adb wait-for-device remount")
		os.system("adb wait-for-device")
		return
	
	# Connection look like this:
	# List of devices attached
	# Z91QAEVJUTQX6   device
	def adb_check_connection(self):
		string = os.popen("adb devices").read()
		info = string.split("\n")
		if (len(info) < 2):
			return False
		info = info[1].split()
		if(len(info) != 2):
			return False
		if(info[1].strip() != "device"):
			return False
		
		return True
	
	def list(self, op):
		model = "adb shell \"find @DIRECTORY @F_ARGS | grep @G_ARGS @PATTEN | xargs ls -l\""
	
		model_t = model.replace("@DIRECTORY", self.conf["capiv2 directory device"])
		model_t = model_t.replace("@F_ARGS", "-type f").replace("@G_ARGS", "-i").replace("@PATTEN", "cirrus")
		os.system(model_t)
	
		model_t = model.replace("@DIRECTORY", self.conf["tool directory device"])
		model_t = model_t.replace("@F_ARGS", "-type f").replace("@G_ARGS", "").replace("@PATTEN", "cirrus")
		os.system(model_t)
	
		model_t = model.replace("@DIRECTORY", self.conf["wmfw directory device"])
		model_t = model_t.replace("@F_ARGS", "-type f").replace("@G_ARGS", "-i").replace("@PATTEN", "cs35")
		os.system(model_t)
	
		model = "adb shell \"find @DIRECTORY @F_ARGS | grep @G_ARGS @PATTEN\""
		model_t = model.replace("@DIRECTORY", self.conf["regmap directory device"])
		model_t = model_t.replace("@F_ARGS", "-type d").replace("@G_ARGS", "-iE").replace("@PATTEN", "\'i2c|spi\'")
		os.system(model_t)
	
		return
	
	def device_md5sum(self, op):
		model = "adb shell \"find @DIRECTORY @F_ARGS | grep @G_ARGS @PATTEN | xargs md5sum\""
		model_t = model.replace("@DIRECTORY", self.conf["capiv2 directory device"])
		model_t = model_t.replace("@F_ARGS", "-type f").replace("@G_ARGS", "-i").replace("@PATTEN", "cirrus")
		os.system(model_t)
	
		model_t = model.replace("@DIRECTORY", self.conf["tool directory device"])
		model_t = model_t.replace("@F_ARGS", "-type f").replace("@G_ARGS", "-i").replace("@PATTEN", "cirrus")
		os.system(model_t)
		
		model_t = model.replace("@DIRECTORY", self.conf["wmfw directory device"])
		model_t = model_t.replace("@F_ARGS", "-type f").replace("@G_ARGS", "-i").replace("@PATTEN", "cs35")
		os.system(model_t)
		
		return
	
	def push_device(self, args):
		model = "adb push @SOURCE @DEST"
		model_md5 = "adb shell \"md5sum @TARGET\""
		f_file = args[1]
		if (os.path.exists(f_file.strip())==False):
		    print("file on exist: " + args[1])
		    return
	
		Tool.md5sum(f_file)
		if(args[0]=="capi"):
			[fname,fename]=os.path.splitext(f_file)
			if (fename != ".so"):
				print("ERROR: Capiv2 lib shoud has extend '.so' : " + f_file)
				return
			#push to device
			model = model.replace("@SOURCE", f_file).replace("@DEST", self.conf["capiv2 lib device"])
			os.system(model)
			
			# md5sum, show both for comparing
			model_md5 = model_md5.repace("@TARGET", self.conf["capiv2 lib device"])
		os.system(model_md5)
		Tool.md5sum(f_file)
	
		return
