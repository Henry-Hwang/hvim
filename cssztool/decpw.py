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

alphabet = "abdcdefghijklmnopqrstuvwsyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!&-="
password = []
pubkey_l = []

def encodepw(pubkey, lenghtpw, offset):
	#get md5sum
	md5sum = hashlib.md5(pubkey.encode('utf8')).hexdigest()
	#print("key: " + pubkey
	#	+ "\nkey lenght: " + str(len(pubkey))
	#	+ "\npasswd lenght: " + str(lenghtpw)
	#	+ "\noffset: " + str(offset)
	#	+ "\nmd5sum: " + md5sum)

	#len of the key shoud be extent to [lenghtpw]
	if(len(pubkey) < lenghtpw):
		pubkey_l = list(pubkey + md5sum[:lenghtpw-len(pubkey)])
	else:
		pubkey_l = list(pubkey[0:lenghtpw])
	
	#1. char of password come from md5sum string
	#2. index of the char in key shoud be matter
	#3. [alphabet] cover all the char in password]
	for index, c in enumerate(pubkey_l):
		#print(ord(c))
		if(alphabet.find(c) != -1):
			newchar = md5sum[(ord(c) + index + offset) % len(md5sum)]
			#Uppercase letter
			if(index%3 == 0 and ord(newchar) >= ord('a') and ord(newchar) <= ord('f')):
				newchar = newchar.upper()
			password.append(newchar)
			continue
		else:
			print("Input Error!")
			return

	print("password: "+ ''.join(password))

parser = argparse.ArgumentParser(description='Generate password for APP',
        usage='use "python %(prog)s --help" for more information',
        formatter_class=argparse.RawTextHelpFormatter)

parser.add_argument('-e', "--encode",
	required=False,
	default="tiaopitiao5du",
	type=str,
	help="Show password according to the input PUBKEY. e.g: %(prog)s -e [PUBKEY]")

parser.add_argument('-l', "--lenght",
	required=False,
	default=16,
	type=int,
	choices=[4, 6, 8, 12, 16, 20, 24],
	help="Lenght of password")

parser.add_argument('-o', "--offset",
	required=False,
	default=0,
	type=int,
	choices=[0, 1, 3, 5],
	help="Offset of password")
#parser.print_help()
arg = parser.parse_args()
#print (arg)
if arg.encode:
	encodepw(arg.encode, arg.lenght, arg.offset)
else:
	encodepw(arg.encode, arg.lenght, arg.offset)
