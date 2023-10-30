// Copyright (C) 2018 Toitware ApS. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

// Driver for the two-color Waveshare 200x200 1.54 inch 2 color e-paper display.

import bitmap show *
import gpio
import serial.protocols.spi

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

/**
A driver for version 1 of the Waveshare 1.54 inch 2 color e-paper display.
This display has a resolution of 200x200 pixels.
It supports partial updates, but they are not faster than full updates.
  However they do flicker less.  After a few partial updates the unchanged
  part of the image begins to fade to gray.
Doing updates with "display.draw --speed=0" will make a complete update, which
  gets the black colors to be more saturated again.  This option is named for a
  speed-quality tradeoff that doesn't really apply for this display since the
  partial update modes are not faster.
*/
class Waveshare2Color154 extends EPaper2Color:
  // There are two frame buffers, and when we refresh, it flips which frame
  // buffer we can write into.  After we flipped, we need to update the second
  // frame buffer with the current state.
  flags ::= FLAG_2_COLOR | FLAG_PARTIAL_UPDATES

  width ::= 200
  height ::= 200

  currently_partial_update_ := false
  saved_updates := []

  /**
  This causes the driver to enter deep sleep mode, which saves power and
    also protects the display from damage caused by being switched on for
    too long.
  You must call $reset to wake it up.
  */
  deep-sleep -> none:
    send DEEP_SLEEP_MODE_154_
    wait_for_busy

  /**
  Creates a new driver for the Waveshare 1.54 inch 2 color e-paper display.
  If $partial_updates is set to false then the display is always fully
    updated, which is easier than addint "--speed=0" to every draw operation
    of the display.
  According to the documentation, the maxiumum SPI speed of the $device is
    20Mhz.
  */
  constructor device/spi.Device
      --reset/gpio.Pin?
      --busy/gpio.Pin?
      --partial_updates/bool=true
      --auto_reset/bool=true
      --auto_initialize/bool=true:
    if partial_updates:
      flags = FLAG_2_COLOR | FLAG_PARTIAL_UPDATES
    else:
      flags = FLAG_2_COLOR
    super device
        --reset=reset
        --busy=busy
        --busy_active_high
    if auto_reset: reset
    if auto_initialize: initialize

  reset --ms/int=10:
    super --ms=ms

  initialize -> none:
    // Inspired by
    // https://github.com/waveshareteam/e-Paper/blob/master/Arduino/epd1in54/epd1in54.cpp
    control_byte := 0   // GD = 0; SM = 0; TB = 0.
    send DRIVER_OUTPUT_154_ (height - 1) ((height - 1) >> 8) control_byte
    send BOOSTER_SOFT_START_154_ 0xd7 0xd6 0x9d
    send WRITE_VCOM_154_ 0xa8                      // VCOM 7C
    send WRITE_DUMMY_LINE_PERIOD_154_ 0x1a         // 4 dummy lines per gate.
    send SET_GATE_TIME_154_ 0x08                   // 2 us per line.
    send DATA_ENTRY_MODE_154_ 3                    // X increment, Y increment.
    send_array WRITE_LUT_154_ FULL_UPDATE_LUT_154_

  start_partial_update speed/int -> none:
    send_array WRITE_LUT_154_ PARTIAL_UPDATE_LUT_154_
    saved_updates = []
    currently_partial_update_ = true

  start_full_update speed/int -> none:
    send_array WRITE_LUT_154_ FULL_UPDATE_LUT_154_
    saved_updates = []
    currently_partial_update_ = false

  set_memory_area_ left/int top/int right/int bottom/int -> none:
    send    SET_RAM_X_RANGE_154_ (left >> 3) ((right - 1) >> 3)
    send_le SET_RAM_Y_RANGE_154_ top         (bottom - 1)

  set_memory_pointer x/int y/int -> none:
    send    SET_RAM_X_ADDRESS_154_ (x >> 3)
    send_le SET_RAM_Y_ADDRESS_154_ y

  draw_two_color left/int top/int right/int bottom/int pixels/ByteArray -> none:
    redraw_rect_ left top right bottom pixels

  clean left/int top/int right/int bottom/int -> none:
    canvas_width := right - left
    canvas_height := round_up (bottom - top) 8
    pixels := ByteArray (canvas_width * canvas_height) >> 3: 0
    redraw_rect_ left top right bottom pixels

  redraw_rect_ left/int top/int right/int bottom/int pixels/ByteArray -> none:
    saved_updates.add [left, top, right, bottom, pixels.copy]
    send_to_device_ left top right bottom pixels WRITE_RAM_154_

  send_to_device_ left/int top/int right/int bottom/int pixels/ByteArray -> none command/int:
    canvas_width := right - left
    set_memory_area_ left top right bottom
    set_memory_pointer left top
    send command
    dump_ 0xff pixels canvas_width (bottom - top)
    send NOP_154_
    wait_for_busy

  static ENABLE_CLOCK_SIGNAL_          ::= 0x80
  static ENABLE_ANALOG_                ::= 0x40
  static LOAD_TEMPERATURE_VALUE_       ::= 0x20
  static LOAD_LUT_WITH_DISPLAY_MODE_1_ ::= 0x10
  static LOAD_LUT_WITH_DISPLAY_MODE_2_ ::= 0x18
  static DISABLE_OSC_                  ::= 0x04
  static DISABLE_ANALOG_               ::= 0x02
  static DISABLE_CLOCK_SIGNAL_         ::= 0x01

  commit x/int y/int w/int h/int -> none:
    if currently_partial_update_:
      send DISPLAY_UPDATE_2_154_ 0xc7
    else:
      send DISPLAY_UPDATE_2_154_ 0xc4
    send MASTER_ACTIVATION_154_
    send NOP_154_
    wait_for_busy
    saved_updates.do:
      send_to_device_ it[0] it[1] it[2] it[3] it[4] WRITE_RAM_154_
    saved_updates = []
