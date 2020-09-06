#======================================================================
Function Ssh-Shenzhen {
    ssh cirrus@198.90.140.122
}
Function Ssh-Scp {
    param([String]$Target)
    scp -r cirrus@198.90.140.122:$Target .
}


