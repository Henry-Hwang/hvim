import os
import sys
import platform
import time
import datetime
import shutil
import argparse
import hashlib
from decimal import Decimal
from tool import Tool
from conf import Conf
PB_DICT = {
	# custommer
	"project name":"M2091",
	"customer":"MEIZU",
	
	# capi v2
	"playback version" : "4",
	"capiv2 directory"       :"/home/hhuang/capiv2/",
	"capiv2 lib directory"   :"/home/hhuang/capiv2/capi_v2_cirrus_cspl/LLVM_Debug/",
	"capiv2 lib"             :"/home/hhuang/capiv2/capi_v2_cirrus_cspl/LLVM_Debug/capi_v2_cirrus_cspl.so",
	"source tuning directory":"/home/hhuang/capiv2/capi_v2_cirrus_cspl/include/tuningheaders/",
	"compat.c"               :"/home/hhuang/capiv2/capi_v2_cirrus_cspl/source/compat.c",
	
	# android device
	"capiv2 directory device":"/vendor/lib/rfsa/adsp/",
	"capiv2 lib device"      :"/vendor/lib/rfsa/adsp/capi_v2_cirrus_sp.so",
}
class Playback:
	def __init__(self):
		self.conf = PB_DICT
		self.readme = {}

	def capiv2_lib_info(self):
		branch = self.get_work_branch(self.conf["capiv2 directory"])
		list_chksum = self.get_mult_checksum(self.conf["compat.c"])
		#for it in list_chksum:
		#	print(it)
		now = datetime.datetime.now()
		self.readme["branch"] = branch
		self.readme["build time"] = now.strftime('%a %b %d %Y %H:%M:%S')
		self.readme["list checksum"] = list_chksum
	
		return

	def lib_copy_zip(self, dir_output):
		conf = self.conf
		now_str = Tool.date_to_str()#now.strftime('%a-%b-%d-%Y_%H-%M-%S')
		
		new_dir = dir_output + "/capi_v2_" + now_str + "/"
		os.mkdir(new_dir)

			
		print(new_dir)
		if (os.path.exists(new_dir)==False):
			print("ERROR: Tuning not founf!")
			return

		# Copy tuning file
		for key, tuning in self.conf["tunings"].items():
			shutil.copy(tuning, new_dir)

		#Copy lib
		lib = self.conf["capiv2 lib"]
		if (os.path.exists(lib)==False):
			shutil.rmtree(new_dir)
			return

		self.readme["lib md5sum"] = Tool.md5sum(lib)
		shutil.copy(lib, new_dir)

		self.new_readme_files(new_dir)

		Tool.zip(new_dir)
		return

	def new_readme_files(self, dir_out):
		model_readme = "@NAME: @STRING\n"
		f_readme = dir_out + "readme.txt"

		[dirname,filename] = os.path.split(self.conf["capiv2 lib"])
		with open(f_readme, "w+") as cfw:
			cfw.write(model_readme.replace("@NAME", "LIB").replace("@STRING",filename))
			cfw.write(model_readme.replace("@NAME", "BUILD TIME").replace("@STRING",self.readme["build time"]))
			cfw.write(model_readme.replace("@NAME", "BRANCH").replace("@STRING",self.readme["branch"]))
			cfw.write(model_readme.replace("@NAME", "MD5SUM").replace("@STRING",self.readme["lib md5sum"]))
			for it in self.readme["list checksum"]:
				#print(it)
				cfw.write(model_readme.replace("@NAME", "CHECKSUM").replace("@STRING",it))
			cfw.write(model_readme.replace("@NAME", "PUSH").replace("@STRING",""))
			cfw.write("\tadb root\n")
			cfw.write("\tadb remount\n")
			cfw.write("\tadb push capi_v2_cirrus_cspl.so /vendor/lib/rfsa/adsp/capi_v2_cirrus_sp.so\n")


		# adb push script
		f_script = dir_out + "push.txt"
		with open(f_script, "w+") as cfw:
				cfw.write("@echo off\n")
				cfw.write("rem : rename 'push.txt' as 'push.bat' and run\n")
				cfw.write("adb wait-for-device root\n")
				cfw.write("adb wait-for-device remount\n")
				cfw.write("adb wait-for-device\n")
				cfw.write("adb push capi_v2_cirrus_cspl.so /vendor/lib/rfsa/adsp/capi_v2_cirrus_sp.so\n")
		return

	def get_work_branch(self, repo):
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
	def get_all_tunings(self, c_compat):
		patten = "#define USE_CASE_@INDEX_TUNING@_NBITS \"tuningheaders/"
		dict_tuning={}
		with open(c_compat, "r") as cfr:
			count = 0;
			lines = cfr.readlines()
			for index, line in enumerate(lines):
				uc_bit = ""
				if patten.replace("@INDEX", "0").replace("@_NBITS", "") in line:
					uc_bit = "UC0_16BIT"
				elif patten.replace("@INDEX", "1").replace("@_NBITS", "") in line:
					uc_bit = "UC1_16BIT"
				elif patten.replace("@INDEX", "2").replace("@_NBITS", "") in line:
					uc_bit = "UC2_16BIT"
				elif patten.replace("@INDEX", "3").replace("@_NBITS", "") in line:
					uc_bit = "UC3_16BIT"
				elif patten.replace("@INDEX", "0").replace("@_NBITS", "_24BIT") in line:
					uc_bit = "UC0_24BIT"
				elif patten.replace("@INDEX", "1").replace("@_NBITS", "_24BIT") in line:
					uc_bit = "UC1_24BIT"
				elif patten.replace("@INDEX", "2").replace("@_NBITS", "_24BIT") in line:
					uc_bit = "UC2_24BIT"
				elif patten.replace("@INDEX", "3").replace("@_NBITS", "_24BIT") in line:
					uc_bit = "UC3_24BIT"
	
				if(uc_bit==""):
					continue
				# Just care about first 8 tuning
				count = 1 + count
				if(count > 8):
					break

				line = line.replace("\"", "").strip()
				[dirname,filename] = os.path.split(line)
				f_tuning = self.conf["source tuning directory"] + filename
				if (os.path.exists(f_tuning)==False):
					continue
				dict_tuning[uc_bit] = f_tuning
		return dict_tuning
	
	def get_mult_checksum(self, c_compat):
		patten = "#define USE_CASE_@INDEX_TUNING@_NBITS \"tuningheaders/"
		list_chksum=[]
		dict_tuning = self.conf["tunings"]

		for key, value in dict_tuning.items():
			dict_chksum = self.get_one_checksum(value)
			list_chksum.append(str(dict_chksum) + " : " + key + " : " + value)

		return list_chksum
	
	def get_one_checksum(self, f_tuning):
		
		#"CSPL_CONFIG_RX_RIGHT"
		#"CSPL_CONFIG_RX_LEFT"
		#"CSPL_CONFIG_TX_RIGHT"
		#"CSPL_CONFIG_TX_LEFT"
		if (self.conf["playback version"] == "4"):
			patten = "CSPL_CONFIG_@TXRX"
		else:
			patten = "CSPL_CONFIG_@TXRX_@LR"
	
		dict_chksum = {}
		with open(f_tuning, "r") as cfr:
			lines = cfr.readlines()
			for line in lines:
				if (self.conf["playback version"] == "4"):
					if patten.replace("@TXRX", "RX") in line:
						elements = line.split(",")
						dict_chksum["rx"] = elements[len(elements) - 1].strip()
					elif patten.replace("@TXRX", "TX") in line:
						elements = line.split(",")
						dict_chksum["tx"] = elements[len(elements) - 1].strip()
				else:
					if patten.replace("@TXRX", "RX").replace("@LR", "RIGHT") in line:
						elements = line.split(",")
						dict_chksum["rx left"] = elements[len(elements) - 1].strip()
					elif patten.replace("@TXRX", "RX").replace("@LR", "LEFT") in line:
						elements = line.split(",")
						dict_chksum["rx right"] = elements[len(elements) - 1].strip()
					elif patten.replace("@TXRX", "TX").replace("@LR", "RIGHT") in line:
						elements = line.split(",")
						dict_chksum["tx right"] = elements[len(elements) - 1].strip()
					elif patten.replace("@TXRX", "TX").replace("@LR", "LEFT") in line:
						elements = line.split(",")
						dict_chksum["tx left"] = elements[len(elements) - 1].strip()
	
		#print(dict_chksum)
		return dict_chksum
	
	
	# @c_file : [compat.c] which include @tuning
	# @tuning : [*.h/txt] tuning file
	# @bit : [16/24] 16bit/24bit tuning
	def update_tuning_in_c_file(self, c_file, tuning, bit, usecase):
		print("3 args")
		dir_tuning = self.conf["source tuning directory"]
		if (bit==24):
			patten = "#define USE_CASE_@USECASE_TUNING_24BIT \"tuningheaders/"
			model = "#define USE_CASE_@USECASE_TUNING_24BIT \"tuningheaders/@NEW_TUNING\"\n"
		else:
			patten = "#define USE_CASE_@USECASE_TUNING \"tuningheaders/"
			model = "#define USE_CASE_@USECASE_TUNING \"tuningheaders/@NEW_TUNING\"\n"

		patten = patten.replace("@USECASE", str(usecase))
		model = model.replace("@USECASE", str(usecase))

		[dirname,filename] = os.path.split(tuning)
		shutil.copyfile(tuning, dir_tuning+filename)
	
		with open(c_file, "r") as cfr:
			lines = cfr.readlines()
		with open(c_file, "w") as cfw:
			for index, line in enumerate(lines):
				if patten in line:
					# Just care about first 2 tuning
					line = model.replace("@NEW_TUNING", filename)
					patten = "SKIP-THE-REST-LINES"
				cfw.write(line)
		return
	def tuning_update(self, c_file, tuning, bit, usecase):
		dir_tuning = self.conf["source tuning directory"]
		if (bit==24):
			patten = "#define USE_CASE_@USECASE_TUNING_24BIT \"tuningheaders/"
			model = "#define USE_CASE_@USECASE_TUNING_24BIT \"tuningheaders/@NEW_TUNING\"\n"
		else:
			patten = "#define USE_CASE_@USECASE_TUNING \"tuningheaders/"
			model = "#define USE_CASE_@USECASE_TUNING \"tuningheaders/@NEW_TUNING\"\n"

		patten = patten.replace("@USECASE", str(usecase))
		model = model.replace("@USECASE", str(usecase))

		[dirname,filename] = os.path.split(tuning)
		shutil.copyfile(tuning, dir_tuning+filename)
	
		with open(c_file, "r") as cfr:
			lines = cfr.readlines()
		with open(c_file, "w") as cfw:
			for index, line in enumerate(lines):
				if patten in line:
					# Just care about first 2 tuning
					line = model.replace("@NEW_TUNING", filename)
					patten = "SKIP-THE-REST-LINES"
				cfw.write(line)
		return

	def update_tuning(self, c_file, tuning, bit):
		self.update_tuning_in_c_file(c_file, tuning, bit, "0")
		return

	def covert_tuning(self, f_tuning):
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
	
	def make_capi_v2(self, make, tuning, bit, uc, ver):
		if (platform.system() != "Windows"):
			model = "cd ~/capiv2 && ./cygwin-make-setup-sdk3.4.3.sh && cd -"
			if (os.path.exists(tuning)==True):
				tuning = self.covert_tuning(tuning)
				self.tuning_update(self.conf["compat.c"], tuning, bit, uc)
				self.conf["tuning"] = tuning
			
			print("Tuning: " + tuning + ", BIT = ", bit, ", usecase = ", uc, "version = ", ver)
			self.conf["playback version"] = str(ver)
			if not os.path.exists(tuning):
				print("No tuning file input!")
				return
			[dirname,filename] = os.path.split(tuning)
			#build lib
			if (make=='Y'):
				os.system(model)
				self.conf["tunings"] = self.get_all_tunings(self.conf["compat.c"])
				self.capiv2_lib_info()
				self.lib_copy_zip(dirname + "/")

		return
