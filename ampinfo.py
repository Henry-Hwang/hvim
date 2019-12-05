#!/usr/bin/python3

import os
import sys
import time
import argparse
from decimal import Decimal
#from __future__ import print_function
adbshell_str="adb shell "
tinymix_str="tinymix "
L_PREFIX="SPK"
R_PREFIX="RCV"
DSP_R_PREFIX="SPK DSP1 Protection R cd"
DSP_L_PREFIX="RCV DSP1 Protection L cd"
AMP_FACTOR=5.8571

def ampinfo_adb_init():
	print('Hello World!')
	os.system("adb wait-for-device")
	os.system("adb root")
	os.system("adb wait-for-device")
	os.system("adb remount")
	os.system("adb wait-for-device")
	return

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
	if (value=="null"):
		cmdstr = adbshell_str + "\"" + tinymix_str + "\'" + prefixed + " " + control + "\' " + "\""
	else:
		cmdstr = adbshell_str + "\"" + tinymix_str + "\'" + prefixed + " " + control + "\' " + value + "\""
	return cmdstr

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

#start here
#
parser = argparse.ArgumentParser()
#parser.add_argument('bar', nargs='+', help='bar help')
parser.add_argument('-i', "--info", required=False, help="display temp", type=int)
parser.add_argument("-m", "--mute", nargs=2, metavar=('channel', 'operation'),help="channel = [left]/[right]/[all]/[mono], operation = [mute]/[unmute]")
parser.add_argument("-p", "--dsp-bypass", nargs=2, metavar=('channel', 'operation'),help="channel = [left]/[right]/[all]/[mono], operation = [yes]/[no]")

parser.add_argument('-s', "--detail", required=False, help="display infomation of a given number", type=int)
parser.add_argument("-r", "--reload", required=False, help="reload firmware", type=int)
parser.add_argument("-de", "--debug", required=False, help="power on / off", type=bool)
parser.add_argument("-rl", "--reload-left", action="store_true", required=False, help="reload left firmware")
parser.add_argument("-rr", "--reload-right", action="store_true", required=False, help="reload right firmware")
parser.add_argument("-rb", "--reload-both", action="store_true", required=False, help="reload right and left firmware")

#parser.print_help()
arg = parser.parse_args()

print (arg)
if arg.info:
	ampinfo_show_temp(arg.info)
if arg.mute:
	ampinfo_mute(arg.mute)
if arg.dsp_bypass:
	ampinfo_dsp_bypass(arg.dsp_bypass)

#un-verify
if arg.detail:
	ampinfo_show_detail(arg.detail)
if arg.reload:
	ampinfo_firmware_reload(arg.reload)
if arg.reload_left:
	ampinfo_firmware_reload(2)
if arg.reload_right:
	ampinfo_firmware_reload(1)
if arg.reload_both:
	ampinfo_firmware_reload(3)
