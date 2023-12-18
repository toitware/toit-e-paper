// Copyright (C) 2018 Toitware ApS. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

// Driver for the two-color Waveshare 640x384 7.5 inch 2 color e-paper display.

// TODO: Should return to deep sleep after a while to avoid damage to the panel.

import bitmap show *
import gpio
import spi

import pixel-display show * 

import .e-paper

class Waveshare2Color75 extends EPaper:
  flags ::= FLAG-2-COLOR
  width := 0
  height := 0

  constructor device/spi.Device
      .width/int .height/int
      --reset/gpio.Pin?
      --busy/gpio.Pin?:
    super device --reset=reset --busy=busy

  initialize -> none:
    wait-for-busy
    send POWER-SETTING_ 0x37 0x00
    panel-setting := RESOLUTION-600-448_  // Overridden later by explicit resolution setting?
    panel-setting |= DC-DC-CONVERTER-ON_
    panel-setting |= NO-SOFT-RESET_
    panel-setting |= LUT-FROM-REGISTER_
    send PANEL-SETTING_ panel-setting //0x08
    send BOOSTER-SOFT-START_ 0xc7 0xcc 0x28
    send POWER-ON_
    wait-for-busy

    send PLL-CONTROL_ FRAME-RATE-50-HZ_
    send TEMPERATURE-SENSOR-CALIBRATION_ 0x00
    send VCOM-AND-DATA-SETTING-INTERVAL_ 0x77
    send TCON-SETTING_ 0x22

    send-be RESOLUTION-SETTING_ width height

    send VCOM-DC_ 0x1e

    send 0xe5 0x03   // Flash mode

    wait-for-busy

  start-full-update speed/int -> none:
    send DATA-START-TRANSMISSION-1_

  draw-two-color left/int top/int right/int bottom/int pixels/ByteArray -> none:
    // BUG: https://github.com/toitware/toit/issues/2939.
    throw "unimplemented"
    /*
    The following code appears to be completely broken. It doesn't
    take the provided coordinates into account.

    8.repeat:
      mask := 1 << it
      for x := 0; x < w; x += 2:
        // Pack 2 pixels in a byte.
        out := 0x00
        if (pixels[x] & mask) == 0: out = 0x30
        if (pixels[x + 1] & mask) == 0: out |= 0x03
        send_ 1 out
    */

  refresh left/int top/int right/int bottom/int ->none:
    send DISPLAY-REFRESH_
    wait-for-busy
