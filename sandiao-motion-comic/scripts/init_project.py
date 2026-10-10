#!/usr/bin/env python3
"""Create a sandiao-motion-comic project from the bundled project template."""

from __future__ import annotations

import argparse
import datetime as dt
import re
import sys
from pathlib import Path


SKILL_DIR = Path(__file__).resolve().parents[1]
TEMPLATE_DIR = SKILL_DIR / "assets" / "project-template"


def slugify(value: str) -> str:
    value = value.strip().lower()
    value = re.sub(r"[^\w\u4e00-\u9fff-]+", "-", value, flags=re.UNICODE)
    value = re.sub(r"-{2,}", "-", value).strip("-")
    return value or "motion-comic-project"


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Create a sandiao-motion-comic project from the bundled template."
    )
    parser.add_argument("target", help="Target project directory")
    parser.add_argument("--name", default="未命名漫剧", help="Project name")
    parser.add_argument("--platform", default="douyin", help="Target platform")
    parser.add_argument("--aspect", default="9:16", help="Aspect ratio")
    parser.add_argument(
        "--date",
        default=dt.date.today().isoformat(),
        help="Creation date (YYYY-MM-DD)",
    )
    parser.add_argument(
        "--force",
        action="store_true",
        help="Write into a non-empty target directory",
    )
    args = parser.parse_args()

    if not TEMPLATE_DIR.exists():
        print(f"Template directory not found: {TEMPLATE_DIR}", file=sys.stderr)
        return 1

    target = Path(args.target).expanduser().resolve()
    if target.exists() and any(target.iterdir()) and not args.force:
        print(
            f"Target is not empty: {target}\nUse --force to overwrite template files.",
            file=sys.stderr,
        )
        return 1

    target.mkdir(parents=True, exist_ok=True)
    replacements = {
        "{{PROJECT_NAME}}": args.name,
        "{{SLUG}}": slugify(args.name),
        "{{DATE}}": args.date,
        "{{PLATFORM}}": args.platform,
        "{{ASPECT}}": args.aspect,
    }

    created: list[Path] = []
    for src in sorted(TEMPLATE_DIR.rglob("*")):
        if not src.is_file():
            continue
        rel = src.relative_to(TEMPLATE_DIR)
        dst = target / rel
        dst.parent.mkdir(parents=True, exist_ok=True)
        text = src.read_text(encoding="utf-8")
        for key, value in replacements.items():
            text = text.replace(key, value)
        dst.write_text(text, encoding="utf-8")
        created.append(dst)

    print(f"Created project: {target}")
    for path in created:
        print(f"  - {path.relative_to(target)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
