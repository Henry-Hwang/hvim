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
from amp import Amp
from playback import Playback
from config import Config
#from __future__ import print_function
OS_SYSTEM = platform.system()

def ampinfo_adb_init():
	os.system("adb wait-for-device")
	os.system("adb root")
	os.system("adb wait-for-device")
	os.system("adb remount")
	os.system("adb wait-for-device")
	return

# Connection look like this:
# List of devices attached
# Z91QAEVJUTQX6   device
def ampinfo_adb_check_connection():
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

def ampinfo_show_op_sys():
	print(platform.system())
	print(platform.platform())
	print(platform.version())
	print(platform.architecture())
	print(platform.machine())
	print(platform.node())
	print(platform.processor())
	return

def ampinfo_md5sum(source):
	fd = open(source)
	md5 = hashlib.md5()
	md5.update(fd.read().encode('utf-8'))
	value = md5.hexdigest()
	print(value)
	return value
def ampinfo_list(op):
	model = "adb shell \"find @DIRECTORY @F_ARGS | grep @G_ARGS @PATTEN | xargs ls -l\""

	model_t = model.replace("@DIRECTORY", DICT_CONFIG["capiv2 directory device"])
	model_t = model_t.replace("@F_ARGS", "-type f").replace("@G_ARGS", "-i").replace("@PATTEN", "cirrus")
	os.system(model_t)

	model_t = model.replace("@DIRECTORY", DICT_CONFIG["tool directory device"])
	model_t = model_t.replace("@F_ARGS", "-type f").replace("@G_ARGS", "").replace("@PATTEN", "cirrus")
	os.system(model_t)

	model_t = model.replace("@DIRECTORY", DICT_CONFIG["wmfw directory device"])
	model_t = model_t.replace("@F_ARGS", "-type f").replace("@G_ARGS", "-i").replace("@PATTEN", "cs35")
	os.system(model_t)

	model = "adb shell \"find @DIRECTORY @F_ARGS | grep @G_ARGS @PATTEN\""
	model_t = model.replace("@DIRECTORY", DICT_CONFIG["regmap directory device"])
	model_t = model_t.replace("@F_ARGS", "-type d").replace("@G_ARGS", "-iE").replace("@PATTEN", "\'i2c|spi\'")
	os.system(model_t)

	return

def ampinfo_device_md5sum(op):
	model = "adb shell \"find @DIRECTORY @F_ARGS | grep @G_ARGS @PATTEN | xargs md5sum\""
	model_t = model.replace("@DIRECTORY", DICT_CONFIG["capiv2 directory device"])
	model_t = model_t.replace("@F_ARGS", "-type f").replace("@G_ARGS", "-i").replace("@PATTEN", "cirrus")
	os.system(model_t)

	model_t = model.replace("@DIRECTORY", DICT_CONFIG["tool directory device"])
	model_t = model_t.replace("@F_ARGS", "-type f").replace("@G_ARGS", "-i").replace("@PATTEN", "cirrus")
	os.system(model_t)
	
	model_t = model.replace("@DIRECTORY", DICT_CONFIG["wmfw directory device"])
	model_t = model_t.replace("@F_ARGS", "-type f").replace("@G_ARGS", "-i").replace("@PATTEN", "cs35")
	os.system(model_t)
	
	return

def ampinfo_push_device(args):
	model = "adb push @SOURCE @DEST"
	model_md5 = "adb shell \"md5sum @TARGET\""
	f_file = args[1]
	if (os.path.exists(f_file.strip())==False):
	    print("file on exist: " + args[1])
	    return

	if(args[0]=="capi"):
		#push to device
		model = model.replace("@SOURCE", f_file).replace("@DEST", DICT_CONFIG["capiv2 lib device"])
		os.system(model)
		
		# md5sum, show both for comparing
		model_md5 = model_md5.repace("@TARGET", DICT_CONFIG["capiv2 lib device"])
	os.system(model_md5)
	ampinfo_md5sum(f_file)

	return

# @args is the device name 'spi1.0'
# /d/regmap/spi1.0/cache_bypass
# /d/regmap/spi1.0/cache_only
# /d/regmap/spi1.0/registers
# /d/regmap/spi1.0/range
# /d/regmap/spi1.0/name
def ampinfo_dump_registers(args):

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

def ampinfo_regs_write(args):
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

def ampinfo_regs_read(args):
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

ampinfo_show_op_sys()
if ampinfo_adb_check_connection():
	ampinfo_adb_init()
else:
	print("Not device connected")
#start here
#
#parser = argparse.ArgumentParser()
parser = argparse.ArgumentParser(description='Cirrus Shenzhen, AMP tool for Android',
        usage='use "python %(prog)s --help" for more information',
        formatter_class=argparse.RawTextHelpFormatter)
#parser.add_argument('bar', nargs='+', help='bar help')
parser.add_argument('-c', "--conf",
	required=False,
	metavar=('[COUNT]'),
	type=int,
	help="Display temp: [COUNT] = 10, 100, 1000")
parser.add_argument('-i', "--info",
	required=False,
	metavar=('[COUNT]'),
	type=int,
	help="Display temp: [COUNT] = 10, 100, 1000")
parser.add_argument('-dmd5', "--dev_md5sum",
	action="store_true",
	required=False,
	help="Show md5sum of cirrus stuff in android device")
parser.add_argument('-md5', "--md5sum",
	required=False,
	type=str,
	help="Show md5sum of file")
parser.add_argument('-l', "--list",
	action="store_true",
	required=False,
	help="List Cirrus stuff")
parser.add_argument('-mc', "--make-capi",
	required=False,
	nargs=2,
	metavar=('[24BIT]', '[16BIT]'),
	help="Make CAPI V2 Playback.")
parser.add_argument("-m", "--mute",
	nargs=2,
	metavar=('[CH]', '[OP]'),
	help="[CH] = left,right,all,mono, [OP] = mute,unmute")
parser.add_argument("-b", "--dsp-bypass",
	nargs=2,
	metavar=('[CH]', '[OP]'),
	help="Bypass DSP: [CH] = left,right,all,mono, [OP] = yes,no")
parser.add_argument('-d', "--dump-regs",
	#action="store_true",
	required=False,
	metavar=('[DEVICE]'),
	help="Dump amp's registers: [DEVICE] = spi1.0, 2-0040. show [DEVICE] by '--list'")
parser.add_argument('-p', "--push",
	nargs=2,
	metavar=('[TYPE]', '[FILE]'),
	help="Push stuff to device: [TYPE] = capi,wmfw,bin,tool, [FILE] = source file")
parser.add_argument('-rw', "--reg-write",
	nargs=2,
	metavar=('[DEVICE]', '[REG<=VAL, ...]'),
	type=str,
	help="Write registers:  [DEVICE] = spi1.0, 2-0040. show [DEVICE] by '--list'. [REG<=VAL,...] = \"0x3804<=0x01,0x3800<=0x12, ...\" >")
parser.add_argument('-rr', "--reg-read", 
	nargs=2,
	metavar=('[DEVICE]', '[REGS, ...]'),
	type=str,
	help="Read registers:  [DEVICE] = spi1.0, 2-0040. show [DEVICE] by '--list'.")

parser.add_argument('-s', "--detail",
	required=False,
	type=int,
	help="display infomation of a given number")
parser.add_argument("-r", "--reload",
	required=False,
	type=int,
	help="reload firmware")
parser.add_argument("-de", "--debug",
	required=False,
	type=bool,
	help="power on / off")

#parser.print_help()
arg = parser.parse_args()
print (arg)

CONFIG = Config().get_conf()
samp = Amp(CONFIG)
playback = Playback(CONFIG)

if arg.conf:
	ampinfo_conf(arg.conf)
if arg.info:
	samp.show_temp(arg.info)
if arg.mute:
	samp.mute(arg.mute)
if arg.dsp_bypass:
	samp.dsp_bypass(arg.dsp_bypass)
if arg.list:
	ampinfo_list(arg.list)
if arg.dump_regs:
	ampinfo_dump_registers(arg.dump_regs)
if arg.dev_md5sum:
	ampinfo_device_md5sum(arg.dev_md5sum)
if arg.md5sum:
	ampinfo_md5sum(arg.md5sum)
if arg.push:
	ampinfo_push_device(arg.push)
if arg.reg_write:
	ampinfo_regs_write(arg.reg_write)
if arg.reg_read:
	ampinfo_regs_read(arg.reg_read)
if arg.make_capi:
	playback.make_capi_v2(arg.make_capi)

#un-verify
if arg.detail:
	samp.show_detail(arg.detail)
if arg.reload:
	samp.firmware_reload(arg.reload)
