# Cambia de cuenta en el emulador: borra datos de la app, salta el onboarding e inicia sesión. uso: bash cambiar_avd.sh correo
cd /c/Users/JoseG/dev/medident/tool/pruebas
adb shell pm clear com.medident.medident >/dev/null
adb shell pm grant com.medident.medident android.permission.POST_NOTIFICATIONS 2>/dev/null
adb shell monkey -p com.medident.medident -c android.intent.category.LAUNCHER 1 >/dev/null 2>&1
python act.py tmp 25
for i in 1 2 3 4 5; do adb shell input tap 930 2248; sleep 1.5; done
sleep 2
bash login_avd.sh "$1" tmp
