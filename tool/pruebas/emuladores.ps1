# Arranca Firebase Emulator Suite para ejecutar el plan de pruebas sin tocar el Firebase real.
# Requiere firebase-tools (C:\Users\JoseG\dev\firebase-tools) y Java 21.
$env:JAVA_HOME = 'C:\Program Files\Java\jdk-21'
$env:Path = 'C:\Program Files\Java\jdk-21\bin;' + $env:Path
Set-Location 'C:\Users\JoseG\dev\medident'
& 'C:\Users\JoseG\dev\firebase-tools\node_modules\.bin\firebase.cmd' emulators:start --project ips-medident --only auth,firestore,storage @args
