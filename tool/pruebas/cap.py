import sys, subprocess
from PIL import Image
import io
name = sys.argv[1]
raw = subprocess.run(['C:/Users/JoseG/dev/android-sdk/platform-tools/adb.exe','exec-out','screencap','-p'], capture_output=True).stdout
img = Image.open(io.BytesIO(raw))
base = r'C:/Users/JoseG/dev/capturas/'
img.save(base + name + '_full.png')
img.resize((img.width//2, img.height//2)).save(base + name + '.png')
print('ok', img.size)
