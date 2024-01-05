// Copyright (C) 2023 Toitware ApS. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

// Driver for the Waveshare 2.9 inch e-paper.  This is a 296x128 two-color
// display as used in the Adafruit MagTag.

import gpio
import spi

import .four-gray

WAVESHARE-E-PAPER-2-9-WIDTH_ ::= 296
WAVESHARE-E-PAPER-2-9-HEIGHT_ ::= 128

class Waveshare4Gray29 extends EPaper4Grey:
  constructor device/spi.Device
      --reset/gpio.Pin?
      --busy/gpio.Pin?:
    w := WAVESHARE-E-PAPER-2-9-WIDTH_
    h := WAVESHARE-E-PAPER-2-9-HEIGHT_
    super device w h
        --reset=reset
        --busy=busy
        --busy-active-high
