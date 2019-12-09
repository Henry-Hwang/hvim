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
from amp import Amp
from playback import Playback
from config import Config
from regmap import Regmap
from andevice import Andevice
from tool import Tool


parser = argparse.ArgumentParser(description='Cirrus Shenzhen, AMP tool for Android',
        usage='use "python %(prog)s --help" for more information',
        formatter_class=argparse.RawTextHelpFormatter)
parser.add_argument('-c', "--conf",
	required=False,
	metavar=('[COUNT]'),
	type=int,
	help="Display temp: [COUNT] = 10, 100, 1000")
parser.add_argument('-i', "--info",
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
	help="Show md5sum of file")
parser.add_argument('-l', "--list",
	action="store_true",
	required=False,
	help="List Cirrus stuff")
parser.add_argument('-a', "--adb",
	action="store_true",
	required=False,
	help="Init adb")
parser.add_argument('-mc', "--make-capi",
	required=False,
	nargs=2,
	metavar=('[24BIT]', '[16BIT]'),
	help="Make CAPI V2 Playback.")
parser.add_argument("-m", "--mute",
	nargs=2,
	metavar=('[CH]', '[OP]'),
	help="[CH] = left,right,all,mono, [OP] = mute,unmute")
parser.add_argument("-b", "--dsp-bypass",
	nargs=2,
	metavar=('[CH]', '[OP]'),
	help="Bypass DSP: [CH] = left,right,all,mono, [OP] = yes,no")
parser.add_argument('-d', "--dump-regs",
	#action="store_true",
	required=False,
	metavar=('[DEVICE]'),
	help="Dump amp's registers: [DEVICE] = spi1.0, 2-0040. show [DEVICE] by '--list'")
parser.add_argument('-p', "--push",
	nargs=2,
	metavar=('[TYPE]', '[FILE]'),
	help="Push stuff to device: [TYPE] = capi,wmfw,bin,tool, [FILE] = source file")
parser.add_argument('-rw', "--reg-write",
	nargs=2,
	metavar=('[DEVICE]', '[REG<=VAL, ...]'),
	type=str,
	help="Write registers:  [DEVICE] = spi1.0, 2-0040. show [DEVICE] by '--list'. [REG<=VAL,...] = \"0x3804<=0x01,0x3800<=0x12, ...\" >")
parser.add_argument('-rr', "--reg-read", 
	nargs=2,
	metavar=('[DEVICE]', '[REGS, ...]'),
	type=str,
	help="Read registers:  [DEVICE] = spi1.0, 2-0040. show [DEVICE] by '--list'.")

parser.add_argument('-s', "--detail",
	required=False,
	type=int,
	help="display infomation of a given number")
parser.add_argument("-r", "--reload",
	required=False,
	type=int,
	help="reload firmware")
parser.add_argument("-de", "--debug",
	required=False,
	type=bool,
	help="power on / off")

parser.add_argument('-t', "--test",
	metavar=('[file]'),
	type=str,
	required=False,
	help="test ....")
#parser.print_help()
arg = parser.parse_args()
print (arg)

config = Config()
amp = Amp(config.get_conf())
playback = Playback(config.get_conf())
regmap = Regmap()
andevice = Andevice(config.get_conf())


if arg.conf:
	config.conf(arg.conf)

if arg.info:
	amp.show_temp(arg.info)
if arg.mute:
	amp.mute(arg.mute)
if arg.dsp_bypass:
	amp.dsp_bypass(arg.dsp_bypass)

if arg.list:
	andevice.list(arg.list)
if arg.adb:
	andevice.adb_init(arg.list)
if arg.dev_md5sum:
	andevice.device_md5sum(arg.dev_md5sum)
if arg.push:
	andevice.push_device(arg.push)
if arg.reg_write:
	regmap.regs_write(arg.reg_write)
if arg.dump_regs:
	regmap.dump_registers(arg.dump_regs)
if arg.reg_read:
	regmap.regs_read(arg.reg_read)
if arg.make_capi:
	playback.make_capi_v2(arg.make_capi)

if arg.test:
	Tool.zip(arg.test)
#un-verify
if arg.detail:
	amp.show_detail(arg.detail)
if arg.reload:
	amp.firmware_reload(arg.reload)
