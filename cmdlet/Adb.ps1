
Function Ainit {
    adb wait-for-device root
    adb wait-for-device remount
    adb wait-for-device
    adb shell setenforce 0
}

Function Apush-music {
    Ainit
    adb push C:\work\music\Music\Cirrus /sdcard/Music
}


Function My-Counter {
    while($val -ne 10) {
        $val++
            echo $val++
            sleep 1
    }
}


Function Adb-Wifi {

}
