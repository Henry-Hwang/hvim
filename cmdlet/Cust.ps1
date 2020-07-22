#======================================================================
Function Dbg-Dump-J17 {
    Dbg-Dump -Device1 0-0040 -Device2 0-0041
}
Function Dbg-Registers-J17 {
    Dbg-Registers -Device1 0-0040 -Device2 0-0041
}

Function Dbg-Unload-J17 {
    adb shell "tinymix 'PCM Source' 'None'"
    adb shell "tinymix 'DSP Booted' '0'"
    adb shell "tinymix 'DSP1 Preload Switch' '0'"
}
Function Dbg-Reload-J17 {
	adb shell "tinymix 'DSP1 Firmware' 'Protection'"
    adb shell "tinymix 'DSP1 Preload Switch' '1'"
    adb shell "tinymix 'PCM Source' 'DSP'"
}
#======================================================================
Function Dbg-Dump-J10 {
    Dbg-Dump -Device1 7-0040 -Device2 7-0041
}
Function Dbg-Registers-J10 {
    Dbg-Registers -Device1 7-0040 -Device2 7-0041
}

#======================================================================
Function Dbg-Dump-J3S {
    Dbg-Dump -Device1 0-0040 -Device2 0-0042
}
Function Dbg-Registers-J3S {
    Dbg-Registers -Device1 0-0040 -Device2 0-0042
}

#======================================================================
Function Dbg-Dump-M2091 {
    Dbg-Dump -Device1 spi1.0 -Device2 spi1.1
}

