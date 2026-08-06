#!/bin/sh

export DISPLAY=:0
export XAUTHORITY=/home/jose/.Xauthority
export HOME=/home/jose

hay_teclado_externo()
{
    awk "
        BEGIN { RS=\"\"; IGNORECASE=1 }

        /Handlers=.*kbd/ &&
        /Name=/ &&
        !/Name=\"axp20x-pek\"/ &&
        !/Name=\"1c22800.lradc\"/ &&
        !/Name=\"Onboard\"/ &&
        !/Name=\"Silead Touchpad Virtual\"/ {
            encontrado=1
        }

        END {
            exit encontrado ? 0 : 1
        }
    " /proc/bus/input/devices
}

while true; do
    if hay_teclado_externo; then
        pkill -x onboard 2>/dev/null || true
    else
        if ! pgrep -x onboard >/dev/null; then
            onboard >/tmp/onboard.log 2>&1 &
        fi
    fi

    sleep 3
done
