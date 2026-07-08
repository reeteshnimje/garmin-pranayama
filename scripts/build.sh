#!/bin/zsh

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SDK_BIN="${CIQ_SDK_BIN:-$HOME/Library/Application Support/Garmin/ConnectIQ/Sdks/connectiq-sdk-mac-9.2.0-2026-06-09-92a1605b2/bin}"
JAVA_BIN="${JAVA_BIN:-/opt/homebrew/opt/openjdk@17/bin/java}"
KEY_PATH="${1:-$ROOT_DIR/developer_key}"
OUTPUT_PATH="${2:-$ROOT_DIR/bin/pranayama.prg}"

if [[ ! -x "$JAVA_BIN" ]]; then
  echo "Java not found at: $JAVA_BIN" >&2
  exit 1
fi

if [[ ! -f "$SDK_BIN/monkeybrains.jar" ]]; then
  echo "Garmin SDK not found at: $SDK_BIN" >&2
  exit 1
fi

if [[ ! -f "$KEY_PATH" ]]; then
  echo "Developer key not found at: $KEY_PATH" >&2
  exit 1
fi

/bin/mkdir -p "$(dirname "$OUTPUT_PATH")"

"$JAVA_BIN" \
  -Xms1g \
  -Dfile.encoding=UTF-8 \
  -Dapple.awt.UIElement=true \
  -classpath "$SDK_BIN/monkeybrains.jar" \
  com.garmin.monkeybrains.Monkeybrains \
  -f "$ROOT_DIR/monkey.jungle" \
  -o "$OUTPUT_PATH" \
  -y "$KEY_PATH"
