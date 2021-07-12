// Copyright (C) 2018 Toitware ApS. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

// Driver for the two-color Waveshare 640x384 7.5 inch 2 color e-paper display.

// TODO: Should return to deep sleep after a while to avoid damage to the panel.

import bitmap show *
import font show *
import two_color show *
import .esp32
import .waveshare_e_paper
import .waveshare_e_paper_2_color
import peripherals.rpc show *

class WaveshareEPaper2Color75 extends WaveshareEPaper2Color:
  flags ::= RPC_DISPLAY_FLAG_2_COLOR
  width := 0
  height := 0

  constructor device reset busy .width/int .height/int flipped/bool:
    super device reset busy
    reset_.set 0
    sleep --ms=1
    reset_.set 1
    sleep --ms=1
    wait_for_busy 1
    send POWER_SETTING_ 0x37 0x00
    panel_setting := RESOLUTION_600_448_  // Overridden later by explicit resolution setting?
    if flipped:
      panel_setting |= FLIP_X_
      panel_setting |= FLIP_Y_
    panel_setting |= DC_DC_CONVERTER_ON_
    panel_setting |= NO_SOFT_RESET_
    panel_setting |= LUT_FROM_REGISTER_
    send PANEL_SETTING_ panel_setting //0x08
    send BOOSTER_SOFT_START_ 0xc7 0xcc 0x28
    send POWER_ON_
    wait_for_busy 1

    send PLL_CONTROL_ FRAME_RATE_50_HZ_
    send TEMPERATURE_SENSOR_CALIBRATION_ 0x00
    send VCOM_AND_DATA_SETTING_INTERVAL_ 0x77
    send TCON_SETTING_ 0x22

    send_be RESOLUTION_SETTING_ width height

    send VCOM_DC_ 0x1e

    send 0xe5 0x03   // Flash mode

    wait_for_busy 1

  start_full_update speed/int -> none:
    send DATA_START_TRANSMISSION_1_

  draw_2_color left/int top/int right/int bottom/int pixels/ByteArray -> none:
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
    send DISPLAY_REFRESH_
    wait_for_busy 1
