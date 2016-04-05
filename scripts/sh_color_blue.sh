#!/bin/bash
OSC_SEND_PORT=31340
IDENTIFIER=default
COLOR_R=0
COLOR_G=0
COLOR_B=255
osc-send -p ${OSC_SEND_PORT} /color ,siii ${IDENTIFIER} \
    ${COLOR_R} ${COLOR_G} ${COLOR_B}
