#!/usr/bin/python3
import os
import sys
import platform
import time
import datetime
import shutil
import argparse
import hashlib
from decimal import Decimal
from explorer import Explorer
from amps import Amps
from playback import Playback
from conf import Conf
from andevice import Andevice
from tool import Tool
from ctags import Ctags
from csparams import Csparams

def str2bool(v):
	if v.lower() in ('yes', 'true', 't', 'y', '1'):
		return True
	elif v.lower() in ('no', 'false', 'f', 'n', '0'):
		return False
	else:
		raise argparse.ArgumentTypeError('Unsupported value encountered.')

parser = argparse.ArgumentParser(description='Cirrus Shenzhen, AMP tool for Android',
        usage='use "python %(prog)s --help" for more information',
        formatter_class=argparse.RawTextHelpFormatter)
parser.add_argument('-c', "--conf",
	required=False,
	metavar=('[COUNT]'),
	type=int,
	help="Display temp: [COUNT] = 10, 100, 1000")
parser.add_argument("--info",
	required=False,
	metavar=('[COUNT]'),
	type=int,
	help="Display temp: [COUNT] = 10, 100, 1000")
parser.add_argument('-dmd5', "--dev_md5sum",
	action="store_true",
	required=False,
	help="Show md5sum of cirrus stuff in android device")

parser.add_argument('-md5', "--md5sum",
	required=False,
	type=str,
	help="Show md5sum of file. e.g: %(prog)s -md5 xxx.bin")
parser.add_argument('-l', "--list",
	action="store_true",
	required=False,
	help="List Cirrus stuff")
parser.add_argument('-a', "--adb",
	action="store_true",
	required=False,
	help="ADB : adb root, adb remount, ...")
parser.add_argument('-r', "--adb-reboot",
	action="store_true",
	required=False,
	help="ADB : adb reboot")
parser.add_argument('-it', "--insert-t",
	required=False,
	nargs=3,
	#dest="mybaby",
	metavar=('[BITs]', '[UC]', '[TUNING]'),
	help="CAPIV2: Insert tuning to source, without building. [BITs]=24,16 [UC]=0,1,2,3 ... [TUNING]= 'path to tuning'")
parser.add_argument('-mc', "--make-capi",
	required=False,
	default='Y',
	type=str,
	choices=['Y', 'N'],
	help="CAPIV2: Make CAPI V2 Playback. eg. %(prog)s -mc Y -f pb4_handfree.h -b 16 -i 3 -v 4")
parser.add_argument('-d', "--regs-dump",
	required=False,
	type=int,
	help="AMP: Dump amp's registers")
parser.add_argument("--push",
	nargs=2,
	metavar=('[TYPE]', '[FILE]'),
	help="ADB: Push stuff to device: [TYPE] = capi,wmfw,bin,tool, [FILE] = source file")
parser.add_argument('-rw', "--regs-write",
	type=str,
	help="AMP: Write registers:  [DEVICE] = spi1.0, 2-0040. show [DEVICE] by '--list'. [REG=VAL,...] e.g. \"0x3804<=0x01,0x3800<=0x12, ...\" >")

parser.add_argument('-rr', "--regs-read",
	type=str,
	help="AMP: Read registers e.g. \"0x3804, 0x4800, ...\"")

parser.add_argument('-o', "--open",
	required=False,
	metavar=('[DIR]'),
	type=str,
	help="SYS: Open common directory: [DIR] = work, doc, hvim, ...")

parser.add_argument("--dir",
	required=False,
	metavar=('[DIR]'),
	default= ".",
	type=str,
	help="SYS: specific a directory for operation")

parser.add_argument("--out",
	required=False,
	type=str,
	help="SYS: specific a file for operation")

parser.add_argument('-t', "--ctags",
	required=False,
	metavar=('[OP]'),
	type=str,
	help="SYS: Create ctags for source code: [DIR] = kernel, all, ...")

parser.add_argument('-s', "--detail",
	required=False,
	type=int,
	help="display infomation of a given number")
parser.add_argument("-de", "--debug",
	required=False,
	type=bool,
	help="power on / off")

parser.add_argument("-bk", "--backup",
	required=False,
	help="Backup cs params")
parser.add_argument("-rs", "--restore",
	required=False,
	help="Restore cs params")
parser.add_argument("-b", "--bit",
	required=False,
	default=24,
	type=int,
	choices=[16, 24, 32],
	help="Specific the bits format")
parser.add_argument("-v", "--version",
	required=False,
	default=5,
	type=int,
	help="Specific the version")
parser.add_argument("-i", "--index",
	required=False,
	default=0,
	type=int,
	choices=[0, 1, 2, 3],
	help="Specific the index")
parser.add_argument("-f", "--file",
	required=False,
	type=str,
	help="Specific the input file")
parser.add_argument("-ch", "--channel",
	required=False,
	default='all',
	choices=['left', 'right', 'all'], 
	help="Specific the AMP of which channel")
parser.add_argument("-e", "--execute",
	required=False,
	help="Execute commands")

parser.add_argument('-ts', "--test",
	metavar=('[file]'),
	type=str,
	required=False,
	help="test ....")
#parser.print_help()
arg = parser.parse_args()
print (arg)
if arg.conf:
	config.conf(arg.conf)
# Amps
if arg.info:
	Amps().show_temp(arg.info, arg.channel)
if arg.regs_write:
	Amps().regs_write(arg.regs_write, arg.channel)
if arg.regs_read:
	Amps().regs_read(arg.regs_read, arg.channel)
if arg.regs_dump:
	Amps().regs_dump(arg.regs_dump, arg.channel)
if arg.channel:
	pass
if arg.execute:
	Amps().execute(arg.channel, arg.execute)

#Run on device
if arg.list:
	Andevice().list(arg.list)
if arg.adb:
	Andevice().adb_init(arg.list)
if arg.dev_md5sum:
	Andevice().device_md5sum(arg.dev_md5sum)
if arg.dev_md5sum:
	Andevice().md5sum(arg.md5sum)
if arg.push:
	Andevice().push(arg.push)

# make capiv2 with tuning
if arg.make_capi:
	Playback().make_capi_v2(arg.make_capi, arg.file, arg.bit, arg.index, arg.version)

# Open comman directory
if arg.open:
	Explorer().open(arg.open)

#Create ctags for source code
if arg.ctags:
	Ctags().create_ctags(arg.ctags)

#Backup and Restore
if arg.backup:
	Csparams().backup(arg.backup)
if arg.restore:
	Csparams().restore(arg.restore)

if arg.test:
	Tool.zip(arg.test)
#un-verify
if arg.detail:
	Amps().show_detail(arg.detail)
