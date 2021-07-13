// Copyright (C) 2018 Toitware ApS. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

// Driver for three-color e-paper displays.

import pixel_display show *

import .e_paper

class EPaper3Color extends EPaper:
  width := 0
  height := 0
  // In software terms these displays support partial update, ie you don't have
  // to send all the data every time.  But once they has the data it is no faster
  // doing a partial vs a full update.
  flags ::= FLAG_3_COLOR | FLAG_PARTIAL_UPDATES

  constructor device reset busy .width .height:
    super device reset busy
    reset_.set 0
    sleep --ms=1
    reset_.set 1
    sleep --ms=1
    wait_for_busy 1
    send_array BOOSTER_SOFT_START_ [0x07, 0x07, 0x04]
    send 0xf8 0x60 0xa5
    send 0xf8 0x89 0xa5
    send 0xf8 0x90 0x00
    send 0xf8 0x93 0x2a
    send PARTIAL_DISPLAY_REFRESH_ 0
    wait_for_busy 1
    send_array POWER_SETTING_ [0x03, 0x00, 0x2b, 0x2b, 0x09]
    send POWER_ON_
    wait_for_busy 1
    send PANEL_SETTING_ 0x8f + _3_COLOR
    wait_for_busy 1
    send_be RESOLUTION_SETTING_ width height

  draw_two_bit left/int top/int right/int bottom/int black/ByteArray red/ByteArray -> none:
    w ::= right - left
    send_be PARTIAL_DATA_START_TRANSMISSION_1_ left top (right - left) (bottom - top)
    dump_ 0 black w (bottom - top)
    send DATA_STOP_
    send_be PARTIAL_DATA_START_TRANSMISSION_2_ left top (right - left) (bottom - top)
    dump_ 0 red w (bottom - top)
    send DATA_STOP_

  refresh refresh_left refresh_top refresh_right refresh_bottom:
    // Refresh.
    sleep --ms=1
    wait_for_busy 1
    // No support for partial refresh on three-color devices.
    send DISPLAY_REFRESH_
    wait_for_busy 1
