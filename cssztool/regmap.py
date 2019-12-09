import os
import sys
import platform
import time
import datetime
import shutil
import argparse
import hashlib
from decimal import Decimal

class Regmap:
	def __init__(device):
		pass
	# @args is the device name 'spi1.0'
	# /d/regmap/spi1.0/cache_bypass
	# /d/regmap/spi1.0/cache_only
	# /d/regmap/spi1.0/registers
	# /d/regmap/spi1.0/range
	# /d/regmap/spi1.0/name
	def dump_registers(self, args):
	
		model = "adb shell \"cat TARGET \" > FILE"
		model_cat = "adb shell \"cat TARGET \""
	
		dir_device = "/d/regmap/" + args + "/"
		registers = dir_device + "registers"
		cache_bypass = dir_device + "cache_bypass"
		cache_only = dir_device + "cache_only"
		range_t = dir_device + "range"
		name = dir_device + "name"
		
		name = model_cat.replace("TARGET", name)
		
		name = os.popen(name).read().strip()
		date = time.strftime('%Y-%m-%d_%H-%M-%S',time.localtime(time.time())).strip()
		
		#cs35l41-spi1.0-2019-12-06_21-35-46.txt
		file_name = name + "-" + args + "-" + date + ".txt"
		model = model.replace("TARGET", registers).replace("FILE", file_name)
	
		print(model)
		
		#read registers
		os.system(model)
	
		return
	
	def regs_write(self, args):
		model = "adb shell \"echo REG VALUE > TARGET\""
		dir_device = "/d/regmap/" + args[0] + "/"
		target = dir_device + "registers"
	
		model = model.replace("TARGET", target)
	
		wsets = args[1].split(",")
		print(wsets)
		for item in wsets:
			reg, value = item.split("<=")
			model_t = model.replace("REG", reg.strip())
			model_t = model_t.replace("VALUE", value.strip())
			print(model_t)
			#write registers
			os.system(model_t)
		return
	
	def regs_read(self, args):
		model = "adb shell \"cat TARGET | grep -iE \'PATTEN\'\""
		dir_device = "/d/regmap/" + args[0] + "/"
		target = dir_device + "registers"
	
		model = model.replace("TARGET", target)
	
		rsets = args[1].split(",")
		length = len(rsets)
		regs=""
	
		# cat /d/regmap/xxxx/registers  look like this:
		# 0003800: 00000000
		# 0003804: 00000001
		for index, item in enumerate(rsets):
			if (index == length -1):
				regs = regs + item.strip().replace("0x","").zfill(7)
			else:
				regs = regs + item.strip().replace("0x","").zfill(7) + "|"
			#write registers
		model = model.replace("PATTEN", regs.strip())
		print(model)
		os.system(model)
		return
