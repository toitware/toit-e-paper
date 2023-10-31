// Copyright (C) 2023 Toitware ApS. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

// Driver for the Waveshare 2.9 inch e-paper.  This is a 296x128 two-color
// display as used in the Adafruit MagTag.

import gpio
import serial.protocols.spi

import .four_gray

WAVESHARE_E_PAPER_2_9_WIDTH_ ::= 296
WAVESHARE_E_PAPER_2_9_HEIGHT_ ::= 128

class Waveshare4Gray29 extends EPaper4Grey:
  constructor device/spi.Device
      --reset/gpio.Pin?
      --busy/gpio.Pin?:
    w := WAVESHARE_E_PAPER_2_9_WIDTH_
    h := WAVESHARE_E_PAPER_2_9_HEIGHT_
    super device w h
        --reset=reset
        --busy=busy
