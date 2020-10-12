Function WMd5sum {
    param([String]$File)
    Get-FileHash $File -Algorithm MD5
}
