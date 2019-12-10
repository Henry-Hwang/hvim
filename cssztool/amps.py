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
from tool import Tool

class Amps:
	def __init__(self):
		conf = {}
		list_amp = []
		self.conf = {}
		self.conf["number"] = 2
		
		conf["prefix"] = "SPK"
		conf["dsp prefix"] = "SPK DSP1 Protection R cd"
		conf["factor"] = 5.8571
		conf["channel"] = "right"
		conf["fw str"] ="Protection Right"
		conf["comport"] = "spi1.0"
		self.conf["right"] = Amp(conf)

		conf["prefix"] = "RCV"
		conf["dsp prefix"] = "RCV DSP1 Protection L cd"
		conf["factor"] = 5.8571
		conf["channel"] = "left"
		conf["fw str"] ="Protection Left"
		conf["comport"] = "spi1.1"
		self.conf["left"] = Amp(conf)
		
		return
	
	def show_temp(self, count):
		if (self.conf["number"] == 2):
			amp_l = self.conf["left"]
			amp_r = self.conf["right"]
			calz_l = amp_l.get_cal_z_value()
			calz_r = amp_r.get_cal_z_value()
			ambient = amp_l.get_cspl_ambient()
		
			print ("Ambient: %d Celsius degree," %ambient,
				"CAL : %3.2f (ohm)," %calz_l,
				"CAL : %3.2f (ohm)," %calz_r)
			print ("-------------------------------------------------------")
			for i in range(count):
				#get calibration value of L/R, Q10.13
				temp_l = amp_l.get_cspl_temperature()
				temp_r = amp_r.get_cspl_temperature()
		
				print ("TEMP ( %3.2f, " %temp_l, "%3.2f )" %temp_r)
				time.sleep(1)
		elif (self.conf["number"] == 1):
			amp_l = self.conf["left"]
			amp_l.show_temp(count)
		return

	def mute(self, op):
		channel = op[0]
		on = op[1]
		if(channel == "left" or channel == "mono"):
			amp_l = self.conf["left"]
			amp_l.mute(on)
		elif(channel == "right"):
			amp_r = self.conf["right"]
			amp_r.mute(on)
		else:
			amp_l = self.conf["left"]
			amp_l.mute(on)
			amp_r = self.conf["right"]
			amp_r.mute(on)
		return

	def dsp_bypass(self, op):
		channel = op[0]
		bypass = op[1]
		if(channel == "left" or channel == "mono"):
			amp_l = self.conf["left"]
			amp_l.dsp_bypass(bypass)
		elif(channel == "right"):
			amp_r = self.conf["right"]
			amp_r.dsp_bypass(bypass)
		else:
			amp_l = self.conf["left"]
			amp_l.dsp_bypass(bypass)
			amp_r = self.conf["right"]
			amp_r.dsp_bypass(bypass)
		return

	def regs_write(self, op):
		channel = op[0]
		regval = op[1]
	
		if(channel == "left" or channel == "mono"):
			amp_l =  self.conf["left"]
			amp_l.regs_write(regval)
		elif(channel == "right"):
			amp_r =  self.conf["right"]
			amp_r.regs_write(regval)
		else:
			amp_l =  self.conf["left"]
			amp_l.regs_write(regval)
			amp_r =  self.conf["right"]
			amp_r.regs_write(regval)
		
		# Read back
		wsets = regval.split(",")
		print(wsets)
		regset=""
		for index, item in enumerate(wsets):
			reg, value = item.split("=")
			if (index == len(wsets) -1):
				regset = regset + reg
			else:
				regset = regset + reg + ","
		op[1] = regset
		self.regs_read(op)

		return

	def regs_read(self, op):
		model = "@REG - @VLEFT  @VRIGHT"
		channel = op[0]
		regs = op[1]

		if(channel == "left" or channel == "mono"):
			amp_l =  self.conf["left"]
			regset = amp_l.regs_read(regs)
			for it in regset:
				print(it)
		elif(channel == "right"):
			amp_r =  self.conf["right"]
			regset = amp_r.regs_read(regs)
			for it in regset:
				print(it)
		else:
			amp_l =  self.conf["left"]
			lregset = amp_l.regs_read(regs)
			amp_r =  self.conf["right"]
			rregset = amp_r.regs_read(regs)

			print("  REG        LEFT      RIGHT")
			print("------------------------------")
			for i in range(len(lregset)):
			    kv=lregset[i].split(":")
			    model_t = model.replace("@REG", kv[0].strip()).replace("@VLEFT", kv[1])
			    kv=rregset[i].split(":")
			    model_t = model_t.replace("@VRIGHT", kv[1])
			    print(model_t)
		return

	def regs_dump(self, op):
		channel = op[0]
		count = int(op[1], 10)
		if(channel == "left" or channel == "mono"):
			amp_l = self.conf["left"]
			lines = amp_l.regs_dump()
			
			for index, item in enumerate(lines):
				print(item)
				if(index >= count):
				    break

			name, comport, cache = amp_l.get_info()
			date = Tool.date_to_str()
			#cs35l41-spi1.0-N-2019-12-06_21-35-46.txt
			filename = name + "-" + comport + "-" + cache+ "-" + date + ".txt"

			Tool.file_write_lines(filename, lines, count)

		elif(channel == "right"):
			amp_r = self.conf["right"]
			lines = amp_r.regs_dump()
			for index, item in enumerate(lines):
				print(item)
				if(index >= count):
				    break
			name, comport, cache = amp_l.get_info()
			date = Tool.date_to_str()
			#cs35l41-spi1.0-N-2019-12-06_21-35-46.txt
			filename = name + "-" + comport + "-" + cache+ "-" + date + ".txt"

			Tool.file_write_lines(filename, lines, count)
		else:
			model = "@REG  @VLEFT  @VRIGHT"

			amp_l = self.conf["left"]
			lines_l = amp_l.regs_dump()
			amp_r = self.conf["right"]
			lines_r = amp_r.regs_dump()

			for index, item in enumerate(lines_l):
				if(index >= count):
				    break
				reg, val = lines_r[index].split(":")
				lines_l[index] = lines_l[index] + "  " + val
				print(lines_l[index])

			name, comport_l, cache = amp_l.get_info()
			name, comport_r, cache = amp_r.get_info()
			date = Tool.date_to_str()
			#cs35l41-spi1.0-N-2019-12-06_21-35-46.txt
			filename = name + "-" + comport_l + "-" + comport_r + "-" + cache+ "-" + date + ".txt"

			Tool.file_write_lines(filename, lines_l, count)
		return


