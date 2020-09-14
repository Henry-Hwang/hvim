import os
import sys
import platform
import time
import datetime
import shutil
import argparse
import hashlib
import json
from decimal import Decimal
from amp import Amp

CONFIG = "csszt_conf.json"
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
class Conf:
	def __init__(self):
                pass

	@classmethod
	def get_conf(self):
		return self.conf

	@classmethod
	def conf(self, args):
		model = "@EXE @CONFIG"
		if (platform.system() == "Windows"):
			model = model.replace("@EXE", "notepad.exe").replace("@CONFIG", F_CONFIG)
		else:
			model = model.replace("@EXE", "vim").replace("@CONFIG", F_CONFIG)
		print(model)
		os.system(model)
	
		return
	
	@classmethod
	def read(self, path):
		f_json = open(path, "r+")
		jstr = f_json.read()
		#print(jstr)
		jdict = json.loads(jstr)
		#print(jdict)
		return jdict

	#def read(self):
	#	self.read(F_CONFIG)
