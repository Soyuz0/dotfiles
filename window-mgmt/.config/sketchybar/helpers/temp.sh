#!/bin/bash
# Get CPU temp on Apple Silicon using temp_sensor
# Extracts PMGR SOC Die Temp Sensor0 (index 18 in the sensor list)
DIR="$(dirname "$0")"
"$DIR/temp_sensor" 2>/dev/null | tail -1 | cut -d',' -f18 | tr -d ' '
