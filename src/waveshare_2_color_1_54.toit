// Copyright (C) 2018 Toitware ApS. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

// Driver for the two-color Waveshare 200x200 1.54 inch 2 color e-paper display.

import bitmap show *
import pixel_display show *

import .e_paper
import .two_color

FULL_UPDATE_LUT_154_ ::= [
  0x02, 0x02, 0x01, 0x11, 0x12,
  0x12, 0x22, 0x22, 0x66, 0x69,
  0x69, 0x59, 0x58, 0x99, 0x99,
  0x88, 0x00, 0x00, 0x00, 0x00,
  0xF8, 0xB4, 0x13, 0x51, 0x35,
  0x51, 0x51, 0x19, 0x01, 0x00]
PARTIAL_UPDATE_LUT_154_ ::= [
  0x10, 0x18, 0x18, 0x08, 0x18,
  0x18, 0x08, 0x00, 0x00, 0x00,
  0x00, 0x00, 0x00, 0x00, 0x00,
  0x00, 0x00, 0x00, 0x00, 0x00,
  0x13, 0x14, 0x44, 0x12, 0x00,
  0x00, 0x00, 0x00, 0x00, 0x00]

class Waveshare2Color154 extends EPaper2Color:
  // There are two frame buffers, and when we refresh, it flips which frame
  // buffer we can write into.  After we flipped, we need to update the second
  // frame buffer with the current state.
  flags ::= FLAG_2_COLOR | FLAG_PARTIAL_UPDATES

  width ::= 200
  height ::= 200

  constructor device reset busy:
    super device reset busy
    reset_.set 0
    sleep --ms=10
    reset_.set 1
    sleep --ms=10

    send_le DRIVER_OUTPUT_154_ height height >> 8
    send_ 1 0                                                         // GD = 0; SM = 0; TB = 0;
    send BOOSTER_SOFT_START_154_ 0xd7 0xd6 0x9d
    send WRITE_VCOM_154_ 0xa8                      // VCOM 7C
    send WRITE_DUMMY_LINE_PERIOD_154_ 0x1a         // 4 dummy lines per gate.
    send SET_GATE_TIME_154_ 0x08                   // 2 us per line.
    send DATA_ENTRY_MODE_154_ 3
    send_array WRITE_LUT_154_ PARTIAL_UPDATE_LUT_154_
    4.repeat: init_image_ width height
    send_array WRITE_LUT_154_ PARTIAL_UPDATE_LUT_154_

  init_image_ width height:
    send SET_RAM_X_RANGE_154_ 0 (width - 1) >> 3
    send_le SET_RAM_Y_RANGE_154_ 0 height - 1
    send SET_RAM_X_ADDRESS_154_ 0
    send_le SET_RAM_Y_ADDRESS_154_ 0
    send WRITE_RAM_154_
    send_repeated_bytes (width * height >> 3) 0
    refresh 0 0 width height

  draw_2_color left/int top/int right/int bottom/int pixels/ByteArray -> none:
    redraw_rect_ left top right bottom pixels

  clean left/int top/int right/int bottom/int -> none:
    canvas_width := right - left
    canvas_height := round_up (bottom - top) 8
    pixels := ByteArray (canvas_width * canvas_height) >> 3: 0
    redraw_rect_ left top right bottom pixels

  redraw_rect_ left/int top/int right/int bottom/int pixels/ByteArray -> none:
    canvas_width := right - left
    right--
    bottom--
    send SET_RAM_X_RANGE_154_ (left >> 3) (right >> 3)
    send_le SET_RAM_Y_RANGE_154_ top bottom
    wait_for_busy 0
    send SET_RAM_X_ADDRESS_154_ (left >> 3)
    send_le SET_RAM_Y_ADDRESS_154_ top
    wait_for_busy 0
    send WRITE_RAM_154_
    dump_ 0xff pixels canvas_width (1 + bottom - top)
    send NOP_154_
    wait_for_busy 0

  refresh x/int y/int w/int h/int -> none:
    send DISPLAY_UPDATE_2_154_ 0xc4
    send MASTER_ACTIVATION_154_
    send NOP_154_
    wait_for_busy 0
