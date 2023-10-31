// Copyright (C) 2023 Toitware ApS. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

// Driver for the Gooddisplay 2.7 inch e-paper.  This is a 264x176 three-color
// display.

import gpio
import serial.protocols.spi

import pixel_display show *

import .e_paper

GOODDISPLAY_E_PAPER_2_7_WIDTH_ ::= 264
GOODDISPLAY_E_PAPER_2_7_HEIGHT_ ::= 176

class Gooddisplay4Gray27 extends EPaper:
  width := ?
  height := ?
  flags ::= FLAG_4_COLOR

  constructor device/spi.Device
      .width=176
      .height=264
      --reset/gpio.Pin?=null
      --reset_active_high/bool=false
      --busy/gpio.Pin?=null
      --busy_active_high/bool=false
      --auto_reset/bool=true
      --auto_initialize/bool=true:
    super device
        --reset=reset
        --reset_active_high=reset_active_high
        --busy=busy
        --busy_active_high=busy_active_high
    if auto_reset: reset
    if auto_initialize: initialize

  initialize -> none:
    phase_a := SOFT_START_10_MS_ | SOFT_START_DRIVING_STRENGTH_1_ | SOFT_START_MINIMUM_OFF_GDR_6580_NS_  // 0x07
    phase_b := SOFT_START_10_MS_ | SOFT_START_DRIVING_STRENGTH_1_ | SOFT_START_MINIMUM_OFF_GDR_6580_NS_  // 0x07
    phase_c := SOFT_START_10_MS_ | SOFT_START_DRIVING_STRENGTH_1_ | SOFT_START_MINIMUM_OFF_GDR_800_NS_   // 0x04
    // https://github.com/soonuse/gdew027w3_2.7inch_e-paper/blob/master/arduino/libraries/epd2in7.cpp
    // uses 0x17 for phase_c.
    send_array BOOSTER_SOFT_START_ #[phase_a, phase_b, phase_c]  // 0x06 0x07 0x07 0x04.
    send POWER_OPTIMIZATION_ 0x60 0xa5                 // 0xf8 0x60 0xa5.
    send POWER_OPTIMIZATION_ 0x89 0xa5                 // 0xf8 0x89 0xa5.
    send POWER_OPTIMIZATION_ 0x90 0x00                 // 0xf8 0x90 0x00.
    send POWER_OPTIMIZATION_ 0x93 0x2a                 // 0xf8 0x93 0x2a.
    // https://github.com/soonuse/gdew027w3_2.7inch_e-paper/ adds:
                                                       // 0xf8 0xa0 0xa5
                                                       // 0xf8 0xa1 0x00
                                                       // 0xf8 0x73 0x41.
    send PARTIAL_DISPLAY_REFRESH_ 0  // Reset DFV_EN      0x16 0x00.
    internal := INTERNAL_POWER_VGH_VGL_ | INTERNAL_POWER_VDH_VDL_    // 3
    vcom_power := VCOM_VOLTAGE_ADDITIVE_ | VCOM_VGHL_LV_MINUS_16_V_  // 0x00
    bw_power := VCOM_VDHL_11_V_
    red_power := VCOM_VDHR_4_2_V_
    send_array POWER_SETTING_ #[                       // 0x01.
        internal,                                      // 0x03.
        vcom_power,                                    // 0x00.
        bw_power,                                      // 0x2b.
        bw_power,                                      // 0x2b.
        red_power,                                     // 0x09.
    ]
    send POWER_ON_                                     // 0x04.
    wait_for_busy
    panel_setting := RESOLUTION_296_160_ | LUT_FROM_FLASH_ | PANEL_BWR_ | 0xf
    // https://github.com/soonuse/gdew027w3_2.7inch_e-paper/ uses 0xaf instead,
    // because they are using BW mode, not BWR mode.
    send PANEL_SETTING_ panel_setting                  // 0x00 0xbf.
    // See chart page 34 of 100001_1909185148/GDEW027W3-2.pdf.
    send PLL_CONTROL_ 0x3a                             // 0x30 0x3a.
    send_be RESOLUTION_SETTING_ width height           // 0x61 264 176
    // The following line is not in https://github.com/soonuse/gdew027w3_2.7inch_e-paper/,
    send VCOM_DC_ VCOM_DC_MINUS_1_V_                   // 0x82 0x12.
    send VCOM_AND_DATA_SETTING_INTERVAL_ 0x87          // 0x50 0x87 page 36, GDEW027W3-2.pdf.
    // A 2ms pause here in the soonuse driver.
    //set_luts_

  set_luts_ -> none:
    send_array VCOM_LUT_ LUT_VCOM_DC_
    send_array W2W_LUT_ LUT_WW_
    send_array B2W_LUT_ LUT_BW_
    send_array W2B_LUT_ LUT_WB_
    send_array B2W_LUT_ LUT_BB_

  draw_two_bit left/int top/int right/int bottom/int black/ByteArray red/ByteArray -> none:
    w ::= right - left
    send_be PARTIAL_DATA_START_TRANSMISSION_1_ left top (right - left) (bottom - top)
    dump_ 0 black w (bottom - top)
    send DATA_STOP_
    send_be PARTIAL_DATA_START_TRANSMISSION_2_ left top (right - left) (bottom - top)
    dump_ 0 red w (bottom - top)
    send DATA_STOP_

  commit x/int y/int w/int h/int -> none:
    // Refresh.
    sleep --ms=1
    wait_for_busy
    send_be DISPLAY_REFRESH_ x y w h
    wait_for_busy

LUT_VCOM_DC_ ::= #[
    0x00, 0x00, 0x00, 0x0f, 0x0f, 0x00,
    0x00, 0x05, 0x00, 0x32, 0x32, 0x00,
    0x00, 0x02, 0x00, 0x0f, 0x0f, 0x00,
    0x00, 0x05, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00,
]

//R21H
LUT_WW_ ::= #[
    0x50, 0x0f, 0x0f, 0x00, 0x00, 0x05,
    0x60, 0x32, 0x32, 0x00, 0x00, 0x02,
    0xa0, 0x0f, 0x0f, 0x00, 0x00, 0x05,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
]

//R22H    r
LUT_BW_ ::= #[
    0x50, 0x0f, 0x0f, 0x00, 0x00, 0x05,
    0x60, 0x32, 0x32, 0x00, 0x00, 0x02,
    0xa0, 0x0f, 0x0f, 0x00, 0x00, 0x05,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
]

//R24H    b
LUT_BB_ ::= #[
    0xa0, 0x0f, 0x0f, 0x00, 0x00, 0x05,
    0x60, 0x32, 0x32, 0x00, 0x00, 0x02,
    0x50, 0x0f, 0x0f, 0x00, 0x00, 0x05,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
]

//R23H    w
LUT_WB_ ::= #[
    0xa0, 0x0f, 0x0f, 0x00, 0x00, 0x05,
    0x60, 0x32, 0x32, 0x00, 0x00, 0x02,
    0x50, 0x0f, 0x0f, 0x00, 0x00, 0x05,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
]
