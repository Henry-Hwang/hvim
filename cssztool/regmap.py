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
	def __init__(self, comport):
		self.comport = comport
		self.regmap_dir = "/d/regmap/" + self.comport + "/"
		return
	
	def get_info(self):
		model = "adb shell \"cat @TARGET \""

		cache_bypass = self.regmap_dir + "cache_bypass"
		name = self.regmap_dir + "name"
		
		model_t = model.replace("@TARGET", name)
		name = os.popen(model_t).read().strip()

		model_t = model.replace("@TARGET", cache_bypass)
		cache_bypass = os.popen(model_t).read().strip()

		comport = self.comport

		return name, comport, cache_bypass

	# @args is the device name 'spi1.0'
	# /d/regmap/spi1.0/cache_bypass
	# /d/regmap/spi1.0/cache_only
	# /d/regmap/spi1.0/registers
	# /d/regmap/spi1.0/range
	# /d/regmap/spi1.0/name
	def regs_dump(self):
	
		model = "adb shell \"cat @TARGET \""
	
		registers = self.regmap_dir + "registers"
		
		
		model = model.replace("@TARGET", registers)
	
		print(model)
		
		#read registers
		raw = os.popen(model).read()
		list_out = raw.split("\n")
		return list_out
	
	def regs_write(self, regval):
		model = "adb shell \"echo REG VALUE > TARGET\""
		target = self.regmap_dir + "registers"
	
		model = model.replace("TARGET", target)
	
		wsets = regval.split(",")
		print(wsets)
		for item in wsets:
			reg, value = item.split("=")
			model_t = model.replace("REG", reg.strip())
			model_t = model_t.replace("VALUE", value.strip())
			print(model_t)
			#write registers
			os.system(model_t)
		return
		
	def regs_read(self, regaddrs):
		model = "adb shell \"cat TARGET | grep -iE \'PATTEN\'\""
		target = self.regmap_dir + "registers"
	
		model = model.replace("TARGET", target)
	
		rsets = regaddrs.split(",")
		patten=""
	
		# cat /d/regmap/xxxx/registers  look like this:
		# 0003800: 00000000
		# 0003804: 00000001

		for index, item in enumerate(rsets):
			rsets[index] = item.strip().replace("0x","").zfill(7)

		for index, item in enumerate(rsets):
			if (index == len(rsets) -1):
				patten = patten + item
			else:
				patten = patten + item + "|"
			#write registers
		model = model.replace("PATTEN", patten.strip())
		print(model)
		#os.system(model)
		string = os.popen(model).read()

		#filter
		list_regs = string.split("\n")
		list_out=[]
		for reg in rsets:
			for it in list_regs:
				rv = it.split(":")
				if(rv[0].strip() != reg):
				    continue
				list_out.append(it)
		return list_out
