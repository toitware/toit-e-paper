// Copyright (C) 2018 Toitware ApS. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

// Driver for the two-color Waveshare 200x200 1.54 inch 2 color e-paper display.

import bitmap show *
import gpio
import spi

import pixel-display show *

import .e-paper

FULL-UPDATE-LUT-154_ ::= [
  0x02, 0x02, 0x01, 0x11, 0x12,
  0x12, 0x22, 0x22, 0x66, 0x69,
  0x69, 0x59, 0x58, 0x99, 0x99,
  0x88, 0x00, 0x00, 0x00, 0x00,
  0xF8, 0xB4, 0x13, 0x51, 0x35,
  0x51, 0x51, 0x19, 0x01, 0x00]

PARTIAL-UPDATE-LUT-154_ ::= [
  0x10, 0x18, 0x18, 0x08, 0x18,
  0x18, 0x08, 0x00, 0x00, 0x00,
  0x00, 0x00, 0x00, 0x00, 0x00,
  0x00, 0x00, 0x00, 0x00, 0x00,
  0x13, 0x14, 0x44, 0x12, 0x00,
  0x00, 0x00, 0x00, 0x00, 0x00]

/**
A driver for version 1 of the Waveshare 1.54 inch 2 color e-paper display.
This display has a resolution of 200x200 pixels.
It supports partial updates, which are both faster than full updates and
  also flicker less.  After a few partial updates the image can get a bit
  cloudy, and then a full update is needed to restore the image quality.
Doing updates with "display.draw --speed=0" will make a complete update, which
  gets the black colors to be more saturated again.  It is also said to be
  good for the health of the display to do a full update every now and then.
*/
class Waveshare2Color154 extends EPaper:
  flags ::= FLAG-2-COLOR | FLAG-PARTIAL-UPDATES

  width ::= 200
  height ::= 200

  currently-partial-update_ := false
  saved-updates := []

  /**
  This causes the driver to enter deep sleep mode, which saves power and
    also protects the display from damage caused by being switched on for
    too long.
  You must call $reset to wake it up.
  */
  deep-sleep -> none:
    send DEEP-SLEEP-MODE-154_ 1

  /**
  Creates a new driver for the Waveshare 1.54 inch 2 color e-paper display.
  If $partial-updates is set to false then the display is always fully
    updated, which is easier than addint "--speed=0" to every draw operation
    of the display.
  According to the documentation, the maxiumum SPI speed of the $device is
    20Mhz.
  */
  constructor device/spi.Device
      --reset/gpio.Pin?
      --busy/gpio.Pin?
      --partial-updates/bool=true
      --auto-reset/bool=true
      --auto-initialize/bool=true:
    if partial-updates:
      flags = FLAG-2-COLOR | FLAG-PARTIAL-UPDATES
    else:
      flags = FLAG-2-COLOR
    super device
        --reset=reset
        --busy=busy
        --busy-active-high
    if auto-reset: reset
    if auto-initialize: initialize

  reset --ms/int=10:
    super --ms=ms

  initialize -> none:
    // Inspired by
    // https://github.com/waveshareteam/e-Paper/blob/master/Arduino/epd1in54/epd1in54.cpp
    control-byte := 0   // GD = 0; SM = 0; TB = 0.
    send DRIVER-OUTPUT-154_ (height - 1) ((height - 1) >> 8) control-byte
    send BOOSTER-SOFT-START-154_ 0xd7 0xd6 0x9d
    send WRITE-VCOM-154_ 0xa8                      // VCOM 7C
    send WRITE-DUMMY-LINE-PERIOD-154_ 0x1a         // 4 dummy lines per gate.
    send SET-GATE-TIME-154_ 0x08                   // 2 us per line.
    send DATA-ENTRY-MODE-154_ 3                    // X increment, Y increment.
    send-array WRITE-LUT-154_ FULL-UPDATE-LUT-154_

  start-partial-update speed/int -> none:
    send-array WRITE-LUT-154_ PARTIAL-UPDATE-LUT-154_
    saved-updates = []
    currently-partial-update_ = true

  start-full-update speed/int -> none:
    send-array WRITE-LUT-154_ FULL-UPDATE-LUT-154_
    saved-updates = []
    currently-partial-update_ = false

  set-memory-area_ left/int top/int right/int bottom/int -> none:
    send    SET-RAM-X-RANGE-154_ (left >> 3) ((right - 1) >> 3)
    send-le SET-RAM-Y-RANGE-154_ top         (bottom - 1)

  set-memory-pointer x/int y/int -> none:
    send    SET-RAM-X-ADDRESS-154_ (x >> 3)
    send-le SET-RAM-Y-ADDRESS-154_ y

  draw-two-color left/int top/int right/int bottom/int pixels/ByteArray -> none:
    redraw-rect_ left top right bottom pixels

  clean left/int top/int right/int bottom/int -> none:
    canvas-width := right - left
    canvas-height := round-up (bottom - top) 8
    pixels := ByteArray (canvas-width * canvas-height) >> 3: 0
    redraw-rect_ left top right bottom pixels

  redraw-rect_ left/int top/int right/int bottom/int pixels/ByteArray -> none:
    saved-updates.add [left, top, right, bottom, pixels.copy]
    send-to-device_ left top right bottom pixels WRITE-RAM-154_

  send-to-device_ left/int top/int right/int bottom/int pixels/ByteArray -> none command/int:
    canvas-width := right - left
    set-memory-area_ left top right bottom
    set-memory-pointer left top
    send command
    dump_ 0xff pixels canvas-width (bottom - top)
    send NOP-154_
    wait-for-busy

  static ENABLE-CLOCK-SIGNAL_          ::= 0x80
  static ENABLE-ANALOG_                ::= 0x40
  static LOAD-TEMPERATURE-VALUE_       ::= 0x20
  static LOAD-LUT-WITH-DISPLAY-MODE-1_ ::= 0x10
  static LOAD-LUT-WITH-DISPLAY-MODE-2_ ::= 0x18
  static DISABLE-OSC_                  ::= 0x04
  static DISABLE-ANALOG_               ::= 0x02
  static DISABLE-CLOCK-SIGNAL_         ::= 0x01

  commit x/int y/int w/int h/int -> none:
    if currently-partial-update_:
      send DISPLAY-UPDATE-2-154_ 0xc7
    else:
      send DISPLAY-UPDATE-2-154_ 0xc4
    send MASTER-ACTIVATION-154_
    send NOP-154_
    wait-for-busy
    saved-updates.do:
      send-to-device_ it[0] it[1] it[2] it[3] it[4] WRITE-RAM-154_
    saved-updates = []
