@echo off
cormis tuning create %1 > CORMIS_TUNING_UUID.txt
set /p CORMIS_TUNING_UUID=<CORMIS_TUNING_UUID.txt
cormis tuning compile -p %2 > %3
cormis block graphviz main | dot -Tpng > %3.png
cormis tuning delete %CORMIS_TUNING_UUID%
