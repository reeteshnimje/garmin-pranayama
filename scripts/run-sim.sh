#!/bin/zsh

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SDK_BIN="${CIQ_SDK_BIN:-$HOME/Library/Application Support/Garmin/ConnectIQ/Sdks/connectiq-sdk-mac-9.2.0-2026-06-09-92a1605b2/bin}"
JAVA_BIN="${JAVA_BIN:-/opt/homebrew/opt/openjdk@17/bin/java}"
PRG_PATH="${1:-$ROOT_DIR/bin/pranayama.prg}"
DEVICE_ID="${2:-fr265}"

if [[ ! -x "$JAVA_BIN" ]]; then
  echo "Java not found at: $JAVA_BIN" >&2
  exit 1
fi

if [[ ! -f "$SDK_BIN/monkeybrains.jar" ]]; then
  echo "Garmin SDK not found at: $SDK_BIN" >&2
  exit 1
fi

if [[ ! -f "$PRG_PATH" ]]; then
  echo "PRG file not found at: $PRG_PATH" >&2
  exit 1
fi

"$JAVA_BIN" \
  -classpath "$SDK_BIN/monkeybrains.jar" \
  com.garmin.monkeybrains.monkeydodeux.MonkeyDoDeux \
  -f "$PRG_PATH" \
  -d "$DEVICE_ID" \
  -s "$SDK_BIN/shell"
