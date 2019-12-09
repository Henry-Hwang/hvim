import os
import sys
import platform
import time
import datetime
import shutil
import argparse
import hashlib
from decimal import Decimal


L_PREFIX="SPK"
R_PREFIX="RCV"
DSP_R_PREFIX="SPK DSP1 Protection R cd"
DSP_L_PREFIX="RCV DSP1 Protection L cd"
AMP_FACTOR=5.8571


class Amp:
	def __init__(self,conf):
		self.conf = conf

	#RCV DSP1 Protection L cd CSPL_COMMAND
	# convert 32bit string to int
	# '01 02 0A 0B' --> 0x01020A0B
	def mixer_32b_parser(self, string):
		int32 = string.split(':')[1]
		int32 = int32.replace(' ','')
		int32 = int(int32, 16)
		return int32
	# convert String to int list
	#  '00  00  2b  94  00  00  2b  fb  00  17  6d  b7  00  17  6d  b7'
	#  --> 0x00002b94, 0x00002bfb, 0x00176db7, 0x00176db7
	def rtlog_data_parser(self, rt):
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
	def mixer_cmd(self, control, prefixed, value):
		model_get = "adb shell \"tinymix \'PREFIX CONTROL\'\""
		model_set = "adb shell \"tinymix \'PREFIX CONTROL\' VALUE\""
		
		model=""
		if (value=="null"):
			model = model_get.replace("PREFIX", prefixed).replace("CONTROL", control)
		else:
			model = model_set.replace("PREFIX", prefixed).replace("CONTROL", control)
			model = model.replace("VALUE", value)
		return model
	
	def dsp_mixer_set_value(self, control, prefixed, value):
		cmd = self.mixer_cmd(control, prefixed, value)
		print(cmd)
		os.system(cmd)
		return
	
	def dsp_mixer_get_value(self, lr):
		cmd = self.mixer_cmd(control, prefixed, "null")
		#print(cmd)
		string = os.popen(cmd)
		ret = string.read()
		return ret
	
	
	def mixer_set_value(self, control, prefixed, value):
		cmd = self.mixer_cmd(control, prefixed, value)
		print(cmd)
		os.system(cmd)
		return
	
	def mixer_get_value(self, control, prefixed):
		cmd = self.mixer_cmd(control, prefixed, "null")
		#print(cmd)
		string = os.popen(cmd)
		ret = string.read()
		return ret
	
	def mute(self, op):
		if (op[1]=="mute"):
		    value = "0"
		else:
		    value = "1"
	
		if(op[0]=="left"):
			self.mixer_set_value("AMP Enable", R_PREFIX, value)
		elif(op[0]=="right"):
			self.mixer_set_value("AMP Enable", L_PREFIX, value)
		elif(op[0]=="all"):
			self.mixer_set_value("AMP Enable", R_PREFIX, value)
			self.mixer_set_value("AMP Enable", L_PREFIX, value)
		else:
			self.mixer_set_value("AMP Enable", "null", value)
		return
	
	def dsp_bypass(self, op):
		if (op[1]=="yes"):
		    value = "ASPRX1"
		else:
		    value = "DSP"
	
		if(op[0]=="left"):
			self.mixer_set_value("PCM Source", R_PREFIX, value)
		elif(op[0]=="right"):
			self.mixer_set_value("PCM Source", L_PREFIX, value)
		elif(op[0]=="all"):
			self.mixer_set_value("PCM Source", R_PREFIX, value)
			self.mixer_set_value("PCM Source", L_PREFIX, value)
		else:
			self.mixer_set_value("PCM Source", "null", value)
		return
	def rtlog_init(self, prefix):
		self.mixer_set_value("RAMESPERCAPTUREWI", prefix, "0x00 0x00 0x07 0xD0")
		self.mixer_set_value("RTLOG_VARIABLE", prefix, "0x00 0x00 0x03 0x9D 0x00 0x00 0x03 0xAE")
		self.mixer_set_value("RTLOG_COUNT", prefix, "0x00 0x00 0x00 0x02")
		self.mixer_set_value("RTLOG_CAN_READ", prefix, "0x0 0x0 0x00 0x02")
		self.mixer_set_value("RTLOG_ENABLE", prefix, "0x00 0x00 0x00 0x01")
		return
	
	def map_route(self, on_off, prefix):
	
		if (side == L_PREFIX):
			FW="Protection Left"
		elif (prefix == R_PREFIX): #right
			FW="Protection Left"
		else:
			FW="Protection"
	
		if(on_off == "on"):
			self.mixer_set_value("PCM Source", prefix, "DSP")
			self.mixer_set_value("DSP1 Firmware", prefix, FW)
			self.mixer_set_value("AMP Enable Switch", prefix, "1")
		else:
			self.mixer_set_value("DSP Booted", prefix, "0")
			self.mixer_set_value("DSP1 Firmware", prefix, FW)
			self.mixer_set_value("AMP Enable Switch", prefix, "0")
		return
	
	def firmware_reload(self, side):
		if(side == 2):
			self.map_route("off", L_PREFIX)
			time.sleep(1)
			self.map_route("on", L_PREFIX)
		elif (side == 1):
			self.map_route("off", R_PREFIX)
			time.sleep(1)
			self.map_route("on", R_PREFIX)
		else:
			self.map_route("off", R_PREFIX)
			self.map_route("off", L_PREFIX)
			time.sleep(1)
			self.map_route("on", R_PREFIX)
			self.map_route("on", L_PREFIX)
		return
	
	# read RT data
	def get_rtlog_data(self, prefix):
		ret = self.mixer_get_value("RTLOG_DATA", prefix)
		#print ret
		return ret
	
	# read calibration Z
	def get_cal_z_value(self, prefix):
		ret = self.mixer_get_value("CAL_R", prefix)
		return ret
	# read temperature
	def get_cspl_temperature(self, prefix):
		ret = self.mixer_get_value("CSPL_TEMPERATURE", prefix)
		return ret
	
	def get_cspl_ambient(self, prefix):
		ret = self.mixer_get_value("CAL_AMBIENT", prefix)
		return ret
	
	def rtlog_info(self, prefix):
		rowdata = self.get_rtlog_data(prefix)
		z_min, z_max, factor_min, factor_max = self.rtlog_data_parser(rowdata)
	
		rowdata = self.get_cspl_temperature(prefix)
		temp = self.mixer_32b_parser(rowdata)
	
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
	
	def show_temp(self, count):
		rawdata = self.get_cal_z_value(DSP_L_PREFIX)
		cal_z_l = self.mixer_32b_parser(rawdata)
	
		rawdata = self.get_cal_z_value(DSP_R_PREFIX)
		cal_z_r = self.mixer_32b_parser(rawdata)
		
		rawdata = self.get_cspl_ambient(DSP_L_PREFIX)
		ambient = self.mixer_32b_parser(rawdata)
	
		#get calibration value of L/R, Q10.13
		cal_z_r = Decimal(AMP_FACTOR * cal_z_r/(2<<12))
		cal_z_l = Decimal(AMP_FACTOR * cal_z_l/(2<<12))
		ambient = Decimal(ambient)
	
		print ("Ambient: %d Celsius degree," %ambient, "CAL Left: %3.2f (ohm)," %cal_z_l, "CAL Right: %3.2f (ohm)" %cal_z_r)
		print ("-------------------------------------------------------")
		for i in range(count):
			#get calibration value of L/R, Q10.13
			rawdata = self.get_cspl_temperature(DSP_R_PREFIX)
			temp_r = self.mixer_32b_parser(rawdata)
	
			rawdata = self.get_cspl_temperature(DSP_L_PREFIX)
			temp_l = self.mixer_32b_parser(rawdata)
		
			#Q9.14
			temp_r = Decimal(temp_r)/Decimal(2<<13)
			#Q9.14
			temp_l = Decimal(temp_l)/Decimal(2<<13)
			print (" TEMP (%3.2f, " %temp_l, "%3.2f)" %temp_r)
			time.sleep(1)
		return
	
	def show_detail(self, count):
		self.rtlog_init(DSP_R_PREFIX)
		self.rtlog_init(DSP_L_PREFIX)
		
		rawdata = self.get_cal_z_value(DSP_L_PREFIX)
		cal_z_l = self.mixer_32b_parser(rawdata)
	
		rawdata = self.get_cal_z_value(DSP_R_PREFIX)
		cal_z_r = self.mixer_32b_parser(rawdata)
	
		#get calibration value of L/R, Q10.13
		cal_z_r = Decimal(AMP_FACTOR * cal_z_r/(2<<12))
		cal_z_l = Decimal(AMP_FACTOR * cal_z_l/(2<<12))
		print (" CAL (%3.2f, " %cal_z_l, "%3.2f)" %cal_z_r ,"  FACTOR (%3.4f," %5.8571, "%3.4f)" %5.8571)
	
		#for i in range(count):
		l_z_min, l_z_max, l_temp = self.rtlog_info(DSP_L_PREFIX)
		r_z_min, r_z_max, r_temp = self.rtlog_info(DSP_R_PREFIX)
		print ("L (%3.2f" %l_z_min, " %3.2f )ohm"  %l_z_max, "  R (%3.2f" %r_z_min, " %3.2f )ohm"  %r_z_max, "  T (%3.2f," %l_temp, "%3.2f)C" %r_temp)
		time.sleep(1)
		return
