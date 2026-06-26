#!/usr/bin/env bash
set -euo pipefail

CONFIG="libs/hbb_common/src/config.rs"

# perl -pi works on both GNU/Linux and macOS (BSD sed -i requires a backup extension)
perl -pi -e 's|pub const RENDEZVOUS_SERVERS.*|pub const RENDEZVOUS_SERVERS: \&[\&str] = \&["51.91.55.73"];|' "$CONFIG"
perl -pi -e 's|pub const RS_PUB_KEY.*|pub const RS_PUB_KEY: \&str = "D9iYR4YD5aHLPPm2x8EWPyxQmRyohiiXRtmiliWEcKo=";|' "$CONFIG"
perl -pi -e 's|pub static ref APP_NAME: RwLock<String> = RwLock::new\("RustDesk"\.to_owned\(\)\);|pub static ref APP_NAME: RwLock<String> = RwLock::new("Assistance Oro".to_owned());|' "$CONFIG"

echo "Orotech config patched:"
grep -n "RENDEZVOUS_SERVERS\|RS_PUB_KEY\|APP_NAME" "$CONFIG" | head -5
