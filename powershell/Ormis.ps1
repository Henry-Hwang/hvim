
Function Ormis-Server {
    ormis server --cspl-block-path C:\work\src\aus\amps\algorithms\blocks\primitives --block-path C:\work\src\aus\amps\algorithms\blocks --platform-path C:\work\src\aus\amps\csplc\platforms
}

Function Ormis-package {
    ormis register package --cspl-block-path C:\work\src\aus\amps\algorithms\blocks\primitives --block-path C:\work\src\aus\amps\algorithms\blocks -o playback.csplpkg
}
