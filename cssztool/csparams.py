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
    "params": {
	   "diag fw":"/vendor/firmware/cs35l41-dsp1-diag.wmfw",
           "left fw":"/vendor/firmware/cs35l41-dsp1-spk-prot-left.wmfw",
           "right fw":"/vendor/firmware/cs35l41-dsp1-spk-prot-right.wmfw",
           "left bin":"/vendor/firmware/cs35l41-dsp1-spk-prot-left.bin",
           "right bin":"/vendor/firmware/cs35l41-dsp1-spk-prot-right.bin",
           "rcv hf dt": "/vendor/firmware/cs35l41-dsp1-rcv-dt-handfree.txt",
           "rcv m dt": "/vendor/firmware/cs35l41-dsp1-rcv-dt-music.txt",
           "spk hf dt": "/vendor/firmware/cs35l41-dsp1-spk-dt-handfree.txt",
           "spk m dt": "/vendor/firmware/cs35l41-dsp1-spk-dt-music.txt",
           "capiv2 lib": "/vendor/lib/rfsa/adsp/capi_v2_cirrus_sp.so",
           "status tool": "/vendor/bin/cirrus_sp_status_rx",
           "load tool": "/vendor/bin/cirrus_sp_load_tuning",
           "ucm": "/vendor/etc/mixer_paths_meizu.xml",
           "hal so": "/vendor/lib/hw/audio.primary.kona.so",
           "q6 ko": "/vendor/lib/modules/audio_q6.ko",
           "amp ko": "/vendor/lib/modules/audio_cs35l41.ko"
    }
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
		return

	def restore(self, dir_bk):
		model = "adb push @PATH @DEST"
		if (os.path.exists(dir_bk)==False):
			print("ERROR: no files for backup")
			return

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
				# Note: Windows / and  \
				if value in it.replace("\\", "/"):
					model_t = model.replace("@PATH", it).replace("@DEST", value)
					#print(model_t)
					os.system(model_t)
		return

