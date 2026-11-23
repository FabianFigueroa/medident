# uso: bash login.sh correo nombre_captura
cd /c/Users/JoseG/dev/medident/tool/pruebas
sleep 1.5; adb shell input tap 540 816; sleep 0.8; adb shell input text "$1"; adb shell input keyevent KEYCODE_BACK; sleep 0.4
adb shell input tap 500 996; sleep 0.6; adb shell input text 'Medident#2026'; adb shell input keyevent KEYCODE_BACK; sleep 0.4
python act.py "$2" 6 tap:270,650
