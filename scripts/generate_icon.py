#!/usr/bin/env python3
"""Generate app icon and splash image for PointBook.

Run from the project root:
    python3 scripts/generate_icon.py

Outputs:
    assets/icon/app_icon.png                                      — master 1024x1024
    android/app/src/main/res/mipmap-{mdpi..xxxhdpi}/ic_launcher.png
    android/app/src/main/res/drawable/splash.png                  — splash (transparent bg)
"""

import os
import numpy as np
from PIL import Image, ImageDraw

MASTER_PATH = os.path.join("assets", "icon", "app_icon.png")
SPLASH_PATH = os.path.join("android", "app", "src", "main", "res", "drawable", "splash.png")
ANDROID_RES = os.path.join("android", "app", "src", "main", "res")

MIPMAP_SIZES = {
    "mipmap-mdpi":    48,
    "mipmap-hdpi":    72,
    "mipmap-xhdpi":   96,
    "mipmap-xxhdpi":  144,
    "mipmap-xxxhdpi": 192,
}


def make_coin_rgba(size: int) -> Image.Image:
    """Render the coin design as RGBA with transparent background.

    SVG design (scaled from 512px viewBox):
      - Outer circle r=230: fill=#2060C0, opacity=0.5
      - Main  circle r=210: linear gradient #7DBDFF → #4A8FE8 → #2860C8
      - Inner ring   r=170: white stroke=6, opacity=0.25
    """
    center = size // 2
    scale = size / 512.0

    result = Image.new("RGBA", (size, size), (0, 0, 0, 0))

    # --- 1. Outer semi-transparent circle ---
    outer_r = int(230 * scale)
    outer_layer = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    ImageDraw.Draw(outer_layer).ellipse(
        [center - outer_r, center - outer_r, center + outer_r, center + outer_r],
        fill=(0x20, 0x60, 0xC0, 127),  # #2060C0 at 50% opacity
    )
    result = Image.alpha_composite(result, outer_layer)

    # --- 2. Gradient circle ---
    grad_r = int(210 * scale)

    # Gradient stops: 0%=#7DBDFF, 50%=#4A8FE8, 100%=#2860C8
    c0 = np.array([0x7D, 0xBD, 0xFF], dtype=np.float32)
    c1 = np.array([0x4A, 0x8F, 0xE8], dtype=np.float32)
    c2 = np.array([0x28, 0x60, 0xC8], dtype=np.float32)

    # Linear gradient direction: (x1=20%,y1=10%) → (x2=80%,y2=90%)
    gx1, gy1 = 0.2 * size, 0.1 * size
    gx2, gy2 = 0.8 * size, 0.9 * size
    dx, dy = gx2 - gx1, gy2 - gy1
    length_sq = float(dx * dx + dy * dy)

    y_arr, x_arr = np.mgrid[0:size, 0:size]
    t = ((x_arr.astype(np.float32) - gx1) * dx +
         (y_arr.astype(np.float32) - gy1) * dy) / length_sq
    t = np.clip(t, 0.0, 1.0)

    first = t < 0.5
    t1 = np.where(first, t / 0.5, 0.0).astype(np.float32)
    t2 = np.where(~first, (t - 0.5) / 0.5, 0.0).astype(np.float32)

    r_ch = np.where(first, c0[0] + t1 * (c1[0] - c0[0]),
                            c1[0] + t2 * (c2[0] - c1[0])).astype(np.uint8)
    g_ch = np.where(first, c0[1] + t1 * (c1[1] - c0[1]),
                            c1[1] + t2 * (c2[1] - c1[1])).astype(np.uint8)
    b_ch = np.where(first, c0[2] + t1 * (c1[2] - c0[2]),
                            c1[2] + t2 * (c2[2] - c1[2])).astype(np.uint8)
    a_ch = np.full((size, size), 255, dtype=np.uint8)

    gradient_img = Image.fromarray(np.stack([r_ch, g_ch, b_ch, a_ch], axis=2), "RGBA")

    # Clip gradient to circle
    circle_mask = Image.new("L", (size, size), 0)
    ImageDraw.Draw(circle_mask).ellipse(
        [center - grad_r, center - grad_r, center + grad_r, center + grad_r],
        fill=255,
    )
    gradient_circle = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    gradient_circle.paste(gradient_img, mask=circle_mask)
    result = Image.alpha_composite(result, gradient_circle)

    # --- 3. Inner ring ---
    ring_r = int(170 * scale)
    stroke_w = max(2, int(6 * scale))
    ring_layer = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    ImageDraw.Draw(ring_layer).ellipse(
        [center - ring_r, center - ring_r, center + ring_r, center + ring_r],
        fill=None,
        outline=(255, 255, 255, 64),  # white at 25% opacity
        width=stroke_w,
    )
    result = Image.alpha_composite(result, ring_layer)

    return result


def on_white(coin: Image.Image) -> Image.Image:
    """Composite coin (RGBA) onto an opaque white background."""
    bg = Image.new("RGBA", coin.size, (255, 255, 255, 255))
    return Image.alpha_composite(bg, coin)


def main() -> None:
    # Master (1024x1024, white bg)
    print("Generating master icon (1024x1024)…")
    master = on_white(make_coin_rgba(1024))
    os.makedirs(os.path.dirname(MASTER_PATH), exist_ok=True)
    master.save(MASTER_PATH, "PNG")
    print(f"  Saved {MASTER_PATH}")

    # Android mipmap icons (scaled from master)
    print("Generating Android mipmap icons…")
    for density, px in MIPMAP_SIZES.items():
        out_path = os.path.join(ANDROID_RES, density, "ic_launcher.png")
        master.resize((px, px), Image.LANCZOS).convert("RGB").save(out_path, "PNG")
        print(f"  Saved {out_path}  ({px}×{px})")

    # Splash (512x512, transparent bg — XML provides white background)
    print("Generating splash image (512x512)…")
    splash = make_coin_rgba(512)
    splash.save(SPLASH_PATH, "PNG")
    print(f"  Saved {SPLASH_PATH}")

    print("Done.")


if __name__ == "__main__":
    main()
