#!/usr/bin/python3

import time
from evdev import InputDevice, UInput, ecodes, list_devices

NOMBRE = "silead_ts"
SENSIBILIDAD = 1.35
UMBRAL_MOVIMIENTO = 15
TIEMPO_CLIC_IZQUIERDO = 0.40
TIEMPO_CLIC_DERECHO = 0.70

def buscar_tactil():
    while True:
        for ruta in list_devices():
            dispositivo = InputDevice(ruta)
            if dispositivo.name == NOMBRE:
                return dispositivo
            dispositivo.close()
        time.sleep(1)

tactil = buscar_tactil()

mouse = UInput(
    {
        ecodes.EV_KEY: [
            ecodes.BTN_LEFT,
            ecodes.BTN_RIGHT,
        ],
        ecodes.EV_REL: [
            ecodes.REL_X,
            ecodes.REL_Y,
        ],
    },
    name="Silead Touchpad Virtual",
    bustype=ecodes.BUS_USB,
)

tactil.grab()

x = y = None
ultimo_x = ultimo_y = None
slot = 0
tocando = False
inicio = 0.0
movimiento = 0
inicio_pendiente = False
fin_pendiente = False

def hacer_clic(boton):
    mouse.write(ecodes.EV_KEY, boton, 1)
    mouse.syn()
    time.sleep(0.04)
    mouse.write(ecodes.EV_KEY, boton, 0)
    mouse.syn()

try:
    for evento in tactil.read_loop():

        if evento.type == ecodes.EV_ABS:

            if evento.code == ecodes.ABS_MT_SLOT:
                slot = evento.value

            elif evento.code == ecodes.ABS_X:
                x = evento.value

            elif evento.code == ecodes.ABS_Y:
                y = evento.value

            elif evento.code == ecodes.ABS_MT_POSITION_X \
                    and slot == 0:
                x = evento.value

            elif evento.code == ecodes.ABS_MT_POSITION_Y \
                    and slot == 0:
                y = evento.value

        elif evento.type == ecodes.EV_KEY \
                and evento.code == ecodes.BTN_TOUCH:

            if evento.value == 1:
                tocando = True
                inicio = time.monotonic()
                movimiento = 0
                inicio_pendiente = True
                fin_pendiente = False

            elif evento.value == 0:
                tocando = False
                fin_pendiente = True

        elif evento.type == ecodes.EV_SYN \
                and evento.code == ecodes.SYN_REPORT:

            if inicio_pendiente:
                ultimo_x = x
                ultimo_y = y
                inicio_pendiente = False

            elif tocando and None not in (
                    x, y, ultimo_x, ultimo_y):

                dx = x - ultimo_x
                dy = y - ultimo_y

                movimiento += abs(dx) + abs(dy)

                mover_x = round(-dy * SENSIBILIDAD)
                mover_y = round(dx * SENSIBILIDAD)

                if mover_x or mover_y:
                    mouse.write(
                        ecodes.EV_REL,
                        ecodes.REL_X,
                        mover_x,
                    )
                    mouse.write(
                        ecodes.EV_REL,
                        ecodes.REL_Y,
                        mover_y,
                    )
                    mouse.syn()

                ultimo_x = x
                ultimo_y = y

            if fin_pendiente:
                duracion = time.monotonic() - inicio

                if movimiento < UMBRAL_MOVIMIENTO:
                    if duracion <= TIEMPO_CLIC_IZQUIERDO:
                        hacer_clic(ecodes.BTN_LEFT)
                    elif duracion >= TIEMPO_CLIC_DERECHO:
                        hacer_clic(ecodes.BTN_RIGHT)

                ultimo_x = ultimo_y = None
                fin_pendiente = False

finally:
    try:
        tactil.ungrab()
    except Exception:
        pass

    mouse.close()
    tactil.close()
