import os
import sys
import platform
import time
import datetime
import shutil
import argparse
import hashlib
from regmap import Regmap
from decimal import Decimal
from tool import Tool

class Amp(Regmap):
	def __init__(self, dict):
		self.dict = dict
		self.comport = self.dict["property"]["comport"]
		self.prefix = self.dict["property"]["prefix"]
		self.dsp_prefix = self.dict["property"]["dsp prefix"]
		self.factor = float(self.dict["property"]["factor"])
		self.channel = self.dict["property"]["channel"]
		self.fw_str = self.dict["property"]["fw str"]
		super().__init__(self.comport)
		return

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

	def execute(self, op):
		model = "adb shell \"@CMDS\""
		model_d = "sleep @TIME"
		mixers = self.dict[op]["cmds"]
		for index, item in enumerate(mixers):
			if "@SEC-DELAY" in item:
				sec = item.replace("@SEC-DELAY ", "").strip()
				mixers[index] = Tool.MODEL_S_SLEEP.replace("@TIME", sec)

		cmds = ";".join(mixers)
		model = Tool.MODEL_ADBSH.replace("@CMDS", cmds)
		print(model.replace(";","\n"))
		os.system(model)
		return

	# The command should look like this:
	# adb shell " tinymix 'PCM Source' 'DSP'"
	def mixer_cmd(self, control, prefixed, value):
		model_get = "adb shell \"tinymix \'@PREFIX @CONTROL\'\""
		model_set = "adb shell \"tinymix \'@PREFIX @CONTROL\' @VALUE\""
		
		model=""
		if (value=="null"):
			model = model_get.replace("@PREFIX", prefixed).replace("@CONTROL", control)
		else:
			model = model_set.replace("@PREFIX", prefixed).replace("@CONTROL", control)
			model = model.replace("@VALUE", value)
		return model
	
	def dsp_mixer_set_value(self, control, value):
		cmd = self.mixer_cmd(control, self.dsp_prefix, value)
		print(cmd)
		os.system(cmd)
		return
	
	def dsp_mixer_get_value(self, control):
		cmd = self.mixer_cmd(control, self.dsp_prefix, "null")
		#print(cmd)
		string = os.popen(cmd)
		ret = string.read()
		return ret
	
	def mixer_set_value(self, control, value):
		cmd = self.mixer_cmd(control, self.prefix, value)
		print(cmd)
		os.system(cmd)
		return
	
	def mixer_get_value(self, control):
		cmd = self.mixer_cmd(control, self.dsp_prefix, "null")
		#print(cmd)
		string = os.popen(cmd)
		ret = string.read()
		return ret
	
	def digital_volume(self, vol):
		self.mixer_set_value("Digital PCM Volume", vol)
		return

	def pcm_gain(self, vol):
		self.mixer_set_value("AMP PCM Gain", vol)
		return
	def digital_volume(self, vol):
		self.mixer_set_value("Digital PCM Volume", vol)
		return
	def pcm_gain(self, vol):
		self.mixer_set_value("AMP PCM Gain", vol)
		return

	def rtlog_init(self):
		self.dsp_mixer_set_value("RAMESPERCAPTUREWI", "0x00 0x00 0x07 0xD0")
		self.dsp_mixer_set_value("RTLOG_VARIABLE", "0x00 0x00 0x03 0x9D 0x00 0x00 0x03 0xAE")
		self.dsp_mixer_set_value("RTLOG_COUNT", "0x00 0x00 0x00 0x02")
		self.dsp_mixer_set_value("RTLOG_CAN_READ", "0x0 0x0 0x00 0x02")
		self.dsp_mixer_set_value("RTLOG_ENABLE", "0x00 0x00 0x00 0x01")
		return
	
	# read RT data
	def get_rtlog_data(self):
		ret = self.dsp_mixer_get_value("RTLOG_DATA")
		#print ret
		return ret
	
	# read calibration Z
	def get_cal_z_value(self):
		raw = self.dsp_mixer_get_value("CAL_R")
		cal_z = self.mixer_32b_parser(raw)
		#get calibration value of L/R, Q10.13
		cal_z = Decimal(self.factor * cal_z/(2<<12))
		return cal_z
	# read temperature
	def get_cspl_temperature(self):
		raw = self.dsp_mixer_get_value("CSPL_TEMPERATURE")
		temp = self.mixer_32b_parser(raw)
		#Q9.14
		temp = Decimal(temp)/Decimal(2<<13)
		return temp
	
	def get_cspl_ambient(self):
		raw = self.dsp_mixer_get_value("CAL_AMBIENT")
		ambient = self.mixer_32b_parser(raw)
		ambient = Decimal(ambient)
		return ambient
	
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
		cal_z = self.get_cal_z_value()
		ambient = self.get_cspl_ambient()
	
		print ("Ambient: %d Celsius degree," %ambient, "CAL : %3.2f (ohm)," %cal_z)
		print ("-------------------------------------------------------")
		for i in range(count):
			#get calibration value of L/R, Q10.13
			temp = self.get_cspl_temperature()
	
			print ("TEMP (%3.2f)" %temp)
			time.sleep(1)
		return
	
	def show_detail(self, count):
		self.rtlog_init()
		rawdata = self.get_cal_z_value()
		cal_z = self.mixer_32b_parser(rawdata)
		#get calibration value of L/R, Q10.13
		cal_z = Decimal(self.factor * cal_z/(2<<12))
		print (" CAL (%3.2f, " %cal_z ," FACTOR (%3.4f," %5.8571, "%3.4f)" %5.8571)
	
		#for i in range(count):
		z_min, z_max, temp = self.rtlog_info()
		print ("L (%3.2f" %z_min,"  R (%3.2f" %z_min, "%3.2f)C" %temp)
		time.sleep(1)
		return
