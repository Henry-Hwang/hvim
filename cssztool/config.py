import os
import sys
import platform
import time
import datetime
import shutil
import argparse
import hashlib
from decimal import Decimal
from amp import Amp

F_CONFIG = "cssztool.conf"
DEFAULT_CONFIG = {
	# custommer
	"project name"  : "J2",
	"customer"      : "XIAOMI",

	# capi v2
	"playback version"         : 5,
	"capiv2 directory"         : "/home/hhuang/capiv2/",
	"capiv2 lib directory"     : "/home/hhuang/capiv2/capi_v2_cirrus_cspl/LLVM_Debug/",
	"capiv2 lib"               : "/home/hhuang/capiv2/capi_v2_cirrus_cspl/LLVM_Debug/capi_v2_cirrus_cspl.so",
	"source tuning directory"  : "/home/hhuang/capiv2/capi_v2_cirrus_cspl/include/tuningheaders/",
	"compat.c"                 : "/home/hhuang/capiv2/capi_v2_cirrus_cspl/source/compat.c",

	# android device
	"capiv2 directory device"  : "/vendor/lib/rfsa/adsp/",
	"capiv2 lib device"        : "/vendor/lib/rfsa/adsp/capi_v2_cirrus_sp.so",

	"wmfw directory device"    : "/vendor/firmware/",
	"tool directory device"    : "/vendor/bin/",
	"regmap directory device"  : "/d/regmap/",

	# adb push script
	"adb root"    : "adb wait-for-device root",
	"adb remount" : "adb wait-for-device remount",
	"adb wait"    : "adb wait-for-device",
	"adb push"    : "adb push capi_v2_cirrus_cspl.so /vendor/lib/rfsa/adsp/capi_v2_cirrus_sp.so"
}
class Config:
	def __init__(self):
                pass

	def get_conf(self):
		return self.conf

	def conf(self, args):
		model = "@EXE @CONFIG"
		if (platform.system() == "Windows"):
			model = model.replace("@EXE", "notepad.exe").replace("@CONFIG", F_CONFIG)
		else:
			model = model.replace("@EXE", "vim").replace("@CONFIG", F_CONFIG)
		print(model)
		os.system(model)
	
		return
	

	def read(self):
		dict_conf = {}
		
		if (os.path.exists(F_CONFIG)==False):
			return DEFAULT_CONFIG

		with open(F_CONFIG, "r") as cfr:
			lines = cfr.readlines()
			for line in lines:
				# Skip comment lines
				if(line.startswith("#") or not len(line.strip())):
					continue
	
				kv = line.split("=")
				dict_conf[kv[0].strip()] = kv[1].strip()
		return dict_conf
	#def read(self):
	#	self.read(F_CONFIG)
