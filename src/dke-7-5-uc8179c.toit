// Copyright (C) 2024 Toitware ApS. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

import gpio
import spi

import .three-color.toit

/**
Driver for the DKE 7.5 Inch Black/White/Red HD e Paper Display.
See https://www.dke.top/products/high-contrast-eink-75-inch-800x480-resolution-epaper-display-color-screens
Item number is 00116.
Chip is UC8179C.
As sold by Fasani, DEPG0750RWU at
  https://www.tindie.com/products/fasani/epaper-dke-model-depg0750rwu-800x480-blackred/
This is an 800x480 display with 3 colors, and no gray-scale support.
It only supports full screen update, no partial updates.
*/
class Dke75Uc8179c extends EPaper3Color:
  flags ::= FLAG-3-COLOR

  constructor device/spi.Device
      --reset/gpio.Pin?
      --reset-active-high/bool=false
      --busy/gpio.Pin?
      --busy-active-high/bool=false:
    super device 800 480
        --reset=reset
        --reset-active-high=reset-active-high
        --busy=busy
        --busy-active-high=busy-active-high

  initialize -> none:
    reset --ms=1000
    send POWER-SETTING_
        0x7
        0x7   // VGH=20V, VGL=-20V.
        0x3f  // VDH=15V.
        0x3f  // VDL=15V



    

