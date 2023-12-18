// Copyright (C) 2018 Toitware ApS. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

// Driver for three-color e-paper displays.

import gpio
import spi

import pixel-display show *

import .e-paper

class EPaper3Color extends EPaper:
  width := 0
  height := 0
  // In software terms these displays support partial update, ie you don't have
  // to send all the data every time.  But once they have the data they are not
  // faster doing a partial vs a full update.
  flags ::= FLAG-3-COLOR | FLAG-PARTIAL-UPDATES

  constructor device/spi.Device .width .height
      --reset/gpio.Pin?
      --reset-active-high/bool=false
      --busy/gpio.Pin?
      --busy-active-high/bool=false:
    super device
        --reset=reset
        --reset-active-high=reset-active-high
        --busy=busy
        --busy-active-high=busy-active-high

  initialize -> none:
    wait-for-busy
    send-array BOOSTER-SOFT-START_ [0x07, 0x07, 0x04]
    send 0xf8 0x60 0xa5
    send 0xf8 0x89 0xa5
    send 0xf8 0x90 0x00
    send 0xf8 0x93 0x2a
    send PARTIAL-DISPLAY-REFRESH_ 0
    wait-for-busy
    send-array POWER-SETTING_ [0x03, 0x00, 0x2b, 0x2b, 0x09]
    send POWER-ON_
    wait-for-busy
    send PANEL-SETTING_ 0x8f + THREE-COLOR_
    wait-for-busy
    send-be RESOLUTION-SETTING_ width height

  draw-two-bit left/int top/int right/int bottom/int black/ByteArray red/ByteArray -> none:
    w ::= right - left
    send-be PARTIAL-DATA-START-TRANSMISSION-1_ left top (right - left) (bottom - top)
    dump_ 0 black w (bottom - top)
    send DATA-STOP_
    send-be PARTIAL-DATA-START-TRANSMISSION-2_ left top (right - left) (bottom - top)
    dump_ 0 red w (bottom - top)
    send DATA-STOP_

  refresh refresh-left refresh-top refresh-right refresh-bottom:
    // Refresh.
    sleep --ms=1
    wait-for-busy
    // No support for partial refresh on three-color devices.
    send DISPLAY-REFRESH_
    wait-for-busy
