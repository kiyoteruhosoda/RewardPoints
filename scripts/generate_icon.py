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


def _draw_gradient_circle(result: Image.Image, size: int, center: int, radius: int,
                           c0: "np.ndarray", c1: "np.ndarray", c2: "np.ndarray") -> Image.Image:
    """Draw a gradient-filled circle onto result and return the composited image."""
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

    circle_mask = Image.new("L", (size, size), 0)
    ImageDraw.Draw(circle_mask).ellipse(
        [center - radius, center - radius, center + radius, center + radius],
        fill=255,
    )
    gradient_circle = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    gradient_circle.paste(gradient_img, mask=circle_mask)
    return Image.alpha_composite(result, gradient_circle)


def make_coin_rgba(size: int) -> Image.Image:
    """Render the blue coin design as RGBA with transparent background.

    Coin fills exactly to the icon boundary (outer_r = center).

    SVG design (proportional):
      - Outer circle = icon boundary: fill=#2060C0, opacity=0.5
      - Main  circle r=210/230 of half-size: linear gradient #7DBDFF → #4A8FE8 → #2860C8
      - Inner ring   r=170/230 of half-size: white stroke=6, opacity=0.25
    """
    center = size // 2
    scale = size / 512.0

    result = Image.new("RGBA", (size, size), (0, 0, 0, 0))

    # --- 1. Outer semi-transparent circle (fills exactly to icon boundary) ---
    outer_r = center
    outer_layer = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    ImageDraw.Draw(outer_layer).ellipse(
        [center - outer_r, center - outer_r, center + outer_r, center + outer_r],
        fill=(0x20, 0x60, 0xC0, 127),  # #2060C0 at 50% opacity
    )
    result = Image.alpha_composite(result, outer_layer)

    # --- 2. Gradient circle (proportional to original design) ---
    grad_r = int(210 * scale)

    c0 = np.array([0x7D, 0xBD, 0xFF], dtype=np.float32)
    c1 = np.array([0x4A, 0x8F, 0xE8], dtype=np.float32)
    c2 = np.array([0x28, 0x60, 0xC8], dtype=np.float32)

    result = _draw_gradient_circle(result, size, center, grad_r, c0, c1, c2)

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


def make_white_coin_rgba(size: int) -> Image.Image:
    """Render a white coin design as RGBA with transparent background.

    Used for the splash screen (blue background provided by XML).

    Design (inverted from blue coin):
      - Outer circle = icon boundary: white at 25% opacity (soft glow)
      - Main  circle r=210/230 of half-size: gradient #FFFFFF → #E8F0FF → #C8D8F8
      - Inner ring   r=170/230 of half-size: blue stroke at 25% opacity
    """
    center = size // 2
    scale = size / 512.0

    result = Image.new("RGBA", (size, size), (0, 0, 0, 0))

    # --- 1. Outer semi-transparent white circle (fills exactly to boundary) ---
    outer_r = center
    outer_layer = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    ImageDraw.Draw(outer_layer).ellipse(
        [center - outer_r, center - outer_r, center + outer_r, center + outer_r],
        fill=(255, 255, 255, 64),  # white at 25% opacity
    )
    result = Image.alpha_composite(result, outer_layer)

    # --- 2. White gradient circle ---
    grad_r = int(210 * scale)

    c0 = np.array([0xFF, 0xFF, 0xFF], dtype=np.float32)   # #FFFFFF
    c1 = np.array([0xE8, 0xF0, 0xFF], dtype=np.float32)   # #E8F0FF
    c2 = np.array([0xC8, 0xD8, 0xF8], dtype=np.float32)   # #C8D8F8

    result = _draw_gradient_circle(result, size, center, grad_r, c0, c1, c2)

    # --- 3. Inner ring (blue at 25% opacity) ---
    ring_r = int(170 * scale)
    stroke_w = max(2, int(6 * scale))
    ring_layer = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    ImageDraw.Draw(ring_layer).ellipse(
        [center - ring_r, center - ring_r, center + ring_r, center + ring_r],
        fill=None,
        outline=(0x28, 0x60, 0xC8, 64),  # #2860C8 at 25% opacity
        width=stroke_w,
    )
    result = Image.alpha_composite(result, ring_layer)

    return result


def main() -> None:
    # Master (1024x1024, transparent bg)
    print("Generating master icon (1024x1024)…")
    master = make_coin_rgba(1024)
    os.makedirs(os.path.dirname(MASTER_PATH), exist_ok=True)
    master.save(MASTER_PATH, "PNG")
    print(f"  Saved {MASTER_PATH}")

    # Android mipmap icons (RGBA — transparent background)
    print("Generating Android mipmap icons…")
    for density, px in MIPMAP_SIZES.items():
        out_path = os.path.join(ANDROID_RES, density, "ic_launcher.png")
        make_coin_rgba(px).save(out_path, "PNG")
        print(f"  Saved {out_path}  ({px}×{px})")

    # Splash (512x512, white coin on transparent bg — XML provides blue background)
    print("Generating splash image (512x512)…")
    splash = make_white_coin_rgba(512)
    splash.save(SPLASH_PATH, "PNG")
    print(f"  Saved {SPLASH_PATH}")

    print("Done.")


if __name__ == "__main__":
    main()
