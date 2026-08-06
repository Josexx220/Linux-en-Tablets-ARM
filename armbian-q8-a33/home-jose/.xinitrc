#!/bin/sh

xset s off
xset -dpms
setxkbmap latam

# Orientación y calibración del táctil Silead
TOUCH_ID=$(xinput list --id-only "silead_ts" 2>/dev/null || true)
if [ -n "$TOUCH_ID" ]; then
    xinput set-prop "$TOUCH_ID"     "Coordinate Transformation Matrix"     0 -0.983 1.110     1.195 0 -0.328     0 0 1
fi

exec dbus-launch --exit-with-session icewm-session
