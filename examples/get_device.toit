// Copyright (C) 2023 Toitware ApS. All rights reserved.
// Use of this source code is governed by a Zero-Clause BSD license that can
// be found in the EXAMPLES_LICENSE file.

import e_paper.waveshare_2_color_1_54 show *
import gpio
import pixel_display show AbstractDriver
import spi

get_device -> AbstractDriver:
  BUSY ::= 16
  RESET ::= 9
  DC ::= 2
  CS ::= 14
  CLOCK ::= 12
  DIN ::= 13
  bus := spi.Bus
    --mosi=gpio.Pin DIN
    --clock=gpio.Pin CLOCK

  device := bus.device
    --cs=gpio.Pin CS
    --dc=gpio.Pin DC
    --frequency=10_000_000

  reset := gpio.Pin.out RESET
  busy := gpio.Pin.in BUSY --pull_down

  driver ::= Waveshare2Color154 device --reset=reset --busy=busy

  return driver
