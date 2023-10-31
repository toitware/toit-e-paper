// Copyright (C) 2023 Toitware ApS. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

// Driver for two-color e-paper displays. eg the 640x384 7.5 inch
// 2 color display or the 1.54 inch with partial update.

// TODO: Should return to deep sleep after a while to avoid damage to the panel.

import gpio
import serial.protocols.spi

import .e_paper

abstract class EPaper2Color extends EPaper:
  constructor device/spi.Device
      --reset/gpio.Pin?=null
      --reset_active_high/bool=false
      --busy/gpio.Pin?=null
      --busy_active_high/bool=false:
    super device
        --reset=reset
        --reset_active_high=reset_active_high
        --busy=busy
        --busy_active_high=busy_active_high
