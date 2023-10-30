// Copyright (C) 2023 Toitware ApS. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

// Driver for the Gooddisplay 2.7 inch e-paper.  This is a 264x176 three-color
// display.

import gpio
import serial.protocols.spi

import .three_color

GOODDISPLAY_E_PAPER_2_7_WIDTH_ ::= 176
GOODDISPLAY_E_PAPER_2_7_HEIGHT_ ::= 264

class Gooddisplay3Color27 extends EPaper3Color:
  constructor device/spi.Device
      --reset/gpio.Pin?
      --busy/gpio.Pin?:
    w := GOODDISPLAY_E_PAPER_2_7_WIDTH_
    h := GOODDISPLAY_E_PAPER_2_7_HEIGHT_
    super device w h
        --reset=reset
        --busy=busy