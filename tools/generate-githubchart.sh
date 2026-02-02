#!/usr/bin/env bash
set -euo pipefail

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
config_file="$root_dir/_config.yml"
output_path="${1:-$root_dir/assets/img/githubchart.svg}"
sidebar_path="$root_dir/assets/img/githubchart-sidebar.svg"
color_hex="${GITHUBCHART_COLOR:-#295170}"

github_user="${GITHUB_USER:-}"
if [[ -z "$github_user" && -f "$config_file" ]]; then
  github_user="$(ruby -e 'require "yaml"; cfg = YAML.load_file(ARGV[0]); puts(cfg.dig("github","username") || "")' "$config_file")"
fi

if [[ -z "$github_user" ]]; then
  echo "github.username not found in _config.yml (or set GITHUB_USER)." >&2
  exit 1
fi

mkdir -p "$(dirname "$output_path")"

bundle exec githubchart -u "$github_user" "$output_path"

GITHUBCHART_INPUT="$output_path" GITHUBCHART_SIDEBAR="$sidebar_path" GITHUBCHART_COLOR="$color_hex" python3 - <<'PY'
import os
import xml.etree.ElementTree as ET
from pathlib import Path

input_path = Path(os.environ["GITHUBCHART_INPUT"])
output_path = Path(os.environ["GITHUBCHART_SIDEBAR"])
base_color = os.environ.get("GITHUBCHART_COLOR", "#295170").lstrip("#")

def hex_to_rgb(hex_str):
    return tuple(int(hex_str[i:i+2], 16) for i in (0, 2, 4))

def rgb_to_hex(rgb):
    return "#{:02x}{:02x}{:02x}".format(*rgb)

def mix_with_white(rgb, ratio):
    # ratio: 0..1, where 1 is full base color, 0 is white
    return tuple(int(round(255 * (1 - ratio) + channel * ratio)) for channel in rgb)

base_rgb = hex_to_rgb(base_color)
palette = {
    "0": "#eeeeee",
    "1": rgb_to_hex(mix_with_white(base_rgb, 0.25)),
    "2": rgb_to_hex(mix_with_white(base_rgb, 0.45)),
    "3": rgb_to_hex(mix_with_white(base_rgb, 0.7)),
    "4": rgb_to_hex(base_rgb),
}

tree = ET.parse(input_path)
root = tree.getroot()

def tag_name(el):
    return el.tag.split('}')[-1]

def update_fill(el, color):
    style = el.get("style")
    if style:
        parts = [p for p in style.split(";") if p]
        style_map = {}
        for part in parts:
            if ":" in part:
                key, value = part.split(":", 1)
                style_map[key.strip()] = value.strip()
        style_map["fill"] = color
        el.set("style", ";".join(f"{k}:{v}" for k, v in style_map.items()))
    else:
        el.set("fill", color)

for rect in root.iter():
    if tag_name(rect) != "rect":
        continue
    score = rect.get("data-score")
    if score in palette:
        update_fill(rect, palette[score])

# Write recolored main chart with labels intact
tree.write(input_path, encoding="utf-8", xml_declaration=True)

# Remove labels for sidebar chart
for parent in root.iter():
    for child in list(parent):
        if tag_name(child) == "text":
            parent.remove(child)

min_x = min_y = None
max_x = max_y = None
for rect in root.iter():
    if tag_name(rect) != "rect":
        continue
    try:
        x = float(rect.get("x", "0"))
        y = float(rect.get("y", "0"))
        w = float(rect.get("width", "0"))
        h = float(rect.get("height", "0"))
    except ValueError:
        continue
    if min_x is None:
        min_x = x
        min_y = y
        max_x = x + w
        max_y = y + h
        continue
    min_x = min(min_x, x)
    min_y = min(min_y, y)
    max_x = max(max_x, x + w)
    max_y = max(max_y, y + h)

if min_x is not None:
    width = max_x - min_x
    height = max_y - min_y
    root.set("viewBox", f"{min_x} {min_y} {width} {height}")
    root.set("width", f"{width}")
    root.set("height", f"{height}")

tree.write(output_path, encoding="utf-8", xml_declaration=True)
PY

echo "Wrote $output_path"
echo "Wrote $sidebar_path"
