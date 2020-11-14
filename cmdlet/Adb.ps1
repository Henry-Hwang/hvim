
Function Ainit {
    adb wait-for-device root
    adb wait-for-device remount
    adb wait-for-device
    adb shell setenforce 0
}
