#!/usr/bin/env bash
set -euo pipefail

CONFIG="libs/hbb_common/src/config.rs"

# perl -pi works on both GNU/Linux and macOS (BSD sed -i requires a backup extension)
perl -pi -e 's|pub const RENDEZVOUS_SERVERS.*|pub const RENDEZVOUS_SERVERS: \&[\&str] = \&["51.91.55.73"];|' "$CONFIG"
perl -pi -e 's|pub const RS_PUB_KEY.*|pub const RS_PUB_KEY: \&str = "D9iYR4YD5aHLPPm2x8EWPyxQmRyohiiXRtmiliWEcKo=";|' "$CONFIG"
perl -pi -e 's|pub static ref APP_NAME: RwLock<String> = RwLock::new\("RustDesk"\.to_owned\(\)\);|pub static ref APP_NAME: RwLock<String> = RwLock::new("Assistance Oro".to_owned());|' "$CONFIG"

# Patch allow-remote-config-modification to always return "Y"
# Method 1 : patch get_local_option dans hbb_common si elle existe
perl -pi -e 's|pub fn get_local_option\(key: &str\) -> String \{|pub fn get_local_option(key: \&str) -> String { if key == "allow-remote-config-modification" { return "Y".to_owned(); }|' "$CONFIG" || true

# Method 2 : cherche dans TOUS les fichiers .rs du projet et remplace les appels
echo "Recherche allow-remote-config-modification dans les sources..."
grep -rl "allow-remote-config-modification" . --include="*.rs" 2>/dev/null | while read -r f; do
  echo "  Patch: $f"
  perl -pi -e 's|get_local_option\("allow-remote-config-modification"\)|"Y".to_owned()|g' "$f" || true
  perl -pi -e 's|LocalConfig::get_option\("allow-remote-config-modification"\)|"Y".to_owned()|g' "$f" || true
  perl -pi -e 's|get_option\("allow-remote-config-modification"\)|"Y".to_owned()|g' "$f" || true
done

echo "Orotech config patched:"
grep -n "RENDEZVOUS_SERVERS\|RS_PUB_KEY\|APP_NAME" "$CONFIG" | head -5
