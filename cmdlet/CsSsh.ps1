#======================================================================
Function Ssh-Shenzhen {
    ssh cirrus@198.90.140.120
}
Function Ssh-Scp {
    param([String]$Target)
    scp -r cirrus@198.90.140.120:$Target .
}


