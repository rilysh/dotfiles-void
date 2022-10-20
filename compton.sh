#!/bin/sh
(pkill xfwm4 && compton -m 5.7 -C -f -G -O 0.06 -I 0.06 -b && xfwm4 &) &> /dev/null
