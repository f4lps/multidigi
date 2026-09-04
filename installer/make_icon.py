"""Génère l'icône MultiDigi (.ico) — badge sombre avec un signal radio en arc,
dégradé magenta -> cyan, cohérent avec l'identité visuelle du programme."""
from PIL import Image, ImageDraw
import math

SIZE = 256
img = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
draw = ImageDraw.Draw(img)

# Badge de fond : carré arrondi gris anthracite (cohérent avec le thème
# "Aluminium usé" devenu thème par défaut de l'interface).
pad = 6
draw.rounded_rectangle(
    [pad, pad, SIZE - pad, SIZE - pad],
    radius=54,
    fill=(28, 30, 34, 255),
    outline=(90, 92, 98, 255),
    width=4,
)

# Point émetteur (antenne), en bas à gauche du cadran.
cx, cy = 78, 178
r_dot = 12
draw.ellipse([cx - r_dot, cy - r_dot, cx + r_dot, cy + r_dot], fill=(255, 255, 255, 255))

# Arcs de signal radio concentriques, dégradé magenta -> cyan, épaisseur
# décroissante vers l'extérieur (façon icône Wi-Fi/onde radio classique).
colors = [
    (255, 68, 170, 255),   # magenta (accent néon d'origine)
    (200, 110, 210, 255),
    (140, 150, 235, 255),
    (95, 168, 230, 255),   # bleu anodisé (accent du thème aluminium)
    (60, 210, 235, 255),   # cyan
]
radii = [34, 58, 82, 106, 130]
widths = [12, 11, 10, 9, 8]

for radius, color, w in zip(radii, colors, widths):
    bbox = [cx - radius, cy - radius, cx + radius, cy + radius]
    # Arc de 135° à 315° (quart supérieur-droit, comme un signal qui part
    # de l'émetteur vers le coin haut-droit).
    draw.arc(bbox, start=-45, end=135, fill=color, width=w)

# Export multi-résolutions dans un seul .ico (Windows choisit la meilleure).
out_path = "C:/Users/14frs/Documents/radio/miltidigi/installer/multidigi.ico"
img.save(out_path, format="ICO", sizes=[(256, 256), (128, 128), (64, 64), (48, 48), (32, 32), (16, 16)])
print("Icone ecrite:", out_path)
