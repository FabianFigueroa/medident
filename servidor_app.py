"""Sirve build/web de Medident en 5174 con revalidacion (sin builds viejos).

Estrategia identica a Tenderos (que ya funciona estable):
'no-cache' obliga a Chrome a revalidar con Last-Modified en cada carga.
Si el build no cambio responde 304 (rapido); si cambio, descarga el nuevo.
Esto evita que Chrome se quede con un main.dart.js viejo.
"""

import http.server
import os

PUERTO = 5174
RAIZ = os.path.join(os.path.dirname(os.path.abspath(__file__)), "build", "web")


class Handler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=RAIZ, **kwargs)

    def end_headers(self):
        self.send_header("Cache-Control", "no-cache, must-revalidate")
        self.send_header("Pragma", "no-cache")
        self.send_header("Expires", "0")
        super().end_headers()

    def log_message(self, formato, *args):
        pass


if __name__ == "__main__":
    with http.server.ThreadingHTTPServer(("0.0.0.0", PUERTO), Handler) as httpd:
        httpd.serve_forever()
