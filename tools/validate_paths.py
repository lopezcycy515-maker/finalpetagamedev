import os
import re

root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
refs = []
for dirpath, _, files in os.walk(root):
    if ".godot" in dirpath:
        continue
    for f in files:
        if f.endswith((".tscn", ".tres", ".gd", ".godot")):
            p = os.path.join(dirpath, f)
            with open(p, encoding="utf-8") as fh:
                txt = fh.read()
            for m in re.finditer(r"res://[^\s\"']+", txt):
                refs.append(m.group(0))

missing = []
for r in sorted(set(refs)):
    if r.endswith((".png", ".gd", ".tscn", ".tres", ".svg")):
        path = os.path.join(root, r.replace("res://", "").replace("/", os.sep))
        if not os.path.exists(path):
            missing.append(r)

print("Missing:", missing or "NONE")
print("Total unique refs:", len(set(refs)))
