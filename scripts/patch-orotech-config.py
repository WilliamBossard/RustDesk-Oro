#!/usr/bin/env python3
"""Patch hbb_common config for Orotech server, key and app name."""

import re
import sys
from pathlib import Path

CONFIG = Path("libs/hbb_common/src/config.rs")
SERVER = "51.91.55.73"
PUB_KEY = "D9iYR4YD5aHLPPm2x8EWPyxQmRyohiiXRtmiliWEcKo="
APP_NAME = "Assistance Oro"

if not CONFIG.is_file():
    print(f"ERROR: {CONFIG} not found", file=sys.stderr)
    sys.exit(1)

content = CONFIG.read_text(encoding="utf-8")
original = content

content, n1 = re.subn(
    r"pub const RENDEZVOUS_SERVERS.*",
    f'pub const RENDEZVOUS_SERVERS: &[&str] = &["{SERVER}"];',
    content,
    count=1,
)
content, n2 = re.subn(
    r'pub const RS_PUB_KEY.*',
    f'pub const RS_PUB_KEY: &str = "{PUB_KEY}";',
    content,
    count=1,
)
content, n3 = re.subn(
    r'pub static ref APP_NAME: RwLock<String> = RwLock::new\("[^"]*"\.to_owned\(\)\);',
    f'pub static ref APP_NAME: RwLock<String> = RwLock::new("{APP_NAME}".to_owned());',
    content,
    count=1,
)

if n1 != 1 or n2 != 1 or n3 != 1:
    print(
        f"ERROR: patch incomplete (servers={n1}, key={n2}, app_name={n3})",
        file=sys.stderr,
    )
    sys.exit(1)

if content == original:
    print("ERROR: no changes written", file=sys.stderr)
    sys.exit(1)

CONFIG.write_text(content, encoding="utf-8", newline="\n")

for label, needle in (
    ("server", SERVER),
    ("key", PUB_KEY),
    ("app_name", APP_NAME),
):
    if needle not in content:
        print(f"ERROR: {label} not found after patch", file=sys.stderr)
        sys.exit(1)

print("Orotech config patched successfully:")
for i, line in enumerate(content.splitlines(), 1):
    if "RENDEZVOUS_SERVERS" in line or "RS_PUB_KEY" in line or "APP_NAME" in line:
        if "pub " in line or "pub static" in line:
            print(f"  {i}: {line.strip()}")
