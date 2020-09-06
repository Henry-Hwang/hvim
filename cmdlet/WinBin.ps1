Function WMd5sum {
    param([String]$File)
	certutil -hashfile $File MD5
}
