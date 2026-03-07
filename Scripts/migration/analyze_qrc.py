#!/usr/bin/env python3
"""Repository-wide QRC inventory and usage analyzer."""

from __future__ import annotations

import csv
import json
import re
import xml.etree.ElementTree as ET
from collections import defaultdict
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[2]
DOCS_DIR = REPO_ROOT / "docs" / "migration"

TEXT_EXTENSIONS = {".qml", ".cpp", ".h", ".hpp", ".cc", ".cxx", ".cmake", ".txt"}
SKIP_PARTS = {".git", ".cursor", ".idea", "build", "cmake-build-debug", "cmake-build-release"}
SOURCE_SCAN_DIRS = ["PowerTune", "Core", "Prism", "Utils", "Hardware"]
SOURCE_SCAN_FILES = ["main.cpp", "CMakeLists.txt"]

QRC_REF_PATTERN = re.compile(r"[\"'](qrc:/[^\"']+|:/[^\"']+)[\"']")


def rel(path: Path) -> str:
    return str(path.relative_to(REPO_ROOT)).replace("\\", "/")


def iter_source_files():
    for folder in SOURCE_SCAN_DIRS:
        base = REPO_ROOT / folder
        if not base.exists():
            continue
        for file in base.rglob("*"):
            if any(part in SKIP_PARTS for part in file.parts):
                continue
            if file.is_file():
                yield file
    for file_name in SOURCE_SCAN_FILES:
        file = REPO_ROOT / file_name
        if file.exists() and file.is_file():
            yield file


def normalize_ref(raw: str) -> str:
    if raw.startswith("qrc:/"):
        return "/" + raw[len("qrc:/"):].lstrip("/")
    if raw.startswith(":/"):
        return "/" + raw[len(":/"):].lstrip("/")
    return raw


def has_nested_duplicate_segment(path: str) -> bool:
    parts = [p for p in path.split("/") if p]
    return any(parts[i] == parts[i + 1] for i in range(len(parts) - 1))


def collect_qrc_inventory():
    qrc_files = []
    registered = defaultdict(list)
    for file in sorted(REPO_ROOT.rglob("*.qrc")):
        if any(part in SKIP_PARTS for part in file.parts):
            continue
        try:
            root = ET.parse(file).getroot()
        except ET.ParseError:
            continue

        qrc_entry = {"qrcFile": rel(file), "resources": []}
        for qresource in root.findall("qresource"):
            prefix = qresource.attrib.get("prefix", "")
            entries = []
            for f in qresource.findall("file"):
                file_path = (f.text or "").strip()
                alias = f.attrib.get("alias", "")
                depth = max(len(Path(file_path).parts) - 1, 0)
                prefix_part = "/" + prefix.strip("/") if prefix else ""
                registered_path = f"{prefix_part}/{file_path}".replace("//", "/")
                registered_path = "/" + registered_path.strip("/")
                entries.append(
                    {
                        "file": file_path,
                        "alias": alias,
                        "folderDepth": depth,
                        "registeredPath": registered_path,
                    }
                )
                registered[registered_path].append(
                    {
                        "qrcFile": rel(file),
                        "prefix": prefix,
                        "file": file_path,
                        "alias": alias,
                    }
                )
            qrc_entry["resources"].append({"prefix": prefix, "entries": entries})
        qrc_files.append(qrc_entry)
    return qrc_files, registered


def collect_usage():
    rows = []
    refs = defaultdict(list)
    seen = set()
    for file in iter_source_files():
        norm_rel = rel(file)
        if norm_rel in seen:
            continue
        seen.add(norm_rel)
        if file.suffix.lower() not in TEXT_EXTENSIONS:
            continue
        try:
            lines = file.read_text(encoding="utf-8", errors="ignore").splitlines()
        except OSError:
            continue
        for n, line in enumerate(lines, 1):
            for m in QRC_REF_PATTERN.finditer(line):
                raw = m.group(1)
                norm = normalize_ref(raw)
                rows.append(
                    {
                        "file": rel(file),
                        "line": n,
                        "rawRef": raw,
                        "normalizedRef": norm,
                        "hasNestedDuplicateSegments": has_nested_duplicate_segment(norm),
                        "isPrismPTRoot": "/PrismPT/" in norm,
                        "isPowerTuneRoot": "/PowerTune/" in norm,
                        "lineText": line.strip(),
                    }
                )
                refs[norm].append({"file": rel(file), "line": n, "rawRef": raw})
    return rows, refs


def write_inventory(qrc_files, registered):
    out_json = DOCS_DIR / "qrc-inventory.json"
    out_md = DOCS_DIR / "qrc-inventory.md"

    payload = {"qrcFileCount": len(qrc_files), "inventory": qrc_files}
    out_json.write_text(json.dumps(payload, indent=2), encoding="utf-8")

    duplicates = {k: v for k, v in registered.items() if len(v) > 1}
    total_entries = sum(len(r["entries"]) for f in qrc_files for r in f["resources"])
    lines = [
        "# QRC Inventory",
        "",
        f"- QRC files found: **{len(qrc_files)}**",
        f"- Total registered entries: **{total_entries}**",
        f"- Duplicate registered paths: **{len(duplicates)}**",
        "",
        "## Files",
        "",
    ]
    for q in qrc_files:
        lines.append(f"### `{q['qrcFile']}`")
        for r in q["resources"]:
            prefix = r["prefix"] if r["prefix"] else "/"
            lines.append(f"- Prefix `{prefix}`: {len(r['entries'])} entries")
        lines.append("")
    lines.extend(["## Duplicate Registrations", ""])
    if not duplicates:
        lines.append("- None")
    else:
        for path, regs in sorted(duplicates.items()):
            lines.append(f"- `{path}`")
            for reg in regs:
                lines.append(f"  - `{reg['qrcFile']}` (prefix `{reg['prefix']}`)")
    out_md.write_text("\n".join(lines) + "\n", encoding="utf-8")


def write_usage(rows):
    out_csv = DOCS_DIR / "qrc-usage-map.csv"
    with out_csv.open("w", encoding="utf-8", newline="") as f:
        writer = csv.DictWriter(
            f,
            fieldnames=[
                "file",
                "line",
                "rawRef",
                "normalizedRef",
                "hasNestedDuplicateSegments",
                "isPrismPTRoot",
                "isPowerTuneRoot",
                "lineText",
            ],
        )
        writer.writeheader()
        writer.writerows(rows)


def write_disconnect_report(rows, refs, registered):
    out_md = DOCS_DIR / "qrc-disconnects-and-orphans.md"
    referenced = set(refs.keys())
    registered_set = set(registered.keys())
    ref_unreg = sorted(referenced - registered_set)
    reg_orphan = sorted(registered_set - referenced)
    nested_dups = sorted({r["normalizedRef"] for r in rows if r["hasNestedDuplicateSegments"]})
    mixed_roots = sorted(
        {
            r["normalizedRef"]
            for r in rows
            if r["isPrismPTRoot"] and r["isPowerTuneRoot"]
        }
    )

    lines = [
        "# QRC Disconnects and Orphans",
        "",
        f"- Referenced QRC paths: **{len(referenced)}**",
        f"- Registered QRC paths: **{len(registered_set)}**",
        f"- Referenced but not registered: **{len(ref_unreg)}**",
        f"- Registered but not referenced: **{len(reg_orphan)}**",
        f"- Paths with nested duplicate segments: **{len(nested_dups)}**",
        "",
        "## Referenced but Not Registered",
        "",
    ]
    lines.extend([f"- `{p}`" for p in ref_unreg] or ["- None"])
    lines.extend(["", "## Registered but Not Referenced", ""])
    lines.extend([f"- `{p}`" for p in reg_orphan] or ["- None"])
    lines.extend(["", "## Nested Duplicate Segment Paths", ""])
    lines.extend([f"- `{p}`" for p in nested_dups] or ["- None"])
    lines.extend(["", "## Mixed PrismPT and PowerTune Roots", ""])
    lines.extend([f"- `{p}`" for p in mixed_roots] or ["- None"])

    out_md.write_text("\n".join(lines) + "\n", encoding="utf-8")


def write_phase_report(qrc_files, usage_rows):
    out = DOCS_DIR / "phase-01-qrc-audit.md"
    qrc_count = len(qrc_files)
    usage_count = len(usage_rows)
    nested = sum(1 for r in usage_rows if r["hasNestedDuplicateSegments"])
    prism_refs = sum(1 for r in usage_rows if r["isPrismPTRoot"])
    power_refs = sum(1 for r in usage_rows if r["isPowerTuneRoot"])

    lines = [
        "# Phase 01 - QRC Audit",
        "",
        "## Scope",
        "",
        "Generated full-repository QRC inventory and active-source QRC usage mapping for migration planning and cutover safety.",
        "",
        "## Results",
        "",
        f"- QRC files discovered: **{qrc_count}**",
        f"- QRC path references in code: **{usage_count}**",
        f"- References with nested duplicate segments: **{nested}**",
        f"- PrismPT-root references: **{prism_refs}**",
        f"- PowerTune-root references: **{power_refs}**",
        "",
        "## Artifacts",
        "",
        "- `docs/migration/qrc-inventory.json`",
        "- `docs/migration/qrc-inventory.md`",
        "- `docs/migration/qrc-usage-map.csv`",
        "- `docs/migration/qrc-disconnects-and-orphans.md`",
        "",
        "## Follow-Up",
        "",
        "Use generated disconnect findings to drive targeted fixes in Phase 02 and systematic cutover in Phase 06.",
    ]
    out.write_text("\n".join(lines) + "\n", encoding="utf-8")


def main():
    DOCS_DIR.mkdir(parents=True, exist_ok=True)
    qrc_files, registered = collect_qrc_inventory()
    usage_rows, refs = collect_usage()
    write_inventory(qrc_files, registered)
    write_usage(usage_rows)
    write_disconnect_report(usage_rows, refs, registered)
    write_phase_report(qrc_files, usage_rows)
    print("Generated migration QRC artifacts in docs/migration")


if __name__ == "__main__":
    main()
