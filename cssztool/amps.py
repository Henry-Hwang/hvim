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
from conf import Conf
from tool import Tool

DEFAULT_CONFIG = {
        "number": "2",
        "left": {
		"prefix"    : "RCV",
		"dsp prefix": "RCV DSP1 Protection L cd",
		"factor"    : "5.8571",
		"channel"   : "left",
		"fw str"    : "\'Protection Left\'",
		"comport"   : "spi1.0",
        },
        "right": {
                "prefix"    : "SPK",
		"dsp prefix": "SPK DSP1 Protection R cd",
		"factor"    : "5.8571",
		"channel"   : "right",
		"fw str"    : "\'Protection Right\'",
		"comport"   : "spi1.1",
        },
}
CONFIG="amps_conf.json"
class Amps:
	def __init__(self):
		path = Tool.get_root_path(CONFIG)
		if (os.path.exists(path)==True):
		    self.dict = Conf.read(path)
		else:
		    self.dict = DEFAULT_CONFIG
		self.amp_r = Amp(self.dict["right"])
		self.amp_l = Amp(self.dict["left"])
	
		return
	
	def show_temp(self, count):
		if (int(self.dict["number"]) == 2):
			calz_l = self.amp_l.get_cal_z_value()
			calz_r = self.amp_r.get_cal_z_value()
			ambient = self.amp_l.get_cspl_ambient()
		
			print ("Ambient: %d Celsius degree," %ambient,
				"CAL : %3.2f (ohm)," %calz_l,
				"CAL : %3.2f (ohm)," %calz_r)
			print ("-------------------------------------------------------")
			for i in range(count):
				#get calibration value of L/R, Q10.13
				temp_l = self.amp_l.get_cspl_temperature()
				temp_r = self.amp_r.get_cspl_temperature()
		
				print ("TEMP ( %3.2f, " %temp_l, "%3.2f )" %temp_r)
				time.sleep(1)
		elif (self.dict["number"] == 1):
			self.amp_l.show_temp(count)
		return

	def mute(self, op):
		channel = op[0]
		on = op[1]
		if(channel == "left" or channel == "mono"):
			self.amp_l.mute(on)
		elif(channel == "right"):
			self.amp_r.mute(on)
		else:
			self.amp_l.mute(on)
			self.amp_r.mute(on)
		return
	def digital_volume(self, vol):
		channel = op[0]
		on = op[1]
		if(channel == "left" or channel == "mono"):
			self.amp_l.digital_volume(vol)
		elif(channel == "right"):
			self.amp_r.digital_volume(vol)
		else:
			self.amp_l.digital_volume(vol)
			self.amp_r.digital_volume(vol)
		return


	def dsp_bypass(self, op):
		channel = op[0]
		bypass = op[1]
		if(channel == "left" or channel == "mono"):
			self.amp_l.dsp_bypass(bypass)
		elif(channel == "right"):
			self.amp_r.dsp_bypass(bypass)
		else:
			self.amp_l.dsp_bypass(bypass)
			self.amp_r.dsp_bypass(bypass)
		return

	def regs_write(self, op):
		channel = op[0]
		regval = op[1]
	
		if(channel == "left" or channel == "mono"):
			self.amp_l.regs_write(regval)
		elif(channel == "right"):
			self.amp_r.regs_write(regval)
		else:
			self.amp_l.regs_write(regval)
			self.amp_r.regs_write(regval)
		
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
			regset = self.amp_l.regs_read(regs)
			for it in regset:
				print(it)
		elif(channel == "right"):
			regset = self.amp_r.regs_read(regs)
			for it in regset:
				print(it)
		else:
			lregset = self.amp_l.regs_read(regs)
			rregset = self.amp_r.regs_read(regs)

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
			lines = self.amp_l.regs_dump()
			for index, item in enumerate(lines):
				print(item)
				if(index >= count):
				    break

			name, comport, cache = self.amp_l.get_info()
			date = Tool.date_to_str()
			#cs35l41-spi1.0-N-2019-12-06_21-35-46.txt
			filename = name + "-" + comport + "-" + cache+ "-" + date + ".txt"

			Tool.file_write_lines(filename, lines, count)

		elif(channel == "right"):
			lines = self.amp_r.regs_dump()
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

			lines_l = self.amp_l.regs_dump()
			lines_r = self.amp_r.regs_dump()

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

	def reload(self, op):
		model = "@REG - @VLEFT  @VRIGHT"
		channel = op[0]
		regs = op[1]

		if(channel == "left" or channel == "mono"):
			regset = self.amp_l.reload()
		elif(channel == "right"):
			regset = self.amp_r.reload()
		else:
			regset = self.amp_l.reload()
			regset = self.amp_r.reload()
		return
