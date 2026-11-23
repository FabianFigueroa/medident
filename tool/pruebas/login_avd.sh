# Inicio de sesión en el emulador Android (Pixel 6). uso: bash login_avd.sh correo captura
cd /c/Users/JoseG/dev/medident/tool/pruebas
oculta() { adb shell dumpsys input_method | grep -q "mInputShown=true" && adb shell input keyevent KEYCODE_BACK; sleep 0.4; }
sleep 1; adb shell input tap 540 912; sleep 0.8; adb shell input text "$1"; oculta
adb shell input tap 500 1096; sleep 0.6; adb shell input text 'Medident#2026'; oculta
python act.py "$2" 7 tap:270,701
