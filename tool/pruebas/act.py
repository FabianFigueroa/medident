# Acciones sobre el celular por adb. Coordenadas en la escala de las capturas (mitad de 1080x2408).
# Uso: python act.py <captura> [espera_s] acc1 acc2 ...
#  tap:x,y   swipe:x1,y1,x2,y2[,ms]   text:hola_mundo (espacios con %s)   key:BACK|ENTER|TAB   wait:s
import sys, subprocess, time, io
from PIL import Image
ADB = 'C:/Users/JoseG/dev/android-sdk/platform-tools/adb.exe'
BASE = r'C:/Users/JoseG/dev/capturas/'

def sh(*a):
    subprocess.run([ADB, 'shell', *a], check=False)

name = sys.argv[1]
espera = float(sys.argv[2])
for acc in sys.argv[3:]:
    tipo, _, arg = acc.partition(':')
    if tipo == 'tap':
        x, y = [int(float(v) * 2) for v in arg.split(',')]
        sh('input', 'tap', str(x), str(y))
    elif tipo == 'swipe':
        p = [int(float(v) * 2) for v in arg.split(',')[:4]]
        ms = arg.split(',')[4] if len(arg.split(',')) > 4 else '400'
        sh('input', 'swipe', *map(str, p), ms)
    elif tipo == 'text':
        sh('input', 'text', arg)
    elif tipo == 'key':
        sh('input', 'keyevent', 'KEYCODE_' + arg)
    elif tipo == 'wait':
        time.sleep(float(arg))
    time.sleep(0.6)
time.sleep(espera)
raw = subprocess.run([ADB, 'exec-out', 'screencap', '-p'], capture_output=True).stdout
img = Image.open(io.BytesIO(raw))
img.save(BASE + name + '_full.png')
img.resize((img.width // 2, img.height // 2)).save(BASE + name + '.png')
print('ok', name)
