#!/usr/bin/env bash
## inject_mock_location.sh — injeta location mock via adb (requer Mock Location ativado)
## Coords default: Sao Paulo (-23.5505, -46.6333)
set -e
LAT="${LAT:--23.5505}"
LON="${LON:--46.6333}"
adb emu geo fix "$LON" "$LAT"
sleep 2
echo "[mock_location] $LAT, $LON injected"
