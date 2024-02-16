// Copyright (C) 2024 Toitware ApS. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

import gpio
import spi

import pixel-display show *

import .e-paper show *
import .three-color

import .uc8179c

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
    vgh := VGH-VGL-20-V_
    vdh := 15_000  // +15V
    vdl := 15_000  // -15V
    send POWER-SETTING_
        INTERNAL-POWER-VDHR_ | INTERNAL-POWER-VGH-VGL_ | INTERNAL-POWER-VDH-VDL_
        vgh
        (vdh - VDH-BASE_) / VDH-STEP_
        (vdl - VDL-BASE_) / VDL-STEP_
    send POWER-ON_
    wait-for-busy
    send PANEL-SETTING_
        NO-SOFT-RESET_ | DC-DC-CONVERTER-ON_ | PANEL-BWR_ | LUT-FROM_FLASH_
    send-be RESOLUTION_SETTING_ 800 480

    // Maybe makes it too red?
    send BOOSTER-SOFT-START_
        // Phase A.
        SOFT-START-40-MS_ | SOFT-START-DRIVING-STRENGTH-1_ | SOFT-START-MINIMUM-OFF-GDR-6580-NS_  // 0xc7.
        // Phase B.
        SOFT-START-40-MS_ | SOFT-START-DRIVING-STRENGTH-2_ | SOFT-START-MINIMUM-OFF-GDR-800-NS_   // 0xcc.
        // Phase C1.
        SOFT-START-DRIVING-STRENGTH-7_ | SOFT-START-MINIMUM-OFF-GDR-270-NS_   // 0x30.
        // Phase C2 is not enabled (would need to set SOFT-START-PHASE-C2-ENABLE_).
        SOFT-START-DRIVING-STRENGTH-2_ | SOFT-START-MINIMUM-OFF-GDR-6580-NS_  // 0x17.

    send DUAL-SPI_
        MM-INPUT-PIN-DISABLE_ | DUAL-SPI-MODE-DISABLE_

    send VCOM-AND-DATA-SETTING-INTERVAL_
        BORDER-OUTPUT-HI-Z-DISABLED_ | BORDER-LUT-3-COLOR-MODE-USE-R_ | VCOM-AND-DATA-INTERVAL-16-HSYNC_  // 0x11.
        VCOM-AND-DATA-INTERVAL-10-HSYNC_  // 0x07

    send TCON-SETTING_
        G2S-NON-OVERLAP-PERIOD-12_ | S2G-NON-OVERLAP-PERIOD-12_  // 0x22
