from PIL import Image, ImageDraw
import math

SIZE = 1024
BG = (255, 255, 255, 255)  # white — matches in-app motif on light scaffold
TEAL = (15, 110, 86, 255)  # #0F6E56
CORAL = (216, 90, 48, 255)  # #D85A30
LIGHT = (230, 244, 240, 255)  # #E6F4F0

img = Image.new("RGBA", (SIZE, SIZE), BG)
draw = ImageDraw.Draw(img)

cx = cy = SIZE / 2
r = SIZE * 0.42


def draw_rotated_rrect(center, width, height, angle, fill, radius):
    layer = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    ld = ImageDraw.Draw(layer)
    left = center[0] - width / 2
    top = center[1] - height / 2
    right = center[0] + width / 2
    bottom = center[1] + height / 2
    ld.rounded_rectangle([left, top, right, bottom], radius=radius, fill=fill)
    rotated = layer.rotate(
        -math.degrees(angle), resample=Image.BICUBIC, center=center
    )
    img.alpha_composite(rotated)


for i in range(4):
    angle = i * (math.pi / 4)
    fill = TEAL if i % 2 == 0 else CORAL
    draw_rotated_rrect((cx, cy), r * 1.2, r * 1.2, angle, fill, 4 * (SIZE / 200))

draw_rotated_rrect((cx, cy), r * 0.7, r * 0.7, math.pi / 4, LIGHT, 0)

half = (r * 0.35) / 2
rad = 4 * (SIZE / 200)
draw.rounded_rectangle(
    [cx - half, cy - half, cx + half, cy + half],
    radius=rad,
    fill=TEAL,
)

tile = SIZE * 0.12
positions = [
    (tile, tile),
    (SIZE - tile, tile),
    (tile, SIZE - tile),
    (SIZE - tile, SIZE - tile),
]
trad = 2 * (SIZE / 200)
for i, (px, py) in enumerate(positions):
    fill = CORAL if i % 2 == 0 else TEAL
    th = tile / 2
    draw.rounded_rectangle(
        [px - th, py - th, px + th, py + th],
        radius=trad,
        fill=fill,
    )

out = r"C:\Users\abdel\Bureau\EnCaisse\assets\branding\encaisse_icon.png"
img.save(out, "PNG")
print("saved", out, img.size)
