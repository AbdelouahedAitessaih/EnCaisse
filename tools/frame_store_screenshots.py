"""Frame raw phone captures into Google Play phone screenshots.

Reads the raw 1080x2392 captures from docs/images/store-captures/<locale>
(the app running in that language) and writes
1080x1920 (9:16) framed images with a caption per locale into
docs/play-store/screenshots/<locale>/. Play rejects phone screenshots whose
long side exceeds twice the short side, which raw captures from tall phones do.

    python tools/frame_store_screenshots.py
"""

from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont

ROOT = Path(__file__).resolve().parents[1]
CAPTURES = ROOT / "docs" / "images" / "store-captures"
OUT = ROOT / "docs" / "play-store" / "screenshots"

WIDTH, HEIGHT = 1080, 1920
TOP_COLOR = (15, 110, 86)  # brand primary 0F6E56
BOTTOM_COLOR = (7, 46, 37)
HEADLINE_COLOR = (255, 255, 255)
SUBLINE_COLOR = (205, 235, 226)
BEZEL_COLOR = (10, 15, 14)

# Status bar and gesture handle are cropped so the clock and notification
# icons of the capture device never appear in the listing.
CROP_TOP, CROP_BOTTOM = 128, 2330
PHONE_WIDTH = 800
BEZEL = 14
RADIUS = 56
PHONE_TOP = 380

FONT_BOLD = "C:/Windows/Fonts/segoeuib.ttf"
FONT_REGULAR = "C:/Windows/Fonts/segoeui.ttf"

SHOTS = [
    ("1-balance", "group"),
    ("2-split", "add"),
    ("3-settle", "insights"),
    ("4-charts", "charts"),
    ("5-history", "detail"),
    ("6-caisses", "home"),
]

CAPTIONS = {
    "en-US": {
        "group": ("One shared caisse", "Everyone sees the same live balance."),
        "add": ("Split any expense", "Equally or custom amounts, in seconds."),
        "insights": ("Know who owes whom", "Settle up with a single tap."),
        "charts": ("See where it goes", "Spending by category at a glance."),
        "detail": ("Nothing gets lost", "Every change stays in the audit trail."),
        "home": ("All your caisses", "Trips, roommates, family — and your own."),
    },
    "fr-FR": {
        "group": ("Une caisse commune", "Le même solde en direct pour tous."),
        "add": ("Partagez chaque dépense", "À parts égales ou personnalisées."),
        "insights": ("Qui doit quoi à qui", "Réglez vos comptes en un geste."),
        "charts": ("Voyez où va l’argent", "Les dépenses par catégorie, d’un coup d’œil."),
        "detail": ("Rien ne se perd", "Chaque modification reste dans l’historique."),
        "home": ("Toutes vos caisses", "Voyages, colocs, famille… et la vôtre."),
    },
}


def gradient() -> Image.Image:
    image = Image.new("RGB", (WIDTH, HEIGHT))
    draw = ImageDraw.Draw(image)
    for y in range(HEIGHT):
        t = y / (HEIGHT - 1)
        color = tuple(round(a + (b - a) * t) for a, b in zip(TOP_COLOR, BOTTOM_COLOR))
        draw.line([(0, y), (WIDTH, y)], fill=color)
    return image


def wrap(draw: ImageDraw.ImageDraw, text: str, font, max_width: int) -> list[str]:
    lines, current = [], ""
    for word in text.split():
        candidate = f"{current} {word}".strip()
        if draw.textlength(candidate, font=font) <= max_width or not current:
            current = candidate
        else:
            lines.append(current)
            current = word
    if current:
        lines.append(current)
    return lines


def draw_centered(draw, lines, font, color, top, line_height) -> int:
    for line in lines:
        width = draw.textlength(line, font=font)
        draw.text(((WIDTH - width) / 2, top), line, font=font, fill=color)
        top += line_height
    return top


def rounded_mask(size, radius) -> Image.Image:
    mask = Image.new("L", size, 0)
    ImageDraw.Draw(mask).rounded_rectangle([(0, 0), (size[0] - 1, size[1] - 1)], radius, fill=255)
    return mask


def frame(capture: Path, headline: str, subline: str) -> Image.Image:
    canvas = gradient()
    draw = ImageDraw.Draw(canvas)

    headline_font = ImageFont.truetype(FONT_BOLD, 72)
    subline_font = ImageFont.truetype(FONT_REGULAR, 40)
    top = draw_centered(draw, wrap(draw, headline, headline_font, 960), headline_font, HEADLINE_COLOR, 120, 86)
    draw_centered(draw, wrap(draw, subline, subline_font, 900), subline_font, SUBLINE_COLOR, top + 18, 52)

    raw = Image.open(capture).convert("RGB")
    screen = raw.crop((0, CROP_TOP, raw.width, CROP_BOTTOM))
    screen_height = round(screen.height * PHONE_WIDTH / screen.width)
    screen = screen.resize((PHONE_WIDTH, screen_height), Image.LANCZOS)

    body_size = (PHONE_WIDTH + 2 * BEZEL, screen_height + 2 * BEZEL)
    left = (WIDTH - body_size[0]) // 2

    shadow = Image.new("L", (WIDTH, HEIGHT + body_size[1]), 0)
    ImageDraw.Draw(shadow).rounded_rectangle(
        [(left, PHONE_TOP + 24), (left + body_size[0], PHONE_TOP + 24 + body_size[1])],
        RADIUS + BEZEL,
        fill=150,
    )
    shadow = shadow.filter(ImageFilter.GaussianBlur(36)).crop((0, 0, WIDTH, HEIGHT))
    canvas.paste((0, 0, 0), (0, 0, WIDTH, HEIGHT), shadow)

    body = Image.new("RGB", body_size, BEZEL_COLOR)
    body.paste(screen, (BEZEL, BEZEL), rounded_mask(screen.size, RADIUS))
    canvas.paste(body, (left, PHONE_TOP), rounded_mask(body_size, RADIUS + BEZEL))
    return canvas


def main() -> None:
    for locale, captions in CAPTIONS.items():
        target = OUT / locale
        target.mkdir(parents=True, exist_ok=True)
        for name, capture in SHOTS:
            headline, subline = captions[capture]
            image = frame(CAPTURES / locale / f"{capture}.png", headline, subline)
            image.save(target / f"{name}.png", optimize=True)
            print(target / f"{name}.png")


if __name__ == "__main__":
    main()
