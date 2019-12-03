#!/usr/bin/python3

import os
import sys
import commands
import time
import argparse
from decimal import Decimal
#from __future__ import print_function

def rtlog_adb_init():
	print('Hello World!')
	os.system("adb wait-for-device")
	os.system("adb root")
	os.system("adb wait-for-device")
	os.system("adb remount")
	os.system("adb wait-for-device")
	return

def rtlog_cspl_init(lr):
	if(lr is "right"):
		os.system("adb shell \"tinymix \'SPK DSP1X Protection R cd RAMESPERCAPTUREWI\'  0x00 0x00 0x07 0xD0 \" ")
		# Log the realtime resistance
		os.system("adb shell \"tinymix \'SPK DSP1X Protection R cd RTLOG_VARIABLE\'   	0x00 0x00 0x03 0x9D 0x00 0x00 0x03 0xAE \" ")
		os.system("adb shell \"tinymix \'SPK DSP1X Protection R cd RTLOG_COUNT\'   		0x00 0x00 0x00 0x02 \" ")
		# Enable the realtime logger
		os.system("adb shell \"tinymix \'SPK DSP1X Protection R cd RTLOG_CAN_READ\'   	0x0 0x0 0x00 0x02 \" ")
		os.system("adb shell \"tinymix \'SPK DSP1X Protection R cd RTLOG_ENABLE\'   	0x00 0x00 0x00 0x01 \" ")
		#result = os.popen("adb shell tinymix \"SPK\ DSP1X\ Protection\ R\ cd\ RTLOG_DATA\"")
	else:
		os.system("adb shell \"tinymix \'RCV DSP1X Protection L cd RAMESPERCAPTUREWI\'  0x00 0x00 0x07 0xD0 \" ")
		# Log the realtime resistance
		os.system("adb shell \"tinymix \'RCV DSP1X Protection L cd RTLOG_VARIABLE\'   	0x00 0x00 0x03 0x9D 0x00 0x00 0x03 0xAE \" ")
		os.system("adb shell \"tinymix \'RCV DSP1X Protection L cd RTLOG_COUNT\'   		0x00 0x00 0x00 0x02 \" ")
		# Enable the realtime logger
		os.system("adb shell \"tinymix \'RCV DSP1X Protection L cd RTLOG_CAN_READ\'   	0x0 0x0 0x00 0x02 \" ")
		os.system("adb shell \"tinymix \'RCV DSP1X Protection L cd RTLOG_ENABLE\'   	0x00 0x00 0x00 0x01 \" ")
		#result = os.popen("adb shell tinymix \"SPK\ DSP1X\ Protection\ R\ cd\ RTLOG_DATA\"")
	return

def rtlog_map_route(on_off, side):

	if (side is "left"):
		if(on_off is "on"):
			os.system("adb shell \"tinymix \'RCV PCM Source\'  DSP \" ")
			os.system("adb shell \"tinymix \'RCV DSP1 Firmware\'  \'Protection Left\' \" ")
			os.system("adb shell \"tinymix \'RCV AMP Enable Switch\'  1 \" ")
		else:
			os.system("adb shell \"tinymix \'RCV DSP Booted\'  0 \" ")
			os.system("adb shell \"tinymix \'RCV DSP1 Firmware\'  \'Protection Left\' \" ")
			os.system("adb shell \"tinymix \'RCV AMP Enable Switch\'  0 \" ")
	else: #right
		if(on_off is "on"):
			os.system("adb shell \"tinymix \'SPK PCM Source\'  DSP \" ")
			os.system("adb shell \"tinymix \'SPK DSP1 Firmware\'  \'Protection Right\' \" ")
			os.system("adb shell \"tinymix \'SPK AMP Enable Switch\'  1 \" ")
		else:
			os.system("adb shell \"tinymix \'SPK DSP Booted\'  0 \" ")
			os.system("adb shell \"tinymix \'SPK DSP1 Firmware\'  \'Protection Right\' \" ")
			os.system("adb shell \"tinymix \'SPK AMP Enable Switch\'  0 \" ")

	return

def rtlog_reload(side):
	if(side is 2):
		rtlog_map_route("off", "left")
		time.sleep(1)
		rtlog_map_route("on", "left")
	elif (side is 1):
		rtlog_map_route("off", "right")
		time.sleep(1)
		rtlog_map_route("on", "right")
	else:
		rtlog_map_route("off", "right")
		rtlog_map_route("off", "left")
		time.sleep(1)
		rtlog_map_route("on", "right")
		rtlog_map_route("on", "left")
	return

def rtlog_power_left(on_off):
	if(on_off is 1):
		rtlog_map_route("on", "left")
	else:
		rtlog_map_route("off", "left")
	return

def rtlog_power_right(on_off):
	if(on_off is 1):
		rtlog_map_route("on", "right")
	else:
		rtlog_map_route("off", "right")
	return
	
def rtlog_set_command(cmd, lr):
	print lr, cmd
	if(lr is "right"):
		if (cmd is 1):
			os.system("adb shell \"tinymix \'SPK DSP1X Protection R cd CSPL_COMMAND\'   0x00 0x00 0x00 0x01 \" ")
		elif (cmd is 2):
			os.system("adb shell \"tinymix \'SPK DSP1X Protection R cd CSPL_COMMAND\'   0x00 0x00 0x00 0x02 \" ")
		else:
			print "nuknown %d" %cmd
	else:
		if (cmd is 1):
			os.system("adb shell \"tinymix \'RCV DSP1X Protection L cd CSPL_COMMAND\'   0x00 0x00 0x00 0x01 \" ")
		elif (cmd is 2):
			os.system("adb shell \"tinymix \'RCV DSP1X Protection L cd CSPL_COMMAND\'   0x00 0x00 0x00 0x02 \" ")
		else:
			print "nuknown %d" %cmd
	return
	
def rtlog_mute_left(op):
	rtlog_set_command(op, 'left')
	return

def rtlog_mute_right(op):
	rtlog_set_command(op, 'right')
	return

#RCV DSP1X Protection L cd CSPL_COMMAND
# convert 32bit string to int
# '01 02 0A 0B' --> 0x01020A0B
def rtlog_32b_parser(string):
	int32 = string.split(':')[1]
	int32 = int32.replace(' ','')
	int32 = int(int32, 16)
	return int32
# convert String to int list
#  '00  00  2b  94  00  00  2b  fb  00  17  6d  b7  00  17  6d  b7'
#  --> 0x00002b94, 0x00002bfb, 0x00176db7, 0x00176db7
def rtlog_data_parser(rt):
	log = rt.split(':')[1]
	log = log.replace(' ','')
	_1st = int(log[0:8], 16)
	_2nd = int(log[8:16], 16)
	_3rd = int(log[16:24], 16)
	_4th = int(log[24:32], 16)
	#Q10.13, @5.18
	return (_1st, _2nd, _3rd, _4th)

# read RT data
def rtlog_get_data(lr):
	if(lr is "right"):
		string = os.popen("adb shell \"tinymix \'SPK DSP1X Protection R cd RTLOG_DATA\' \" ")
	else:
		string = os.popen("adb shell \"tinymix \'RCV DSP1X Protection L cd RTLOG_DATA\' \" ")
	ret = string.read()
	#print ret
	return ret

# read calibration Z
def rtlog_get_cal_r(lr):
	if(lr is "right"):
		string = os.popen("adb shell \"tinymix \'SPK DSP1X Protection R cd CAL_R\' \" ")
	else:
		string = os.popen("adb shell \"tinymix \'RCV DSP1X Protection L cd CAL_R\' \" ")

	ret = string.read()
	#print ret
	return ret
# read temperature
def rtlog_get_cspl_temperature(lr):
	if(lr is "right"):
		string = os.popen("adb shell \"tinymix \'SPK DSP1X Protection R cd CSPL_TEMPERATURE\' \" ")
	else:
		string = os.popen("adb shell \"tinymix \'RCV DSP1X Protection L cd CSPL_TEMPERATURE\' \" ")
	ret = string.read()
	#print ret
	return ret

def rtlog_info(lr, cal_r):
	if(lr is "right"):
		z_min, z_max, factor_min, factor_max = rtlog_data_parser(rtlog_get_data("right"))
		temp = rtlog_32b_parser(rtlog_get_cspl_temperature("right"))
	else:
		z_min, z_max, factor_min, factor_max = rtlog_data_parser(rtlog_get_data("left"))
		temp = rtlog_32b_parser(rtlog_get_cspl_temperature("left"))

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

def rtlog_show_info(count):
	rtlog_adb_init()
	rtlog_cspl_init("left")
	rtlog_cspl_init("right")
	global_cal_r_l = rtlog_32b_parser(rtlog_get_cal_r("left"))
	global_cal_r_r = rtlog_32b_parser(rtlog_get_cal_r("right"))

	#get calibration value of L/R, Q10.13
	cal_r_r_10 = Decimal(5.8571 * global_cal_r_r/(2<<12))
	cal_r_l_10 = Decimal(5.8571 * global_cal_r_l/(2<<12))
	print " CAL (%3.2f, " %cal_r_l_10, "%3.2f)" %cal_r_r_10 ,"  FACTOR (%3.4f," %5.8571, "%3.4f)" %5.8571
	for i in range(count):
		l_z_min, l_z_max, l_temp = rtlog_info("left", global_cal_r_l)
		r_z_min, r_z_max, r_temp = rtlog_info("right", global_cal_r_r)
		print "L (%3.2f" %l_z_min, " %3.2f )ohm"  %l_z_max, "  R (%3.2f" %r_z_min, " %3.2f )ohm"  %r_z_max, "  T (%3.2f," %l_temp, "%3.2f)C" %r_temp
		time.sleep(1)
	return

#start here
#
parser = argparse.ArgumentParser()
#parser.add_argument('bar', nargs='+', help='bar help')
parser.add_argument('-s', "--show", required=False, help="display infomation of a given number", type=int)
parser.add_argument("-r", "--reload", required=False, help="reload firmware", type=int)
parser.add_argument("-p", "--power", required=False, help="power on / off", type=str)
parser.add_argument("-de", "--debug", required=False, help="power on / off", type=bool)
parser.add_argument("-rl", "--reload-left", action="store_true", required=False, help="reload left firmware")
parser.add_argument("-rr", "--reload-right", action="store_true", required=False, help="reload right firmware")
parser.add_argument("-rb", "--reload-both", action="store_true", required=False, help="reload right and left firmware")
parser.add_argument("-pl", "--power-left", required=False, help="power right and left AMP on/off, 1:on, 2:off", type=int)
parser.add_argument("-pr", "--power-right", required=False, help="power right and left AMP on/off, 1:on, 2:off", type=int)
parser.add_argument("-ml", "--mute-left", required=False, help="mute/unmute left AMP, 1:mute, 2:unmute", type=int)
parser.add_argument("-mr", "--mute-right", required=False, help="mute/unmute right AMP, 1:mute, 2:unmute", type=int)

#parser.print_help()
arg = parser.parse_args()

if arg.show:
	rtlog_show_info(arg.show)
if arg.reload:
	rtlog_reload(arg.reload)
if arg.reload_left:
	rtlog_reload(2)
if arg.reload_right:
	rtlog_reload(1)
if arg.reload_both:
	rtlog_reload(3)
if arg.mute_left:
	rtlog_mute_left(arg.mute_left)
if arg.mute_right:
	rtlog_mute_right(arg.mute_right)
if arg.power_left:
	rtlog_power_left(arg.power_left)
if arg.power_right:
	rtlog_power_right(arg.power_right)	