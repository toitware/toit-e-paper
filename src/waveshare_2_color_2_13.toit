// Copyright (C) 2018 Toitware ApS. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

// Driver for the flexible two-color Waveshare 104x212 2.13 inch 2 color
// e-paper display, type D.  According to the info from Waveshare this panel is
// capable of partial update, but we don't have this working so this driver is
// in full update mode (around 2 seconds).

// The hat should be set to 4-pin SPI mode.
// Busy pin is 0=busy 1=notbusy

import bitmap show *
import gpio
import serial.protocols.spi

import pixel_display show *

import .e_paper
import .two_color

LUT_VCOM_DC_ ::= #[
    0x00, 0x08, 0x00, 0x00, 0x00, 0x02,
    0x60, 0x28, 0x28, 0x00, 0x00, 0x01,
    0x00, 0x14, 0x00, 0x00, 0x00, 0x01,
    0x00, 0x12, 0x12, 0x00, 0x00, 0x01,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00
]

LUT_WW_ ::= #[
    0x40, 0x08, 0x00, 0x00, 0x00, 0x02,
    0x90, 0x28, 0x28, 0x00, 0x00, 0x01,
    0x40, 0x14, 0x00, 0x00, 0x00, 0x01,
    0xA0, 0x12, 0x12, 0x00, 0x00, 0x01,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
]

LUT_BW_ ::= #[
    0x40, 0x17, 0x00, 0x00, 0x00, 0x02,
    0x90, 0x0F, 0x0F, 0x00, 0x00, 0x03,
    0x40, 0x0A, 0x01, 0x00, 0x00, 0x01,
    0xA0, 0x0E, 0x0E, 0x00, 0x00, 0x02,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
]

LUT_WB_ ::= #[
    0x80, 0x08, 0x00, 0x00, 0x00, 0x02,
    0x90, 0x28, 0x28, 0x00, 0x00, 0x01,
    0x80, 0x14, 0x00, 0x00, 0x00, 0x01,
    0x50, 0x12, 0x12, 0x00, 0x00, 0x01,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
]

LUT_BB_ ::= #[
    0x80, 0x08, 0x00, 0x00, 0x00, 0x02,
    0x90, 0x28, 0x28, 0x00, 0x00, 0x01,
    0x80, 0x14, 0x00, 0x00, 0x00, 0x01,
    0x50, 0x12, 0x12, 0x00, 0x00, 0x01,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
]

LUT_VCOM_DC_GRAYSCALE_ ::= #[
    0x00, 0x0A, 0x00, 0x00, 0x00, 0x01,
    0x60, 0x14, 0x14, 0x00, 0x00, 0x01,
    0x00, 0x14, 0x00, 0x00, 0x00, 0x01,
    0x00, 0x13, 0x0A, 0x01, 0x00, 0x01,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00,
]

LUT_WW_GRAYSCALE_ ::= #[
    0x40, 0x0A, 0x00, 0x00, 0x00, 0x01,
    0x90, 0x14, 0x14, 0x00, 0x00, 0x01,
    0x10, 0x14, 0x0A, 0x00, 0x00, 0x01,
    0xA0, 0x13, 0x01, 0x00, 0x00, 0x01,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
]

LUT_BW_GRAYSCALE_ ::= #[
    0x40, 0x0A, 0x00, 0x00, 0x00, 0x01,
    0x90, 0x14, 0x14, 0x00, 0x00, 0x01,
    0x00, 0x14, 0x0A, 0x00, 0x00, 0x01,
    0x99, 0x0C, 0x01, 0x03, 0x04, 0x01,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
]

LUT_WB_GRAYSCALE_ ::= #[
    0x40, 0x0A, 0x00, 0x00, 0x00, 0x01,
    0x90, 0x14, 0x14, 0x00, 0x00, 0x01,
    0x00, 0x14, 0x0A, 0x00, 0x00, 0x01,
    0x99, 0x0B, 0x04, 0x04, 0x01, 0x01,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
]

LUT_BB_GRAYSCALE_ ::= #[
    0x80, 0x0A, 0x00, 0x00, 0x00, 0x01,
    0x90, 0x14, 0x14, 0x00, 0x00, 0x01,
    0x20, 0x14, 0x0A, 0x00, 0x00, 0x01,
    0x50, 0x13, 0x01, 0x00, 0x00, 0x01,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
]

LUT_VCOM_DC_PARTIAL_ ::= #[
    0x00, 0x19, 0x01, 0x00, 0x00, 0x01,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00
]

LUT_WW_PARTIAL_ ::= #[
    0x00, 0x19, 0x01, 0x00, 0x00, 0x01,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00
]

LUT_BW_PARTIAL_ ::= #[
    0x80, 0x19, 0x01, 0x00, 0x00, 0x01,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00
]

LUT_WB_PARTIAL_ ::= #[
    0x40, 0x19, 0x01, 0x00, 0x00, 0x01,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00
]

LUT_BB_PARTIAL_ ::= #[
    0x00, 0x19, 0x01, 0x00, 0x00, 0x01,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00
]

class Waveshare2Color213 extends EPaper2Color:
  flags:
    if four_gray_mode_:
      return FLAG_3_COLOR
    else:
      return FLAG_2_COLOR | FLAG_PARTIAL_UPDATES

  width := 0
  height := 0
  four_gray_mode_ := false
  speed_ := 50

  constructor device/spi.Device
      .width
      .height
      --reset/gpio.Pin?
      --busy/gpio.Pin?:
    super device
        --reset=reset
        --busy=busy

  set_mode mode:
    if mode == "default":
      four_gray_mode_ = false
    else if mode == "four_gray":
      four_gray_mode_ = true
    else:
      throw "Unknown display mode $mode"

  flush:
    switch_off_

  init_two_color_:
    reset --ms=10

    send_array POWER_SETTING_ #[
      0x03,  // Internal DC/DC converter for power.
      0x00,  // VCOM voltage level 20V.
      0x2b,  // VDH power for B/W pixel +15V
      0x2b,  // VDL power for B/W pixel -15V
      0x03  // VDHR power for red pixel +3V
    ]

    send BOOSTER_SOFT_START_  // Default values.
      0x17  // A
      0x17  // B
      0x17  // C

    send POWER_ON_
    check_status_

    send PANEL_SETTING_ (RES_96_252_ | LUT_FROM_REG_ | BLACK_WHITE_ | SCAN_UP_ | SOURCE_SHIFT_RIGHT_ | BOOSTER_SWITCH_ON_ | NO_SOFT_RESET_) 0x0d

    send PLL_CONTROL_ 0x3a  // 0x3a 100Hz, 0x3c 50Hz

    send RESOLUTION_SETTING_ width height >> 8 height
    send VCOM_DC_ 0x28  // in steps of -0.05V, this is -2.1V

  check_status_:
    send GET_STATUS_
    wait_for_busy

  init_grayscale_:
    reset --ms=10

    send_array POWER_SETTING_ #[
      0x03,  // Internal DC/DC converter for power.
      0x00,  // VCOM voltage level +-16V.
      0x2b,  // VDH power for B/W pixel
      0x2b,  // VDL power for B/W pixel
      0x13  // VDHR power for red pixel
    ]

    send BOOSTER_SOFT_START_  // Default values.
      0x17  // A
      0x17  // B
      0x17  // C

    send POWER_ON_
    check_status_

    send PANEL_SETTING_ (RES_96_230_ | LUT_FROM_REG_ | BLACK_WHITE_ | SCAN_UP_ | SOURCE_SHIFT_RIGHT_ | BOOSTER_SWITCH_ON_ | NO_SOFT_RESET_) 0x0d

    send PLL_CONTROL_ 0x3c  // 0x3a 100Hz, 0x3c 50Hz

    send RESOLUTION_SETTING_ width height >> 8 height

    send VCOM_DC_ 0x12  // in steps of -0.05V

  static NO_UPDATE_IN_PROGRESS_ ::= 0
  static FULL_UPDATE_IN_PROGRESS_ ::= 1
  static PARTIAL_UPDATE_IN_PROGRESS_ ::= 2

  update_in_progress_ := NO_UPDATE_IN_PROGRESS_

  start_full_update speed/int:
    if update_in_progress_ != NO_UPDATE_IN_PROGRESS_: throw "Already updating"
    speed_ = speed
    if four_gray_mode_:
      init_grayscale_
      set_grayscale_registers_
      send DATA_START_TRANSMISSION_1_
      saved_plane_0_pixels_ = []
    else:
      init_two_color_
      set_full_registers_
      send DATA_START_TRANSMISSION_2_
    update_in_progress_ = FULL_UPDATE_IN_PROGRESS_

  start_partial_update speed/int:
    start_partial_update_implementation_ speed

  start_partial_update_implementation_ speed/int --force/bool=false:
    if update_in_progress_ != NO_UPDATE_IN_PROGRESS_:
      if not force: throw "Already updating"
      // Abandon update in progress and keep on trucking.
      refresh_implementation_ 0 0 0 0
    speed_ = speed
    if four_gray_mode_: throw "No partial update supported"
    init_two_color_
    set_partial_registers_
    update_in_progress_ = PARTIAL_UPDATE_IN_PROGRESS_

  draw_2_color left/int top/int right/int bottom/int pixels/ByteArray -> none:
    draw_2_color_implementation_ left top right bottom pixels

  draw_2_color_implementation_ left/int top/int right/int bottom/int pixels/ByteArray -> none:
    if four_gray_mode_: throw "Two color data sent in gray mode"
    if update_in_progress_ == NO_UPDATE_IN_PROGRESS_: throw "Data sent while not updating"
    w := right - left
    h := bottom - top
    if update_in_progress_ == FULL_UPDATE_IN_PROGRESS_:
      dump_ 0xff pixels w h
    else:
      send PARTIAL_IN_
      send_array PARTIAL_WINDOW_ [ left, right - 1, top >> 8, top, (bottom - 1) >> 8, bottom - 1, 0x28 ]
      send DATA_START_TRANSMISSION_1_
      dump_ 0xff pixels w h
      send DATA_START_TRANSMISSION_2_
      dump_ 0 pixels w h
      refresh_all
      send PARTIAL_OUT_

  saved_plane_0_pixels_ := null

  draw_two_bit left/int top/int right/int bottom/int plane_0_pixels/ByteArray plane_1_pixels/ByteArray -> none:
    if not four_gray_mode_: throw "Gray data sent in two-color mode"
    if update_in_progress_ != FULL_UPDATE_IN_PROGRESS_: throw "Data sent while not updating"
    w := right - left
    h := bottom - top
    saved_plane_0_pixels_.add [plane_0_pixels, w, h]
    dump_ 0xff plane_1_pixels w h

  vcom_and_data_interval_ interval:
    assert: 2 <= interval <= 17
    return 17 - interval

  // Full update mode is also black-white-red mode.
  static FULL_MODE_1_IS_RED_ ::= 0x00
  static FULL_MODE_0_IS_RED_ ::= 0x20
  static FULL_MODE_1_IS_BLACK_ ::= 0x00
  static FULL_MODE_1_IS_WHITE_ ::= 0x10
  static FULL_MODE_FLOATING_BORDER_WHEN_1_IS_BLACK_ ::= 0x00
  static FULL_MODE_RED_BORDER_WHEN_1_IS_BLACK_      ::= 0x40
  static FULL_MODE_WHITE_BORDER_WHEN_1_IS_BLACK_    ::= 0x80
  static FULL_MODE_BLACK_BORDER_WHEN_1_IS_BLACK_    ::= 0xC0
  static FULL_MODE_FLOATING_BORDER_WHEN_1_IS_WHITE_ ::= 0xC0
  static FULL_MODE_RED_BORDER_WHEN_1_IS_WHITE_      ::= 0x80
  static FULL_MODE_WHITE_BORDER_WHEN_1_IS_WHITE_    ::= 0x40
  static FULL_MODE_BLACK_BORDER_WHEN_1_IS_WHITE_    ::= 0x00

  static RES_96_230_ ::= 0x00
  static RES_96_252_ ::= 0x80
  static RES_128_296_ ::= 0x40
  static RES_160_296_ ::= 0xc0
  static LUT_FROM_OTP_ ::= 0x00
  static LUT_FROM_REG_ ::= 0x20
  static BLACK_WHITE_RED_ ::= 0x00
  static BLACK_WHITE_ ::= 0x10
  static SCAN_DOWN_ ::= 0
  static SCAN_UP_ ::= 8
  static SOURCE_SHIFT_LEFT_ ::= 0
  static SOURCE_SHIFT_RIGHT_ ::= 4
  static BOOSTER_SWITCH_OFF_ ::= 0
  static BOOSTER_SWITCH_ON_ ::= 2
  static SOFT_RESET_ ::= 0
  static NO_SOFT_RESET_ ::= 1

  switch_off_:
    if update_in_progress_ == NO_UPDATE_IN_PROGRESS_: return
    update_in_progress_ = NO_UPDATE_IN_PROGRESS_

    set_border_floating_
    sleep --ms=1
    check_status_

    send VCOM_AND_DATA_SETTING_INTERVAL_ 0xf7   // 0x50 0xf7
    send POWER_OFF_                             // 0x02
    sleep --ms=1
    check_status_

    wait_for_busy                               // Wait for the busy line to be not busy
    send DEEP_SLEEP_ DEEP_SLEEP_CHECK_          // 0x07 0xa5

  set_full_registers_:
    send VCOM_AND_DATA_SETTING_INTERVAL_
      FULL_MODE_1_IS_WHITE_ +
        FULL_MODE_0_IS_RED_ +
          FULL_MODE_WHITE_BORDER_WHEN_1_IS_BLACK_ +
            (vcom_and_data_interval_ 10)
    send_array VCOM_LUT_ LUT_VCOM_DC_
    send_array W2W_LUT_ LUT_WW_
    send_array B2W_LUT_ LUT_BW_
    send_array W2B_LUT_ LUT_WB_
    send_array B2B_LUT_ LUT_BB_

  set_grayscale_registers_:
    send VCOM_AND_DATA_SETTING_INTERVAL_
      FULL_MODE_1_IS_WHITE_ +
        FULL_MODE_RED_BORDER_WHEN_1_IS_WHITE_ +
          (vcom_and_data_interval_ 10)
    send_array VCOM_LUT_ LUT_VCOM_DC_GRAYSCALE_
    send_array W2W_LUT_ LUT_WW_GRAYSCALE_
    send_array B2W_LUT_ LUT_BW_GRAYSCALE_
    send_array W2B_LUT_ LUT_WB_GRAYSCALE_
    send_array B2B_LUT_ LUT_BB_GRAYSCALE_
    send_array VCOM_LUT_2_ LUT_WW_GRAYSCALE_

  // Partial mode is also black-and-white mode.
  static PARTIAL_MODE_1_IS_WHITE_ ::= 0x00
  static PARTIAL_MODE_1_IS_BLACK_ ::= 0x10
  static PARTIAL_MODE_BORDER_IS_FLOATING_ ::= 0x00  // Also 0xC0.
  static PARTIAL_MODE_BORDER_IS_0_ ::= 0x40
  static PARTIAL_MODE_BORDER_IS_1_ ::= 0x80

  set_partial_registers_:
    send VCOM_DC_ 3
    send VCOM_AND_DATA_SETTING_INTERVAL_ PARTIAL_MODE_BORDER_IS_0_ + PARTIAL_MODE_1_IS_WHITE_ + (vcom_and_data_interval_ 10)
    send_array VCOM_LUT_ LUT_VCOM_DC_PARTIAL_
    send_array W2W_LUT_ LUT_WW_PARTIAL_
    send_array B2W_LUT_ LUT_BW_PARTIAL_
    send_array W2B_LUT_ LUT_WB_PARTIAL_
    send_array B2B_LUT_ LUT_BB_PARTIAL_

  refresh_all:
    send DISPLAY_REFRESH_
    sleep --ms=1
    check_status_

  // Called at the end of a series of draw commands.  For partial mode we don't
  // need to do anything, but for full mode there is some final cleanup to do.
  refresh left top right bottom:
    refresh_implementation_ left top right bottom

  refresh_implementation_ left top right bottom:
    if update_in_progress_ == FULL_UPDATE_IN_PROGRESS_:
      if four_gray_mode_:
        send DATA_START_TRANSMISSION_2_
        saved_plane_0_pixels_.do:
          pixels := it[0]
          w := it[1]
          h := it[2]
          dump_ 0xff pixels w h
        saved_plane_0_pixels_ = null
      else:
        screen_bytes := ((right - left) * (bottom - top)) >> 3
        send DATA_START_TRANSMISSION_1_
        send_repeated_bytes screen_bytes 0
      refresh_all
    switch_off_

  set_border_floating_:
    send VCOM_AND_DATA_SETTING_INTERVAL_
      FULL_MODE_1_IS_WHITE_ +
        FULL_MODE_0_IS_RED_ +
          FULL_MODE_FLOATING_BORDER_WHEN_1_IS_WHITE_ +
            (vcom_and_data_interval_ 10)
