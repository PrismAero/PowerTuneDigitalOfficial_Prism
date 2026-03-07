#!/usr/bin/env python3
"""Verify graphics/font resource integration against qml.qrc and active QML usage."""

from __future__ import annotations

import json
import re
import xml.etree.ElementTree as ET
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[2]
QRC_FILE = REPO_ROOT / "qml.qrc"
DOCS_DIR = REPO_ROOT / "docs" / "migration"

QML_SCAN_DIRS = ["PowerTune", "Prism"]
RESOURCE_REF_RE = re.compile(r"qrc:/Resources/([^\"]+)")


def normalize_qrc_resource(path_part: str) -> str:
    return f"Resources/{path_part}".replace("//", "/")


def load_qrc_entries() -> set[str]:
    tree = ET.parse(QRC_FILE)
    root = tree.getroot()
    entries = set()
    for qresource in root.findall("qresource"):
        for f in qresource.findall("file"):
            path = (f.text or "").strip()
            if path:
                entries.add(path)
    return entries


def collect_resource_refs() -> set[str]:
    refs = set()
    for dirname in QML_SCAN_DIRS:
        base = REPO_ROOT / dirname
        if not base.exists():
            continue
        for qml in base.rglob("*.qml"):
            text = qml.read_text(encoding="utf-8", errors="ignore")
            for match in RESOURCE_REF_RE.findall(text):
                refs.add(normalize_qrc_resource(match))
    return refs


def main():
    DOCS_DIR.mkdir(parents=True, exist_ok=True)
    qrc_entries = load_qrc_entries()
    refs = collect_resource_refs()

    missing_in_qrc = sorted(refs - qrc_entries)
    unreferenced_in_qrc = sorted(
        p for p in qrc_entries - refs if p.startswith("Resources/graphics/") or p.startswith("Resources/fonts/")
    )

    font_path = "Resources/fonts/MaterialSymbolsOutlined.ttf"
    font_registered = font_path in qrc_entries
    font_exists = (REPO_ROOT / font_path).exists()

    payload = {
        "qrcEntriesCount": len(qrc_entries),
        "resourceRefsCount": len(refs),
        "missingInQrc": missing_in_qrc,
        "unreferencedResourceEntries": unreferenced_in_qrc,
        "fontCheck": {
            "path": font_path,
            "registeredInQrc": font_registered,
            "existsOnDisk": font_exists,
        },
    }

    (DOCS_DIR / "assets-fonts-verification.json").write_text(
        json.dumps(payload, indent=2), encoding="utf-8"
    )

    lines = [
        "# Assets and Fonts Verification",
        "",
        f"- QRC entries scanned: **{len(qrc_entries)}**",
        f"- Active resource references scanned: **{len(refs)}**",
        f"- Referenced but missing in qrc: **{len(missing_in_qrc)}**",
        f"- QRC graphics/fonts entries currently unreferenced: **{len(unreferenced_in_qrc)}**",
        "",
        "## Font Registration Check",
        "",
        f"- `MaterialSymbolsOutlined.ttf` on disk: **{'yes' if font_exists else 'no'}**",
        f"- `MaterialSymbolsOutlined.ttf` in qml.qrc: **{'yes' if font_registered else 'no'}**",
        "",
        "## Referenced but Missing in qrc",
        "",
    ]
    lines.extend([f"- `{p}`" for p in missing_in_qrc] or ["- None"])
    lines.extend(["", "## Unreferenced graphics/fonts entries in qrc", ""])
    lines.extend([f"- `{p}`" for p in unreferenced_in_qrc] or ["- None"])

    (DOCS_DIR / "assets-fonts-verification.md").write_text(
        "\n".join(lines) + "\n", encoding="utf-8"
    )
    print("Generated assets-fonts-verification artifacts")


if __name__ == "__main__":
    main()
