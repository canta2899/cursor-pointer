#!/usr/bin/env python3
# /// script
# dependencies = ["Pillow"]
# ///
"""
This is a completely vibe-coded that generates the app icon and the menu-bar icon
"""

import os
import subprocess

from PIL import Image, ImageDraw, ImageFilter


def lerp(a: float, b: float, t: float) -> float:
    return a + (b - a) * t


def bezier(p0, p1, p2, t):
    """Quadratic Bezier point at parameter t."""
    x = (1 - t) ** 2 * p0[0] + 2 * (1 - t) * t * p1[0] + t**2 * p2[0]
    y = (1 - t) ** 2 * p0[1] + 2 * (1 - t) * t * p1[1] + t**2 * p2[1]
    return x, y


def composite_circle(
    canvas: Image.Image, cx: float, cy: float, radius: float, color: tuple, alpha: int
) -> Image.Image:
    """Alpha-composite a single filled circle onto canvas."""
    if radius < 0.5 or alpha < 1:
        return canvas
    layer = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)
    d.ellipse(
        [cx - radius, cy - radius, cx + radius, cy + radius], fill=(*color, alpha)
    )
    return Image.alpha_composite(canvas, layer)


def draw_app_icon(size: int) -> Image.Image:
    """
    Dark rounded-square background, a bright red laser dot, and a curved
    trail fading from lower-left toward the dot.
    """
    canvas = Image.new("RGBA", (size, size), (0, 0, 0, 0))

    # Background
    bg = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    ImageDraw.Draw(bg).rounded_rectangle(
        [0, 0, size - 1, size - 1],
        radius=max(4, size // 5),
        fill=(18, 18, 30, 255),
    )
    canvas = Image.alpha_composite(canvas, bg)

    # Geometry
    dot_x, dot_y = size * 0.60, size * 0.43  # laser dot centre
    tail_x, tail_y = size * 0.13, size * 0.76  # tail tip
    ctrl_x, ctrl_y = size * 0.16, size * 0.26  # bezier control → curves upward

    dot_r = size * 0.085
    steps = max(48, size // 4)

    # Trail: series of soft glowing circles along the bezier curve
    for i in range(steps):
        t = i / steps
        bx, by = bezier((tail_x, tail_y), (ctrl_x, ctrl_y), (dot_x, dot_y), t)
        r = dot_r * lerp(0.06, 0.50, t)
        base_alpha = int(lerp(0, 190, t))

        # Outer glow
        canvas = composite_circle(
            canvas, bx, by, r * 3.2, (255, 40, 20), int(base_alpha * 0.12)
        )
        canvas = composite_circle(
            canvas, bx, by, r * 1.9, (255, 55, 30), int(base_alpha * 0.28)
        )
        # Core trail
        canvas = composite_circle(canvas, bx, by, r, (255, 90, 60), base_alpha)

    # Main dot: layered glow rings + bright core
    glow_layers = [
        (4.0, (255, 25, 10), 55),
        (2.8, (255, 50, 25), 90),
        (1.8, (255, 90, 55), 140),
        (1.2, (255, 150, 100), 200),
        (1.0, (255, 230, 210), 255),
    ]
    for scale, color, alpha in glow_layers:
        canvas = composite_circle(canvas, dot_x, dot_y, dot_r * scale, color, alpha)

    # Subtle smoothing for the glow edges
    if size >= 64:
        canvas = canvas.filter(ImageFilter.GaussianBlur(radius=max(0.5, size * 0.007)))

    return canvas


def draw_menubar_icon(size: int) -> Image.Image:
    """
    Monochrome (black on transparent) template image — same dot+trail shape.
    macOS will tint it automatically for dark/light mode.
    """
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    dot_r = size * 0.21
    dot_x, dot_y = size * 0.65, size * 0.37
    tail_x, tail_y = size * 0.11, size * 0.80
    ctrl_x, ctrl_y = size * 0.14, size * 0.25

    steps = max(30, size * 3)

    # Fading trail
    for i in range(steps):
        t = i / steps
        bx, by = bezier((tail_x, tail_y), (ctrl_x, ctrl_y), (dot_x, dot_y), t)
        r = dot_r * lerp(0.05, 0.46, t)
        alpha = int(lerp(0, 210, t**1.4))
        draw.ellipse([bx - r, by - r, bx + r, by + r], fill=(0, 0, 0, alpha))

    # Solid dot
    draw.ellipse(
        [dot_x - dot_r, dot_y - dot_r, dot_x + dot_r, dot_y + dot_r],
        fill=(0, 0, 0, 255),
    )
    return img


ICONSET_SIZES = [
    ("icon_16x16.png", 16),
    ("icon_16x16@2x.png", 32),
    ("icon_32x32.png", 32),
    ("icon_32x32@2x.png", 64),
    ("icon_128x128.png", 128),
    ("icon_128x128@2x.png", 256),
    ("icon_256x256.png", 256),
    ("icon_256x256@2x.png", 512),
    ("icon_512x512.png", 512),
    ("icon_512x512@2x.png", 1024),
]


def main():
    resources = "Sources/Resources"
    iconset = os.path.join(resources, "AppIcon.iconset")
    os.makedirs(iconset, exist_ok=True)

    print("Generating app iconset…")
    for filename, size in ICONSET_SIZES:
        img = draw_app_icon(size)
        img.save(os.path.join(iconset, filename))
        print(f"  {filename:<28}  ({size}×{size})")

    print("\nGenerating menu-bar template icons…")
    for size, suffix in [(16, ""), (32, "@2x")]:
        img = draw_menubar_icon(size)
        path = os.path.join(resources, f"MenuBarIconTemplate{suffix}.png")
        img.save(path)
        print(f"  MenuBarIconTemplate{suffix}.png  ({size}×{size})")

    print("\nConverting iconset → AppIcon.icns …")
    icns = os.path.join(resources, "AppIcon.icns")
    ret = subprocess.check_call(
        ["iconutil", "-c", "icns", f'"{iconset}"', "-o", f'"{icns}"']
    )
    if ret == 0:
        print(f"  Done: {icns}")
    else:
        print("  iconutil failed — run manually:")
        print(f'    iconutil -c icns "{iconset}" -o "{icns}"')


if __name__ == "__main__":
    main()
