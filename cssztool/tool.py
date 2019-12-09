import os
import sys
import platform
import time
import datetime
import shutil
import argparse
import hashlib
import zipfile
from decimal import Decimal

class Tool:
	@classmethod
	def show_op_sys(self):
		print(platform.system())
		print(platform.platform())
		print(platform.version())
		print(platform.architecture())
		print(platform.machine())
		print(platform.node())
		print(platform.processor())
		return

	@classmethod
	def md5sum(self, source):
		fd = open(source)
		md5 = hashlib.md5()
		md5.update(fd.read().encode('utf-8'))
		value = md5.hexdigest()
		print(value)
		return value

	@classmethod
	def zip(self, start_dir):
		start_dir = start_dir.rstrip("/").rstrip("\\")  # 要压缩的文件夹路径
		file_news = start_dir + '.zip'  # 压缩后文件夹的名字
		print(start_dir, file_news)

		z = zipfile.ZipFile(file_news, 'w', zipfile.ZIP_DEFLATED)
		for dir_path, dir_names, file_names in os.walk(start_dir):
			f_path = dir_path.replace(start_dir, '')  # 这一句很重要，不replace的话，就从根目录开始复制
			f_path = f_path and f_path + os.sep or ''  # 实现当前文件夹以及包含的所有文件的压缩
			for filename in file_names:
				z.write(os.path.join(dir_path, filename), f_path + filename)
		z.close()
		return file_news
