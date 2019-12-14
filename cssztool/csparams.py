import os
import sys
import platform
import time
import datetime
import shutil
import hashlib
from tool import Tool
from conf import Conf
DEFAULT_CONFIG = {
        "params": ["/vendor/firmware/cs35l41-dsp1-diag.wmfw",
                 "/vendor/firmware/cs35l41-dsp1-spk-prot-left.wmfw",
                 "/vendor/firmware/cs35l41-dsp1-spk-prot-right.wmfw"
                 "/vendor/firmware/cs35l41-dsp1-spk-prot-left.bin",
                 "/vendor/firmware/cs35l41-dsp1-spk-prot-right.bin"
                 "/vendor/firmware/cs35l41-dsp1-rcv-dt-handfree.txt",
                 "/vendor/firmware/cs35l41-dsp1-rcv-dt-music.txt",
                 "/vendor/firmware/cs35l41-dsp1-spk-dt-handfree.txt",
                 "/vendor/firmware/cs35l41-dsp1-spk-dt-music.txt",
                 "/vendor/lib/rfsa/adsp/capi_v2_cirrus_sp.so",
                 "/vendor/bin/cirrus_sp_status_rx",
                 "/vendor/bin/cirrus_sp_load_tuning",
                 "/vendor/etc/mixer_path_meizu.xml",
                 #"/vendor/etc/acdbdata/*",
                 #"/vendor/lib/hw/audio.primary.kona.so",
                 "/vendor/lib/modules/audio_q6.ko",
                 "/vendor/lib/modules/audio_cs35l41.ko",
                ],
}
CONFIG="csparam_conf.json"
class Csparams:
	def __init__(self):
		path = Tool.get_root_path(CONFIG)
		if (os.path.exists(path)==True):
			self.dict = Conf.read(path)
		else:
			self.dict = DEFAULT_CONFIG
		return
	
	def backup(self, dir_bk):
		model = "adb pull @PATH @DEST"
		if (os.path.exists(dir_bk)==False):
			os.mkdir(dir_bk)
		params = self.dict["params"]
		for key, value in params.items():
			[dirname,filename] = os.path.split(value)
			dir_dest = dir_bk + dirname
			if (os.path.exists(dir_dest)==False):
				os.makedirs(dir_dest)
			model_t = model.replace("@PATH", value).replace("@DEST", dir_dest)
			#print(model_t)
			os.system(model_t)
		
		Tool.tree(dir_bk)
#		for i in Tool.tree(dir_bk):
#			print(i,end='')
		return

	def restore(self, dir_bk):
		print(self.dict)
		model = "adb push @PATH @DEST"
		if (os.path.exists(dir_bk)==False):
			print("ERROR: no files for backup")
			return

		#TODO: get all files to bk_list
		bk_list = []
		for rootdir, dirs, files in os.walk(dir_bk):
			for file in files:
				t_file = os.path.join(rootdir, file)
				bk_list.append(t_file)

		#list dict
		params = self.dict["params"]
		for key, value in params.items():
			[dirname,filename] = os.path.split(value)
			for it in bk_list:
				if value in it:
					model_t = model.replace("@PATH", it).replace("@DEST", value)
					#print(model_t)
					os.system(model_t)
		return

