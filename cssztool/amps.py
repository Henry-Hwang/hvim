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

		for key, value in self.dict.items():
			value["ampobj"] = Amp(value)

		return
	
	def show_temp(self, count, ch):
		if(ch == "all"):
			list_amp = []
			list_calz = []
			list_ambient = []
			for key, value in self.dict.items():
				list_amp.append(value["ampobj"])

			for it in list_amp:
				list_calz.append(str(round(it.get_cal_z_value(), 2)))
				list_ambient.append(str(round(it.get_cspl_ambient(),2)))
		
			print ("Ambient: " + ", ".join(list_ambient))
			print ("Calz: " + ", ".join(list_calz))
			print ("-------------------------------------------------------")
			for i in range(count):
				#get calibration value of L/R, Q10.13
				list_temp=[]
				for it in list_amp:
					list_temp.append(str(round(it.get_cspl_temperature(),2)))
		
				print ("TEMP:" + ", ".join(list_temp))
				time.sleep(1)
		else:
			amp = self.dict[ch]["ampobj"]
			calz = []
			ambient = []

			calz = str(round(amp.get_cal_z_value(), 2))
			ambient = str(round(amp.get_cspl_ambient(),2))
	
			print ("Ambient: " + ambient)
			print ("Calz: " + calz)
			print ("-------------------------------------------------------")
			for i in range(count):
				#get calibration value of L/R, Q10.13
				temp = str(round(amp.get_cspl_temperature(),2))
				print ("TEMP:" + temp)
				time.sleep(1)
		return

	def execute(self, ch, cmd):
		if(ch == "right" or ch == "left" or ch == "mono"):
			amp = self.dict[ch]["ampobj"]
			amp.execute(cmd)
		else:
			for key, value in self.dict.items():
				value["ampobj"].execute(cmd)
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


	def regs_write(self, regval, ch):
		if(ch == "all"):
			for key, value in self.dict.items():
				value["ampobj"].regs_write(regval)
		else:
			amp = self.dict[ch]["ampobj"]
			amp.regs_write(regval)

		# Read back
		wsets = regval.split(",")
		print(wsets)
		list_regset=[]
		for index, item in enumerate(wsets):
			reg, value = item.split("=")
			list_regset.append(reg)

		regs = ",".join(list_regset)
		self.regs_read(regs)

		return

	def regs_read(self, regs, ch):
		if(ch == "all"):
			list_regset = []
			for key, value in self.dict.items():
				rset = value["ampobj"].regs_read(regs)
				list_regset.append(rset)
			print("  REG        LEFT      RIGHT")
			print("------------------------------")
			for i in range(len(list_regset[0])):
				combin_line = []
				for it in list_regset:
					combin_line.append(it[i])
				model = ", ".join(combin_line)
				print(model)
		else:
			amp = self.dict[ch]["ampobj"]
			list_regset = amp.regs_read(regs)
			for it in list_regset:
				print(it)
		return

	def regs_dump(self, count, ch):
		if(ch == "all"):
			model = "@REG  @VLEFT  @VRIGHT"

			list_regset = []
			for key, value in self.dict.items():
				rset = value["ampobj"].regs_dump()
				name, comport, cache = value["ampobj"].get_info()
				list_regset.append(rset)

			combin_lines = []
			for index, item in enumerate(list_regset[0]):
				if(index >= count):
					break
				combin_line = []
				for it in list_regset:
					combin_line.append(it[index])

				outline = ", ".join(combin_line)
				
				#Add a line switch in the end
				combin_lines.append(outline+"\n")
				print(outline)

			date = Tool.date_to_str()
			#cs35l41-spi1.0-N-2019-12-06_21-35-46.txt
			filename = name + "s-" + comport + "-" + cache+ "-" + date + ".txt"

			Tool.file_write_lines(filename, combin_lines, count)
		else:
			amp = self.dict[ch]["ampobj"]
			lines = amp.regs_dump()
			for index, item in enumerate(lines):
				print(item)
				if(index >= count):
				    break

			name, comport, cache = amp.get_info()
			date = Tool.date_to_str()
			#cs35l41-spi1.0-N-2019-12-06_21-35-46.txt
			filename = name + "-" + comport + "-" + cache+ "-" + date + ".txt"

			Tool.file_write_lines(filename, lines, count)
		return
