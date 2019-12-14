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

PREFIX = ['└─ ', '├─ ']
INDENTION = ['│  ', ' '*4]
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
		'''
		fd = open(source)
		md5 = hashlib.md5()
		md5.update(fd.read().encode('utf-8'))
		value = md5.hexdigest()
		'''
		model = "md5sum @FILE"
		model = model.replace("@FILE", source)
		value = os.popen(model).read().strip()
		print(value)
		return value

	@classmethod
	def zip(self, start_dir):
		start_dir = start_dir.rstrip("/").rstrip("\\")
		file_news = start_dir + '.zip'
		print(start_dir, file_news)

		z = zipfile.ZipFile(file_news, 'w', zipfile.ZIP_DEFLATED)
		for dir_path, dir_names, file_names in os.walk(start_dir):
			f_path = dir_path.replace(start_dir, '')
			f_path = f_path and f_path + os.sep or ''
			for filename in file_names:
				z.write(os.path.join(dir_path, filename), f_path + filename)
		z.close()
		return file_news

	@classmethod
	def file_write_lines(self, path, lines, count):
		with open(path, "w+") as cfw:
			for index, item in enumerate(lines):
				cfw.write(item)
				if(index >= count):
					break
		return

	@classmethod
	def date_to_str(self):
		date = time.strftime('%Y-%m-%d_%H-%M-%S',time.localtime(time.time())).strip()
		return date

	@classmethod
	def windows_dir(self, path):
		path = path.replace("/","\\")
		return path
	def linux_dir(self, path):
		path = path.replace("\\","/")
		return path
	@classmethod
	def get_root_dir(self):
		path = os.path.abspath(sys.argv[0])
		[dirname,filename] = os.path.split(path)
		print(dirname)
		return dirname
	@classmethod
	def get_root_path(self, jfile):
		# Seach current directory first
		if (os.path.exists(jfile)==True):
			path = jfile
		else:
			path = os.path.abspath(sys.argv[0])
			[dirname,filename] = os.path.split(path)
			path = path.replace(filename, jfile)
			if (platform.system() != "Windows"):
				path = path.replace("\\","/")
		print(path)
		return path


	@classmethod
	def tree(self, dir):
		for i in Tool.treeup(dir):
			print(i,end='')
		return

	@classmethod
	def treeup(self, path , depth=1, flag=True, relation=[]):
		files = os.listdir(path)
		yield ''.join([PREFIX[not flag],os.path.basename(path),'\n'])

		depth += 1
		relation.append(flag)

		for i in files:
			for j in relation:
				yield INDENTION[j]
			tempPath = os.path.join(path,i)
			if not os.path.isdir(tempPath):
				yield ''.join([PREFIX[i!=files[-1]], i, '\n'])
			else:
				for i in Tool.treeup(tempPath,depth,i==files[-1],relation[:]):
					print(i,end='')

