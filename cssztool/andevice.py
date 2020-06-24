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
from conf import Conf

class Andevice:
	def __init__(self):
		pass

	def adb_init(self, op):
		os.system("adb wait-for-device root")
		os.system("adb wait-for-device remount")
		os.system("adb wait-for-device")
		os.system("adb disable-verity")
		os.system("adb shell \"setenforce 0\"")
		os.system("adb shell \"setprop sys.usb.config diag,adb\"")

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
		model_list = []
		model_shell = "adb shell \"@CMDSET\""
		model = "find @DIRECTORY @F_ARGS | grep @G_ARGS @PATTEN | xargs ls -l"
	
		model_t = model.replace("@DIRECTORY", self.conf["capiv2 directory device"])
		model_t = model_t.replace("@F_ARGS", "-type f").replace("@G_ARGS", "-i").replace("@PATTEN", "cirrus")
		model_list.append(model_t)

		model_t = model.replace("@DIRECTORY", self.conf["tool directory device"])
		model_t = model_t.replace("@F_ARGS", "-type f").replace("@G_ARGS", "").replace("@PATTEN", "cirrus")
		model_list.append(model_t)
	
		model_t = model.replace("@DIRECTORY", self.conf["wmfw directory device"])
		model_t = model_t.replace("@F_ARGS", "-type f").replace("@G_ARGS", "-i").replace("@PATTEN", "cs35")
		model_list.append(model_t)
	
		model = "find @DIRECTORY @F_ARGS | grep @G_ARGS @PATTEN"
		model_t = model.replace("@DIRECTORY", self.conf["regmap directory device"])
		model_t = model_t.replace("@F_ARGS", "-type d").replace("@G_ARGS", "-iE").replace("@PATTEN", "\'i2c|spi\'")
		model_list.append(model_t)

		# Combin the command lines to one
		model_combin = ";".join(model_list)
		model_shell = model_shell.replace("@CMDSET", model_combin)

		os.system(model_shell)

		return
	
	def device_md5sum(self, op):
		model_list = []
		model_shell = "adb shell \"@CMDSET\""
		model = "find @DIRECTORY @F_ARGS | grep @G_ARGS @PATTEN | xargs md5sum"

		model_t = model.replace("@DIRECTORY", self.conf["capiv2 directory device"])
		model_t = model_t.replace("@F_ARGS", "-type f").replace("@G_ARGS", "-i").replace("@PATTEN", "cirrus")
		model_list.append(model_t)
	
		model_t = model.replace("@DIRECTORY", self.conf["tool directory device"])
		model_t = model_t.replace("@F_ARGS", "-type f").replace("@G_ARGS", "-i").replace("@PATTEN", "cirrus")
		model_list.append(model_t)
		
		model_t = model.replace("@DIRECTORY", self.conf["wmfw directory device"])
		model_t = model_t.replace("@F_ARGS", "-type f").replace("@G_ARGS", "-i").replace("@PATTEN", "cs35")
		model_list.append(model_t)
		
		# Combin the command lines to one
		model_combin = ";".join(model_list)
		model_shell = model_shell.replace("@CMDSET", model_combin)

		os.system(model_shell)
		return
	
	def push(self, op):
		type_t = op[0]
		if (platform.system() == "Windows"):
			files = Tool.windows_dir(op[1])
		else:
			files = op[1]

		if (type_t == "music"):
			model = "adb push @SRC @DEST"
			dir_music = "C:/work/music/Music/cs-test-music/"
			if (platform.system() == "Windows"):
				files = Tool.windows_dir(dir_music)

			model = model.replace("@SRC", dir_music).replace("@DEST", "/sdcard/Music/")
			print(model)
			os.system(model)
		return
		
