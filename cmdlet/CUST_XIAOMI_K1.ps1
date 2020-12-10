
Function Record_US_K1{
    adb shell "tinymix 'MultiMedia1 Mixer TERT_TDM_TX_0' 1"
    adb shell "tinymix 'TERT_TDM_TX_0 Channels' 1"
    adb shell "tinymix 'TERT_TDM_TX_0 Format' 'S24_LE'"
    adb shell "tinymix 'TERT_TDM_TX_0 SampleRate' 'KHZ_96'"
    adb shell "tinymix  'ASP TX2 Source' 'VMON'"
    adb shell "tinymix  'RCV ASP TX1 Source' 'VMON'"
    adb shell "tinymix  'ASPTX Ref' 'Ref'"
    adb shell "tinymix  'RCV ASPTX Ref' 'Ref'"
    adb shell "tinymix  'RCV ASPTX1 Slot Position'  0"
    adb shell "tinymix  'ASPTX2 Slot Position'      1"
    adb shell "tinycap /sdcard/Download/us_rec.wav -r 96000 -b 16 -c 2 -T 10"
    adb pull /sdcard/Download/us_rec.wav .
    start .
}
Function Record_RCV_K1
{
    echo 'enabling receiver'
    tinymix 'MultiMedia1 Mixer TERT_TDM_TX_0' 1
    tinymix 'TERT_TDM_TX_0 Channels' 1
    tinymix 'TERT_TDM_TX_0 Format' 'S24_LE'
    tinymix 'TERT_TDM_TX_0 SampleRate' 'KHZ_96'
    tinymix  'ASP TX2 Source' 'ASPRX1'
    tinymix  'RCV ASP TX1 Source' 'ASPRX1'
    tinymix  'ASPTX Ref' 'Ref'
    tinymix  'RCV ASPTX Ref' 'Ref'
    tinymix  'RCV ASPTX2 Slot Position'  4
    tinymix  'RCV ASPTX3 Slot Position'  4
    tinymix  'RCV ASPTX4 Slot Position'  4
    tinymix  'ASPTX1 Slot Position'      4
    tinymix  'ASPTX3 Slot Position'      4
    tinymix  'ASPTX4 Slot Position'      4
    tinymix  'RCV ASPTX1 Slot Position'  0
    tinymix  'ASPTX2 Slot Position'      1
    adb shell "tinycap /sdcard/Download/rcv_rec.wav -r 96000 -b 16 -c 2"
    adb pull /sdcard/Download/rcv_rec.wav .
    start .
}

Function Record_SPK_K1
{
    echo 'enabling receiver'
    tinymix 'MultiMedia1 Mixer TERT_TDM_TX_0' 1
    tinymix 'TERT_TDM_TX_0 Channels' 1
    tinymix 'TERT_TDM_TX_0 Format' 'S24_LE'
    tinymix 'TERT_TDM_TX_0 SampleRate' 'KHZ_96'
    tinymix  'ASP TX2 Source' 'ASPRX1'
    tinymix  'RCV ASP TX1 Source' 'ASPRX1'
    tinymix  'ASPTX Ref' 'Ref'
    tinymix  'RCV ASPTX Ref' 'Ref'
    tinymix  'RCV ASPTX2 Slot Position'  4
    tinymix  'RCV ASPTX3 Slot Position'  4
    tinymix  'RCV ASPTX4 Slot Position'  4
    tinymix  'ASPTX1 Slot Position'      4
    tinymix  'ASPTX3 Slot Position'      4
    tinymix  'ASPTX4 Slot Position'      4
    tinymix  'RCV ASPTX1 Slot Position'  1
    tinymix  'ASPTX2 Slot Position'      0
    adb shell "tinycap /sdcard/Download/spk_rec.wav -r 96000 -b 16 -c 2"
    adb pull /sdcard/Download/spk_rec.wav .
    start .
}
