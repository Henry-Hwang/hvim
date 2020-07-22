#!/bin/bash
#date -d"1970-01-01 + $(date +%s) sec - $(cut -d' ' -f1 </proc/uptime) sec + 600711.395348 sec" +"%F %T.%N %Z"
date -d"1970-01-01 + $(date +%s) sec - $(cut -d' ' -f1 </proc/uptime) sec + "$1" sec" +"%F %T.%N %Z"

