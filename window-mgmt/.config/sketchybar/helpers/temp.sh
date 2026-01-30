#!/bin/bash
# Get CPU temp from TG Pro menu bar
osascript -e '
tell application "System Events"
    tell process "TG Pro"
        return help of menu bar item 1 of menu bar 2
    end tell
end tell' 2>/dev/null | grep -i "CPU" | head -1 | grep -oE '[0-9]+°C' | grep -oE '[0-9]+'
