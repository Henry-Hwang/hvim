import logging
import coloredlogs
import click
import json
import operator
import os
import re
import shutil
import fnmatch
from fuzzywuzzy import fuzz
from prompt_toolkit import prompt
from prompt_toolkit.completion import WordCompleter
from prompt_toolkit import PromptSession

coloredlogs.install()
logger = logging.getLogger(__name__)

def format_inputs(string):
    replacements = {"hf":"handsfree", "hs":"handset", "speaker":"spk", "reciver":"rcv", "dt":"delta"}
    input_str = re.sub(("\ |\_"), "-", string.lower())
    for key in list(replacements.keys()):
        if key in input_str.replace(".","-").split("-"):
            input_str = input_str.replace(key, replacements[key])
    return input_str

def create_scripts(paths_dict, sorted_dict):
    #create push script
    for k, v in paths_dict.items():
        path = os.path.join(v, "push.txt")
        fp = open(path, "w")

        fp.write("@echo off\n" +
            "adb wait-for-device-root\n" +
            "adb wait-for-device remount\n" +
            "adb wait-for-device\n")
        CMDSTR = "adb push @SRC /vendor/firmware/@DEST\n"
        for key, value in sorted_dict.items():
            logger.debug("%s --> %s", key, value)
            if k == "origin" :
                fp.write(CMDSTR.replace("@SRC", key).replace("@DEST", value))
            else :
                fp.write(CMDSTR.replace("@SRC", value).replace("@DEST", value))

        fp.write("pause\n")
        fp.close()
        fp = open(path, "r")
        logger.debug("%s", fp.read())

def fuzzy_handwork(sorted_dict):
    for key, value in sorted_dict.items():
        if(len(value) == 1):
            logger.warning("%s --> %s", key, value[0])
            sorted_dict[key] = value[0]
        else:
            completer = WordCompleter(value)
            session = PromptSession(key + ': ', completer=completer)
            text = session.prompt(pre_run=session.default_buffer.start_completion)
            sorted_dict[key] = text
            logger.warning("%s --> %s", key, text)
    return sorted_dict

@click.command()
@click.option("-s", "--src", default=None, help="Path to the orign tuning")
@click.option("-d", "--dest", default=None, help="String of all formated tunings")
@click.option('-m', '--manual', is_flag=True, help="Manually.")
def trename(src, dest, manual):

    #filter tuning files
    input_tunings = fnmatch.filter(os.listdir(src), '*.txt')
    input_tunings += fnmatch.filter(os.listdir(src), '*.bin')
    input_tunings += fnmatch.filter(os.listdir(src), '*.wmfw')

    #inputs of file name that used
    orgin_tunings = list(dest.split(' '))
    origin_rate_dict = {}
    sorted_dict = {}
    for one in input_tunings:
        orgin_rate_dict = {}
        for orgin in orgin_tunings:
            orgin_rate_dict[orgin] = fuzz.token_sort_ratio(format_inputs(one), orgin.lower())
        origin_rate_dict[one] = orgin_rate_dict
        sorted_list = sorted(orgin_rate_dict.items(), key=lambda item: item[1], reverse=True)
        tup_list = []
        for tup in sorted_list:
            if (tup[1] == sorted_list[0][1]):
                tup_list.append(tup[0])
        sorted_dict[one] = tup_list

    for key, value in origin_rate_dict.items():
        filename, ext = os.path.splitext(key)
        origin_rate_dict[key] = list(filter(lambda k: ext in k, list(value.keys())))

    logger.debug("%s", json.dumps(origin_rate_dict, sort_keys=True, indent=4))

    #handwork
    if manual:
        sorted_dict = fuzzy_handwork(origin_rate_dict)
    else:
        sorted_dict = fuzzy_handwork(sorted_dict)

    logger.warning("%s", json.dumps(sorted_dict, sort_keys=True, indent=4))

    #Copy files to place
    origin_path = os.path.join(src, "origin")
    renamed_path = os.path.join(src,"renamed")

    if os.path.exists(origin_path):
        shutil.rmtree(origin_path)
    if os.path.exists(renamed_path):
        shutil.rmtree(renamed_path)

    logger.warning("%s --> %s", origin_path, renamed_path)
    os.makedirs(origin_path, exist_ok=True)
    os.makedirs(renamed_path, exist_ok=True)
    for key, value in sorted_dict.items():
        ofile = os.path.join(src, key)
        shutil.copy(ofile, origin_path)
        shutil.copy(ofile, os.path.join(renamed_path, value))

    scrits_dict = {"origin":origin_path, "renamed":renamed_path}
    create_scripts(scrits_dict, sorted_dict)

if __name__ == '__main__':
    trename()
