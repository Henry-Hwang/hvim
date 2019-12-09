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
#from __future__ import print_function
L_PREFIX="SPK"
R_PREFIX="RCV"
DSP_R_PREFIX="SPK DSP1 Protection R cd"
DSP_L_PREFIX="RCV DSP1 Protection L cd"
AMP_FACTOR=5.8571

DICT_CONFIG = {}
F_CONFIG = "cssztool.conf"
OS_SYSTEM = platform.system()

def ampinfo_adb_init():
	print('Hello World!')
	os.system("adb wait-for-device")
	os.system("adb root")
	os.system("adb wait-for-device")
	os.system("adb remount")
	os.system("adb wait-for-device")
	return

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
#RCV DSP1 Protection L cd CSPL_COMMAND
# convert 32bit string to int
# '01 02 0A 0B' --> 0x01020A0B
def ampinfo_32b_parser(string):
	int32 = string.split(':')[1]
	int32 = int32.replace(' ','')
	int32 = int(int32, 16)
	return int32
# convert String to int list
#  '00  00  2b  94  00  00  2b  fb  00  17  6d  b7  00  17  6d  b7'
#  --> 0x00002b94, 0x00002bfb, 0x00176db7, 0x00176db7
def ampinfo_trlog_data_parser(rt):
	log = rt.split(':')[1]
	log = log.replace(' ','')
	_1st = int(log[0:8], 16)
	_2nd = int(log[8:16], 16)
	_3rd = int(log[16:24], 16)
	_4th = int(log[24:32], 16)
	#Q10.13, @5.18
	return (_1st, _2nd, _3rd, _4th)

# The command should look like this:
#	adb shell " tinymix 'PCM Source' 'DSP'"
def ampinfo_mixer_cmd(control, prefixed, value):
	model_get = "adb shell \"tinymix \'PREFIX CONTROL\'\""
	model_set = "adb shell \"tinymix \'PREFIX CONTROL\' VALUE\""
	
	model=""
	if (value=="null"):
		model = model_get.replace("PREFIX", prefixed).replace("CONTROL", control)
	else:
		model = model_set.replace("PREFIX", prefixed).replace("CONTROL", control)
		model = model.replace("VALUE", value)
	return model

def ampinfo_dsp_mixer_set_value(control, prefixed, value):
	cmd = ampinfo_mixer_cmd(control, prefixed, value)
	print(cmd)
	os.system(cmd)
	return

def ampinfo_dsp_mixer_get_value(lr):
	cmd = ampinfo_mixer_cmd(control, prefixed, "null")
	#print(cmd)
	string = os.popen(cmd)
	ret = string.read()
	return ret


def ampinfo_mixer_set_value(control, prefixed, value):
	cmd = ampinfo_mixer_cmd(control, prefixed, value)
	print(cmd)
	os.system(cmd)
	return

def ampinfo_mixer_get_value(control, prefixed):
	cmd = ampinfo_mixer_cmd(control, prefixed, "null")
	#print(cmd)
	string = os.popen(cmd)
	ret = string.read()
	return ret

def ampinfo_mute(op):
	if (op[1]=="mute"):
	    value = "0"
	else:
	    value = "1"

	if(op[0]=="left"):
		ampinfo_mixer_set_value("AMP Enable", R_PREFIX, value)
	elif(op[0]=="right"):
		ampinfo_mixer_set_value("AMP Enable", L_PREFIX, value)
	elif(op[0]=="all"):
		ampinfo_mixer_set_value("AMP Enable", R_PREFIX, value)
		ampinfo_mixer_set_value("AMP Enable", L_PREFIX, value)
	else:
		ampinfo_mixer_set_value("AMP Enable", "null", value)
	return

def ampinfo_dsp_bypass(op):
	if (op[1]=="yes"):
	    value = "ASPRX1"
	else:
	    value = "DSP"

	if(op[0]=="left"):
		ampinfo_mixer_set_value("PCM Source", R_PREFIX, value)
	elif(op[0]=="right"):
		ampinfo_mixer_set_value("PCM Source", L_PREFIX, value)
	elif(op[0]=="all"):
		ampinfo_mixer_set_value("PCM Source", R_PREFIX, value)
		ampinfo_mixer_set_value("PCM Source", L_PREFIX, value)
	else:
		ampinfo_mixer_set_value("PCM Source", "null", value)
	return

def ampinfo_list(op):
	model = "adb shell \"find DIRECTORY F_ARGS | grep G_ARGS PATTEN | xargs ls -l\""
	os.system("adb shell \"find /vendor/lib/rfsa/adsp -type f | grep -i cirrus | xargs ls -l\"")
	os.system("adb shell \"find /vendor/bin -type f | grep -i cirrus | xargs ls -l\"")
	#os.system("adb shell \"find /vendor/etc -type f | grep -i cirrus | xargs ls -l\"")
	os.system("adb shell \"find /vendor/firmware -type f| grep -i cs35 | xargs ls -l\"")
	os.system("adb shell \"find /d/regmap -type d | grep -iE i2c\|spi\"")
	return

def ampinfo_device_md5sum(op):
	os.system("adb shell \"find /vendor/lib/rfsa/adsp -typr f | grep -i cirrus | xargs md5sum\"")
	os.system("adb shell \"find /vendor/bin -type f | grep -i cirrus | xargs md5sum\"")
	os.system("adb shell \"find /vendor/firmware -type f | grep -i cs35 | xargs md5sum\"")
	return

def ampinfo_push(args):
	if(args[0]=="capi"):
	    cmd = "adb push"
	    target = "/vendor/lib/rfsa/adsp/capi_v2_cirrus_sp.so"

	os.system(cmd + " " + args[1] + " " + target)
	os.system("md5sum " + args[1])
	os.system("adb shell md5sum " + target)

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

def ampinfo_rtlog_init(prefix):
	ampinfo_mixer_set_value("RAMESPERCAPTUREWI", prefix, "0x00 0x00 0x07 0xD0")
	ampinfo_mixer_set_value("RTLOG_VARIABLE", prefix, "0x00 0x00 0x03 0x9D 0x00 0x00 0x03 0xAE")
	ampinfo_mixer_set_value("RTLOG_COUNT", prefix, "0x00 0x00 0x00 0x02")
	ampinfo_mixer_set_value("RTLOG_CAN_READ", prefix, "0x0 0x0 0x00 0x02")
	ampinfo_mixer_set_value("RTLOG_ENABLE", prefix, "0x00 0x00 0x00 0x01")
	return

def ampinfo_map_route(on_off, prefix):

	if (side == L_PREFIX):
		FW="Protection Left"
	elif (prefix == R_PREFIX): #right
		FW="Protection Left"
	else:
		FW="Protection"

	if(on_off == "on"):
		ampinfo_mixer_set_value("PCM Source", prefix, "DSP")
		ampinfo_mixer_set_value("DSP1 Firmware", prefix, FW)
		ampinfo_mixer_set_value("AMP Enable Switch", prefix, "1")
	else:
		ampinfo_mixer_set_value("DSP Booted", prefix, "0")
		ampinfo_mixer_set_value("DSP1 Firmware", prefix, FW)
		ampinfo_mixer_set_value("AMP Enable Switch", prefix, "0")
	return

def ampinfo_firmware_reload(side):
	if(side == 2):
		ampinfo_map_route("off", L_PREFIX)
		time.sleep(1)
		ampinfo_map_route("on", L_PREFIX)
	elif (side == 1):
		ampinfo_map_route("off", R_PREFIX)
		time.sleep(1)
		ampinfo_map_route("on", R_PREFIX)
	else:
		ampinfo_map_route("off", R_PREFIX)
		ampinfo_map_route("off", L_PREFIX)
		time.sleep(1)
		ampinfo_map_route("on", R_PREFIX)
		ampinfo_map_route("on", L_PREFIX)
	return

# read RT data
def ampinfo_get_rtlog_data(prefix):
	ret = ampinfo_mixer_get_value("RTLOG_DATA", prefix)
	#print ret
	return ret

# read calibration Z
def ampinfo_get_cal_z_value(prefix):
	ret = ampinfo_mixer_get_value("CAL_R", prefix)
	return ret
# read temperature
def ampinfo_get_cspl_temperature(prefix):
	ret = ampinfo_mixer_get_value("CSPL_TEMPERATURE", prefix)
	return ret

def ampinfo_get_cspl_ambient(prefix):
	ret = ampinfo_mixer_get_value("CAL_AMBIENT", prefix)
	return ret

def ampinfo_rtlog_info(prefix):
	rowdata = ampinfo_get_rtlog_data(prefix)
	z_min, z_max, factor_min, factor_max = ampinfo_trlog_data_parser(rowdata)

	rowdata = ampinfo_get_cspl_temperature(prefix)
	temp = ampinfo_32b_parser(rowdata)

	z_min = Decimal(z_min)
	z_max = Decimal(z_max)
	factor_min = Decimal(factor_min)
	factor_max = Decimal(factor_max)

	#Q9.14
	temp = Decimal(temp)/Decimal(2<<13)
	#Q5.18
	factor_min = Decimal(factor_min/(2<<17))
	#Q10.13
	z_min = Decimal(factor_min * z_min)/Decimal(2<<12)
	z_max = Decimal(factor_min * z_max)/Decimal(2<<12)

	return (z_min, z_max, temp)

def ampinfo_show_temp(count):
	ampinfo_adb_init()
	rawdata = ampinfo_get_cal_z_value(DSP_L_PREFIX)
	cal_z_l = ampinfo_32b_parser(rawdata)

	rawdata = ampinfo_get_cal_z_value(DSP_R_PREFIX)
	cal_z_r = ampinfo_32b_parser(rawdata)
	
	rawdata = ampinfo_get_cspl_ambient(DSP_L_PREFIX)
	ambient = ampinfo_32b_parser(rawdata)

	#get calibration value of L/R, Q10.13
	cal_z_r = Decimal(AMP_FACTOR * cal_z_r/(2<<12))
	cal_z_l = Decimal(AMP_FACTOR * cal_z_l/(2<<12))
	ambient = Decimal(ambient)

	print ("Ambient: %d Celsius degree," %ambient, "CAL Left: %3.2f (ohm)," %cal_z_l, "CAL Right: %3.2f (ohm)" %cal_z_r)
	print ("-------------------------------------------------------")
	for i in range(count):
		#get calibration value of L/R, Q10.13
		rawdata = ampinfo_get_cspl_temperature(DSP_R_PREFIX)
		temp_r = ampinfo_32b_parser(rawdata)

		rawdata = ampinfo_get_cspl_temperature(DSP_L_PREFIX)
		temp_l = ampinfo_32b_parser(rawdata)
	
		#Q9.14
		temp_r = Decimal(temp_r)/Decimal(2<<13)
		#Q9.14
		temp_l = Decimal(temp_l)/Decimal(2<<13)
		print (" TEMP (%3.2f, " %temp_l, "%3.2f)" %temp_r)
		time.sleep(1)
	return

def ampinfo_show_detail(count):
	ampinfo_adb_init()
	ampinfo_rtlog_init(DSP_R_PREFIX)
	ampinfo_rtlog_init(DSP_L_PREFIX)
	
	rawdata = ampinfo_get_cal_z_value(DSP_L_PREFIX)
	cal_z_l = ampinfo_32b_parser(rawdata)

	rawdata = ampinfo_get_cal_z_value(DSP_R_PREFIX)
	cal_z_r = ampinfo_32b_parser(rawdata)

	#get calibration value of L/R, Q10.13
	cal_z_r = Decimal(AMP_FACTOR * cal_z_r/(2<<12))
	cal_z_l = Decimal(AMP_FACTOR * cal_z_l/(2<<12))
	print (" CAL (%3.2f, " %cal_z_l, "%3.2f)" %cal_z_r ,"  FACTOR (%3.4f," %5.8571, "%3.4f)" %5.8571)

	#for i in range(count):
	l_z_min, l_z_max, l_temp = ampinfo_rtlog_info(DSP_L_PREFIX)
	r_z_min, r_z_max, r_temp = ampinfo_rtlog_info(DSP_R_PREFIX)
	print ("L (%3.2f" %l_z_min, " %3.2f )ohm"  %l_z_max, "  R (%3.2f" %r_z_min, " %3.2f )ohm"  %r_z_max, "  T (%3.2f," %l_temp, "%3.2f)C" %r_temp)
	time.sleep(1)
	return


def ampinfo_conf(args):
	model = "@EXE @CONFIG"
	if (OS_SYSTEM == "Windows"):
		model = model.replace("@EXE", "notepad.exe").replace("@CONFIG", F_CONFIG)
	else:
		model = model.replace("@EXE", "vim").replace("@CONFIG", F_CONFIG)
	print(model)
	os.system(model)

	return

def ampinfo_read_conf():
	with open(F_CONFIG, "r") as cfr:
		lines = cfr.readlines()
		for line in lines:
			# Skip comment lines
			if(line.startswith("#")):
				continue
			kv = line.split("=")
			DICT_CONFIG[kv[0].strip()] = kv[1].strip()
	print(DICT_CONFIG)	
	return

def ampinfo_capiv2_lib_info():
	branch = ampinfo_get_work_branch(DICT_CONFIG["capiv2 directory"])
	list_chksum = ampinfo_get_mult_checksum(DICT_CONFIG["compat.c"])
	print(branch)
	for it in list_chksum:
		print(it)
	now = datetime.datetime.now()
	print(now.strftime('%a-%b-%d-%Y_%H-%M-%S'))

	return

def ampinfo_get_work_branch(repo):
	model = "cd REPO && git branch && cd -"
	model = model.replace("REPO", repo)
	print(model)
	branch = os.popen(model).read()
	lines = branch.split("\n")
	for line in lines:
		if(line.startswith("*")):
			branch=line
			break
	return branch

def ampinfo_get_mult_checksum(c_compat):
	patten = "#define USE_CASE_@INDEX_TUNING@_NBITS \"tuningheaders/"
	list_chksum=[]
	with open(c_compat, "r") as cfr:
		lines = cfr.readlines()
		for line in lines:
			uc_bit = ""
			if patten.replace("@INDEX", "0").replace("@_NBITS", "") in line:
				uc_bit = "UC0_16BIT"
			if patten.replace("@INDEX", "1").replace("@_NBITS", "") in line:
				uc_bit = "UC1_16BIT"
			if patten.replace("@INDEX", "2").replace("@_NBITS", "") in line:
				uc_bit = "UC2_16BIT"
			if patten.replace("@INDEX", "3").replace("@_NBITS", "") in line:
				uc_bit = "UC3_16BIT"
			if patten.replace("@INDEX", "0").replace("@_NBITS", "_24BIT") in line:
				uc_bit = "UC0_24BIT"
			if patten.replace("@INDEX", "1").replace("@_NBITS", "_24BIT") in line:
				uc_bit = "UC1_24BIT"
			if patten.replace("@INDEX", "2").replace("@_NBITS", "_24BIT") in line:
				uc_bit = "UC2_24BIT"
			if patten.replace("@INDEX", "3").replace("@_NBITS", "_24BIT") in line:
				uc_bit = "UC3_24BIT"

			if(uc_bit==""):
				continue

			line = line.replace("\"", "").strip()
			[dirname,filename] = os.path.split(line)
			f_tuning = DICT_CONFIG["source tuning directory"] + filename
			if (os.path.exists(f_tuning)==False):
				continue
			dict_chksum = aminfo_get_one_checksum(f_tuning)
			list_chksum.append(str(dict_chksum) + " : " + uc_bit + " : " +filename)
	return list_chksum

def aminfo_get_one_checksum(f_tuning):
	
	#"CSPL_CONFIG_RX_RIGHT"
	#"CSPL_CONFIG_RX_LEFT"
	#"CSPL_CONFIG_TX_RIGHT"
	#"CSPL_CONFIG_TX_LEFT"
	if (DICT_CONFIG["playback version"] == "4"):
		patten = "CSPL_CONFIG_@TXRX"
	else:
		patten = "CSPL_CONFIG_@TXRX_@LR"

	dict_chksum = {}
	with open(f_tuning, "r") as cfr:
		lines = cfr.readlines()
		for line in lines:
			if (DICT_CONFIG["playback version"] == "4"):
				if patten.replace("@TXRX", "RX") in line:
					elements = line.split(",")
					dict_chksum["rx"] = elements[len(elements) - 1].strip()
				if patten.replace("@TXRX", "TX") in line:
					elements = line.split(",")
					dict_chksum["tx"] = elements[len(elements) - 1].strip()
			else:
				if patten.replace("@TXRX", "RX").replace("@LR", "RIGHT") in line:
					elements = line.split(",")
					dict_chksum["rx left"] = elements[len(elements) - 1].strip()
				if patten.replace("@TXRX", "RX").replace("@LR", "LEFT") in line:
					elements = line.split(",")
					dict_chksum["rx right"] = elements[len(elements) - 1].strip()
				if patten.replace("@TXRX", "TX").replace("@LR", "RIGHT") in line:
					elements = line.split(",")
					dict_chksum["tx right"] = elements[len(elements) - 1].strip()
				if patten.replace("@TXRX", "TX").replace("@LR", "LEFT") in line:
					elements = line.split(",")
					dict_chksum["tx left"] = elements[len(elements) - 1].strip()

	#print(dict_chksum)
	return dict_chksum


# @c_file : [compat.c] which include @tuning
# @tuning : [*.h/txt] tuning file
# @bit : [16/24] 16bit/24bit tuning
def ampinfo_tuning_update(c_file, tuning, bit):
	dir_tuning = DICT_CONFIG["source tuning directory"]
	if (bit==24):
		patten = "#define USE_CASE_0_TUNING_24BIT \"tuningheaders/"
		model = "#define USE_CASE_0_TUNING_24BIT \"tuningheaders/@NEW_TUNING\"\n"
	else:
		patten = "#define USE_CASE_0_TUNING \"tuningheaders/"
		model = "#define USE_CASE_0_TUNING \"tuningheaders/@NEW_TUNING\"\n"
	[dirname,filename] = os.path.split(tuning)
	shutil.copyfile(tuning, dir_tuning+filename)

	with open(c_file, "r") as cfr:
		lines = cfr.readlines()
	with open(c_file, "w") as cfw:
		for line in lines:
			if patten in line:
				line = model.replace("@NEW_TUNING", filename)
			cfw.write(line)
	return

def ampinfo_covert_tuning(f_tuning):
	covt_model = "cd @DIR && json2hexagonbin.exe -t @H_HEADER @JSON && cd -"
	[dirname,filename] = os.path.split(f_tuning)
	[fname,fename]=os.path.splitext(f_tuning)
	
	tuning_t = f_tuning
	if (fename==".json"):
		h_header = filename.replace(".json", ".h")
		model_t = covt_model.replace("@H_HEADER", h_header).replace("@JSON", filename)
		model_t = model_t.replace("@DIR", dirname)
		print(model_t)
		os.system(model_t)
		tuning_t = f_tuning.replace(".json", ".h")
	return tuning_t

def ampinfo_make_capi_v2(args):
	ampinfo_read_conf()
	if (OS_SYSTEM != "Windows"):
		model = "cd ~/capiv2 && ./cygwin-make-setup-sdk3.4.3.sh && cd -"
		f_24bit = args[0]
		f_16bit = args[1]
		print(args)
		print(f_24bit)
		if (os.path.exists(f_24bit)==True):
			f_24bit = ampinfo_covert_tuning(f_24bit)
			ampinfo_tuning_update(DICT_CONFIG["compat.c"], f_24bit, 24)
		
		if (os.path.exists(f_16bit)==True):
			f_16bit = ampinfo_covert_tuning(f_16bit)
			ampinfo_tuning_update(DICT_CONFIG["compat.c"], f_16bit, 16)
		
		if (os.path.exists(f_24bit)) and (os.path.exists(f_16bit)):
			print("No tuning file input!")
		#build lib
		os.system(model)
		ampinfo_capiv2_lib_info()
	return

ampinfo_show_op_sys()
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
if arg.conf:
	ampinfo_conf(arg.conf)
if arg.info:
	ampinfo_show_temp(arg.info)
if arg.mute:
	ampinfo_mute(arg.mute)
if arg.dsp_bypass:
	ampinfo_dsp_bypass(arg.dsp_bypass)
if arg.list:
	ampinfo_list(arg.list)
if arg.dump_regs:
	ampinfo_dump_registers(arg.dump_regs)
if arg.dev_md5sum:
	ampinfo_device_md5sum(arg.dev_md5sum)
if arg.md5sum:
	ampinfo_md5sum(arg.md5sum)
if arg.push:
	ampinfo_push(arg.push)
if arg.reg_write:
	ampinfo_regs_write(arg.reg_write)
if arg.reg_read:
	ampinfo_regs_read(arg.reg_read)
if arg.make_capi:
	ampinfo_make_capi_v2(arg.make_capi)

#un-verify
if arg.detail:
	ampinfo_show_detail(arg.detail)
if arg.reload:
	ampinfo_firmware_reload(arg.reload)
