"""Generate pastel chibi pixel art sprites for Lopezcy Run."""
import math
from PIL import Image, ImageDraw
import os

ROOT = os.path.join(os.path.dirname(__file__), "..", "assets", "sprites")
os.makedirs(ROOT, exist_ok=True)
os.makedirs(os.path.join(ROOT, "obstacles"), exist_ok=True)
os.makedirs(os.path.join(ROOT, "tiles"), exist_ok=True)
os.makedirs(os.path.join(ROOT, "ui"), exist_ok=True)

# Palette
SKIN = (255, 232, 214)
SKIN_SHADE = (245, 210, 190)
HAIR = (232, 160, 191)
HAIR_DARK = (212, 120, 154)
HAIR_LIGHT = (255, 200, 220)
BOW = (255, 120, 170)
BOW_LIGHT = (255, 180, 210)
BLUSH = (255, 179, 198)
EYE = (80, 50, 70)
EYE_HI = (255, 255, 255)
SKIRT = (255, 158, 199)
SKIRT_DARK = (230, 120, 170)
SHIRT = (201, 160, 255)
SHOE = (184, 232, 216)
SHOE_DARK = (140, 200, 180)
OUTLINE = (120, 70, 90)


def px(img, d, x, y, c):
    if 0 <= x < img.width and 0 <= y < img.height:
        d.point((x, y), fill=c)


def fill_circle(img, d, cx, cy, r, c):
    for y in range(cy - r, cy + r + 1):
        for x in range(cx - r, cx + r + 1):
            if (x - cx) ** 2 + (y - cy) ** 2 <= r * r:
                px(img, d, x, y, c)


def fill_ellipse(img, d, cx, cy, rx, ry, c):
    for y in range(cy - ry, cy + ry + 1):
        for x in range(cx - rx, cx + rx + 1):
            if ((x - cx) / max(rx, 1)) ** 2 + ((y - cy) / max(ry, 1)) ** 2 <= 1:
                px(img, d, x, y, c)


def draw_chibi_frame(leg_offset=0, arm_swing=0, skirt_flap=0, jumping=False, hurt=False, dash=False, highjump=False):
    """Draw one 48x48 chibi frame. Returns RGBA image."""
    img = Image.new("RGBA", (48, 48), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)

    base_y = 6 if jumping else 0
    body_y = 28 + base_y
    head_cy = 16 + base_y

    # Pigtails (back)
    fill_ellipse(img, d, 10, head_cy + 2, 5, 8, HAIR)
    fill_ellipse(img, d, 38, head_cy + 2, 5, 8, HAIR)
    fill_ellipse(img, d, 8, head_cy + 6, 4, 6, HAIR_DARK)
    fill_ellipse(img, d, 40, head_cy + 6, 4, 6, HAIR_DARK)

    # Legs
    l_leg = 38 + leg_offset + base_y
    r_leg = 38 - leg_offset + base_y
    if jumping:
        fill_ellipse(img, d, 20, l_leg, 4, 5, SHOE)
        fill_ellipse(img, d, 28, r_leg, 4, 5, SHOE)
        fill_ellipse(img, d, 20, l_leg - 3, 3, 4, SKIN)
        fill_ellipse(img, d, 28, r_leg - 3, 3, 4, SKIN)
    else:
        fill_ellipse(img, d, 18, l_leg, 5, 6, SHOE)
        fill_ellipse(img, d, 30, r_leg, 5, 6, SHOE)
        fill_ellipse(img, d, 18, l_leg - 4, 3, 5, SKIN)
        fill_ellipse(img, d, 30, r_leg - 4, 3, 5, SKIN)
        px(img, d, 17, l_leg + 2, SHOE_DARK)
        px(img, d, 31, r_leg + 2, SHOE_DARK)

    # Skirt
    skirt_cx = 24 + skirt_flap
    fill_ellipse(img, d, skirt_cx, body_y + 6, 12, 6, SKIRT)
    fill_ellipse(img, d, skirt_cx, body_y + 8, 10, 4, SKIRT_DARK)

    # Torso
    fill_ellipse(img, d, 24, body_y, 7, 8, SHIRT)

    # Arms
    arm_lx = 14 - arm_swing
    arm_rx = 34 + arm_swing
    arm_y = body_y - 2 if jumping else body_y
    fill_ellipse(img, d, arm_lx, arm_y, 4, 5, SKIN)
    fill_ellipse(img, d, arm_rx, arm_y, 4, 5, SKIN)

    # Head
    fill_circle(img, d, 24, head_cy, 11, SKIN)
    fill_circle(img, d, 24, head_cy, 10, SKIN)

    # Hair top
    fill_ellipse(img, d, 24, head_cy - 4, 12, 9, HAIR)
    fill_ellipse(img, d, 24, head_cy - 6, 10, 6, HAIR_LIGHT)
    # Bangs
    for bx in range(16, 33):
        if (bx - 24) ** 2 < 64:
            px(img, d, bx, head_cy - 2, HAIR)
    fill_ellipse(img, d, 24, head_cy - 1, 9, 4, HAIR)

    # Bow
    fill_circle(img, d, 24, head_cy - 12, 4, BOW)
    fill_circle(img, d, 20, head_cy - 12, 3, BOW_LIGHT)
    fill_circle(img, d, 28, head_cy - 12, 3, BOW_LIGHT)
    px(img, d, 24, head_cy - 12, (255, 80, 130))

    # Blush
    fill_ellipse(img, d, 17, head_cy + 3, 3, 2, BLUSH)
    fill_ellipse(img, d, 31, head_cy + 3, 3, 2, BLUSH)

    # Eyes
    if hurt:
        # X eyes
        for i in range(-2, 3):
            px(img, d, 18 + i, head_cy + 1 + i, EYE)
            px(img, d, 18 + i, head_cy + 1 - i, EYE)
            px(img, d, 30 + i, head_cy + 1 + i, EYE)
            px(img, d, 30 + i, head_cy + 1 - i, EYE)
    elif dash:
        fill_circle(img, d, 19, head_cy + 2, 2, (255, 220, 80))
        fill_circle(img, d, 29, head_cy + 2, 2, (255, 220, 80))
        px(img, d, 18, head_cy + 1, EYE_HI)
        px(img, d, 28, head_cy + 1, EYE_HI)
    else:
        fill_circle(img, d, 19, head_cy + 2, 2, EYE)
        fill_circle(img, d, 29, head_cy + 2, 2, EYE)
        px(img, d, 18, head_cy + 1, EYE_HI)
        px(img, d, 28, head_cy + 1, EYE_HI)

    # Mouth
    for mx in range(22, 27):
        px(img, d, mx, head_cy + 7, (200, 120, 130))
    px(img, d, 23, head_cy + 6, (200, 120, 130))
    px(img, d, 26, head_cy + 6, (200, 120, 130))

    if highjump:
        for hx in range(14, 34, 4):
            fill_circle(img, d, hx, 44, 2, (255, 150, 200))

    if dash:
        for sx in range(2, 10, 2):
            fill_circle(img, d, sx, 24 + (sx % 3) * 2, 2, (255, 200, 255))

    return img


def build_player_sheet():
    frames = []
    # idle
    frames.append(draw_chibi_frame(leg_offset=0, arm_swing=0))
    frames.append(draw_chibi_frame(leg_offset=0, arm_swing=0, skirt_flap=0))  # bounce via position later
    # run 6 frames
    run_offsets = [(2, -2, 1), (1, 0, 0), (0, 2, -1), (-1, 0, 0), (-2, 2, 1), (0, -2, -1)]
    for lo, ar, sf in run_offsets:
        frames.append(draw_chibi_frame(leg_offset=lo, arm_swing=ar, skirt_flap=sf))
    # jump
    frames.append(draw_chibi_frame(jumping=True, arm_swing=-3))
    frames.append(draw_chibi_frame(jumping=True, arm_swing=0))
    frames.append(draw_chibi_frame(jumping=True, arm_swing=2))
    frames.append(draw_chibi_frame(leg_offset=0, arm_swing=0))
    # hurt
    frames.append(draw_chibi_frame(hurt=True))
    # sprint
    frames.append(draw_chibi_frame(dash=True, leg_offset=3, arm_swing=-3))
    frames.append(draw_chibi_frame(dash=True, leg_offset=3, arm_swing=-4))
    # highjump prep
    frames.append(draw_chibi_frame(highjump=True, jumping=True, arm_swing=-4))

    cols = 8
    rows = (len(frames) + cols - 1) // cols
    sheet = Image.new("RGBA", (48 * cols, 48 * rows), (0, 0, 0, 0))
    for i, fr in enumerate(frames):
        x = (i % cols) * 48
        y = (i // cols) * 48
        sheet.paste(fr, (x, y))
    path = os.path.join(ROOT, "player_sheet.png")
    sheet.save(path)
    print(f"Saved {path} ({len(frames)} frames)")


def draw_obstacle(kind):
    img = Image.new("RGBA", (48, 48), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    if kind == "cupcake":
        fill_ellipse(img, d, 24, 38, 14, 6, (220, 180, 140))
        fill_ellipse(img, d, 24, 30, 12, 10, (255, 180, 210))
        fill_ellipse(img, d, 24, 22, 10, 8, (255, 200, 230))
        fill_circle(img, d, 24, 14, 5, (255, 120, 160))
        fill_circle(img, d, 22, 13, 2, (255, 200, 220))
    elif kind == "teddy":
        fill_circle(img, d, 24, 28, 12, (210, 170, 130))
        fill_circle(img, d, 24, 16, 9, (210, 170, 130))
        fill_circle(img, d, 14, 10, 4, (210, 170, 130))
        fill_circle(img, d, 34, 10, 4, (210, 170, 130))
        fill_circle(img, d, 20, 15, 2, EYE)
        fill_circle(img, d, 28, 15, 2, EYE)
        fill_ellipse(img, d, 24, 19, 3, 2, (180, 130, 100))
        fill_circle(img, d, 16, 36, 5, (210, 170, 130))
        fill_circle(img, d, 32, 36, 5, (210, 170, 130))
        fill_circle(img, d, 24, 12, 3, (255, 150, 170))
    elif kind == "ribbon":
        for y in range(8, 44):
            px(img, d, 22, y, (255, 150, 200))
            px(img, d, 23, y, (255, 180, 220))
            px(img, d, 24, y, (255, 150, 200))
            px(img, d, 25, y, (255, 180, 220))
        fill_ellipse(img, d, 24, 8, 8, 4, (255, 120, 180))
        fill_ellipse(img, d, 16, 10, 5, 3, (255, 150, 200))
        fill_ellipse(img, d, 32, 10, 5, 3, (255, 150, 200))
    elif kind == "flower_pot":
        fill_ellipse(img, d, 24, 36, 12, 8, (200, 130, 90))
        fill_ellipse(img, d, 24, 30, 10, 4, (220, 150, 100))
        fill_circle(img, d, 18, 20, 5, (255, 150, 180))
        fill_circle(img, d, 30, 20, 5, (255, 180, 200))
        fill_circle(img, d, 24, 14, 5, (255, 120, 160))
        for gx in range(20, 29):
            px(img, d, gx, 26, (100, 180, 100))
    elif kind == "heart":
        fill_circle(img, d, 18, 22, 7, (255, 100, 150))
        fill_circle(img, d, 30, 22, 7, (255, 100, 150))
        fill_ellipse(img, d, 24, 30, 10, 9, (255, 100, 150))
        fill_circle(img, d, 22, 20, 2, (255, 200, 220))
    return img


def build_obstacles():
    for k in ["cupcake", "teddy", "ribbon", "flower_pot", "heart"]:
        p = os.path.join(ROOT, "obstacles", f"{k}.png")
        draw_obstacle(k).save(p)
        print(f"Saved {p}")


def build_tiles():
    grass = Image.new("RGBA", (32, 32), (0, 0, 0, 0))
    d = ImageDraw.Draw(grass)
    fill_ellipse(grass, d, 16, 20, 16, 14, (168, 230, 200))
    fill_ellipse(grass, d, 16, 22, 14, 10, (140, 210, 170))
    for fx, fy in [(8, 14), (22, 16), (14, 10), (26, 12)]:
        fill_circle(grass, d, fx, fy, 2, (255, 150, 180))
        px(grass, d, fx, fy - 1, (100, 180, 100))
    grass.save(os.path.join(ROOT, "tiles", "grass.png"))

    path = Image.new("RGBA", (32, 32), (0, 0, 0, 0))
    d = ImageDraw.Draw(path)
    fill_ellipse(path, d, 16, 20, 16, 14, (255, 200, 220))
    fill_ellipse(path, d, 16, 22, 14, 10, (255, 170, 200))
    for x in range(4, 28, 6):
        fill_circle(path, d, x, 18, 2, (255, 220, 235))
    path.save(os.path.join(ROOT, "tiles", "path.png"))

    # Seamless parallax sky tile (128x400) — fills viewport height.
    sky_w, sky_h = 128, 400
    sky = Image.new("RGBA", (sky_w, sky_h), (0, 0, 0, 0))
    d = ImageDraw.Draw(sky)
    for y in range(sky_h):
        t = y / sky_h
        r = int(184 + t * 30)
        g = int(212 + t * 22)
        b = int(240 + t * 12)
        for x in range(sky_w):
            px(sky, d, x, y, (r, g, b, 255))
    fill_ellipse(sky, d, 36, 70, 18, 10, (255, 248, 252))
    fill_ellipse(sky, d, 92, 110, 22, 12, (255, 252, 255))
    fill_ellipse(sky, d, 64, 180, 20, 11, (255, 250, 255))
    sky.save(os.path.join(ROOT, "tiles", "sky_tile.png"))

    # Seamless cloud layer (256x96).
    cloud_w, cloud_h = 256, 96
    clouds = Image.new("RGBA", (cloud_w, cloud_h), (0, 0, 0, 0))
    d = ImageDraw.Draw(clouds)
    fill_ellipse(clouds, d, 48, 36, 28, 14, (255, 250, 255, 220))
    fill_ellipse(clouds, d, 72, 40, 20, 10, (255, 245, 252, 200))
    fill_ellipse(clouds, d, 168, 48, 34, 16, (255, 252, 255, 230))
    fill_ellipse(clouds, d, 198, 52, 22, 11, (255, 248, 255, 210))
    fill_ellipse(clouds, d, 240, 38, 18, 9, (255, 250, 255, 180))
    clouds.save(os.path.join(ROOT, "tiles", "cloud_tile.png"))

    # Seamless hill tile (256x80) using periodic curve.
    hill_w, hill_h = 256, 80
    hill = Image.new("RGBA", (hill_w, hill_h), (0, 0, 0, 0))
    d = ImageDraw.Draw(hill)
    baseline = hill_h - 8

    def hill_height(x):
        return int(
            baseline
            - 18
            - 12 * math.sin((x / hill_w) * math.tau)
            - 6 * math.sin((x / hill_w) * math.tau * 2 + 1.2)
        )

    for x in range(hill_w):
        top = hill_height(x)
        for y in range(top, hill_h):
            t = (y - top) / max(baseline - top, 1)
            r = int(190 + t * 10)
            g = int(228 - t * 8)
            b = int(198 + t * 6)
            px(hill, d, x, y, (r, g, b, 255))

    for hx in range(16, hill_w, 24):
        hy = hill_height(hx) - 4
        fill_circle(hill, d, hx, hy, 2, (255, 170, 200))
        px(hill, d, hx, hy - 2, (90, 170, 100))

    hill.save(os.path.join(ROOT, "tiles", "hill_tile.png"))

    # Legacy names kept for compatibility.
    sky.save(os.path.join(ROOT, "tiles", "sky.png"))
    hill.save(os.path.join(ROOT, "tiles", "hill.png"))
    print("Saved tiles")


def build_ui_icons():
    for name, color in [("sprint", (255, 220, 100)), ("hop", (180, 220, 255)), ("shield", (255, 150, 200))]:
        icon = Image.new("RGBA", (32, 32), (0, 0, 0, 0))
        d = ImageDraw.Draw(icon)
        fill_circle(icon, d, 16, 16, 12, color)
        fill_circle(icon, d, 16, 16, 10, (255, 255, 255, 180))
        if name == "sprint":
            for i in range(4):
                px(icon, d, 22 + i, 14 + i, (255, 180, 50))
        elif name == "hop":
            for y in range(10, 22):
                px(icon, d, 16, y, (100, 150, 255))
            fill_circle(icon, d, 16, 8, 3, (100, 150, 255))
        else:
            fill_circle(icon, d, 16, 16, 8, (255, 200, 230))
        icon.save(os.path.join(ROOT, "ui", f"icon_{name}.png"))

    heart = Image.new("RGBA", (24, 24), (0, 0, 0, 0))
    d = ImageDraw.Draw(heart)
    fill_circle(heart, d, 8, 10, 6, (255, 80, 120))
    fill_circle(heart, d, 16, 10, 6, (255, 80, 120))
    fill_ellipse(heart, d, 12, 16, 8, 7, (255, 80, 120))
    heart.save(os.path.join(ROOT, "ui", "heart.png"))

    bubble = Image.new("RGBA", (64, 64), (0, 0, 0, 0))
    d = ImageDraw.Draw(bubble)
    fill_circle(bubble, d, 32, 32, 28, (255, 180, 220, 90))
    fill_circle(bubble, d, 32, 32, 26, (255, 220, 240, 60))
    fill_circle(bubble, d, 24, 24, 6, (255, 255, 255, 120))
    bubble.save(os.path.join(ROOT, "shield_bubble.png"))
    print("Saved UI icons")


if __name__ == "__main__":
    build_player_sheet()
    build_obstacles()
    build_tiles()
    build_ui_icons()
    print("All sprites generated!")
