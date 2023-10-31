// Copyright (C) 2023 Toitware ApS. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

// Driver for SPI-connected e-paper displays.  These are two- or three-color displays.

import binary
import bitmap
import gpio
import serial.protocols.spi

import pixel_display show AbstractDriver

PANEL_SETTING_                     ::= 0x00  // PSR
POWER_SETTING_                     ::= 0x01
POWER_OFF_                         ::= 0x02  // PWR
POWER_OFF_SEQUENCE_                ::= 0x03
POWER_ON_                          ::= 0x04
POWER_ON_MEASURE_                  ::= 0x05  // PMES
BOOSTER_SOFT_START_                ::= 0x06  // BTST
DEEP_SLEEP_                        ::= 0x07
DATA_START_TRANSMISSION_1_         ::= 0x10
DATA_STOP_                         ::= 0x11
DISPLAY_REFRESH_                   ::= 0x12
DATA_START_TRANSMISSION_2_         ::= 0x13
PARTIAL_DATA_START_TRANSMISSION_1_ ::= 0x14
PARTIAL_DATA_START_TRANSMISSION_2_ ::= 0x15
PARTIAL_DISPLAY_REFRESH_           ::= 0x16
VCOM_LUT_                          ::= 0x20  // LUTC
W2W_LUT_                           ::= 0x21  // LUTWW
B2W_LUT_                           ::= 0x22  // LUTBW/LUTR
W2B_LUT_                           ::= 0x23  // LUTWB/LUTW
B2B_LUT_                           ::= 0x24  // LUTBB/LUTB
VCOM_LUT_2_                        ::= 0x25  // For grayscale.
PLL_CONTROL_                       ::= 0x30
TEMPERATURE_SENSOR_CALIBRATION_    ::= 0x40
TEMPERATURE_SENSOR_SELECTION_      ::= 0x41
TEMPERATURE_SENSOR_WRITE_          ::= 0x42  // TSW
TEMPERATURE_SENSOR_READ_           ::= 0x43  // TSR
VCOM_AND_DATA_SETTING_INTERVAL_    ::= 0x50
LOW_POWER_DETECTION_               ::= 0x51
TCON_SETTING_                      ::= 0x60  // TCON
RESOLUTION_SETTING_                ::= 0x61
SOURCE_AND_GATE_START_SETTING_     ::= 0x62
FLASH_CONTROL_                     ::= 0x65  // 1 = enable, 0 = disable
GET_STATUS_                        ::= 0x71
AUTO_MEASURE_VCOM_                 ::= 0x80  // AMV
VCOM_VALUE_                        ::= 0x81  // VV
VCOM_DC_                           ::= 0x82
PARTIAL_WINDOW_                    ::= 0x90
PARTIAL_IN_                        ::= 0x91  // Enter partial update mode
PARTIAL_OUT_                       ::= 0x92  // Exit partial update mode
PROGRAM_MODE_                      ::= 0xa0  // PGM
ACTIVE_PROGRAM_                    ::= 0xa1  // APG
READ_OTP_DATA_                     ::= 0xa2  // ROTP
TURN_OFF_FLASH_                    ::= 0xb9

// Check code for deep sleep command.
DEEP_SLEEP_CHECK_                  ::= 0xa5

POWER_OPTIMIZATION_                ::= 0xf8

DRIVER_OUTPUT_154_                 ::= 0x01
BOOSTER_SOFT_START_154_            ::= 0x0c
GATE_SCAN_START_POSITION_154_      ::= 0x0f
DEEP_SLEEP_MODE_154_               ::= 0x10
DATA_ENTRY_MODE_154_               ::= 0x11
SOFTWARE_RESET_154_                ::= 0x12
TEMPERATURE_SENSOR_154_            ::= 0x1a
MASTER_ACTIVATION_154_             ::= 0x20
DISPLAY_UPDATE_1_154_              ::= 0x21
DISPLAY_UPDATE_2_154_              ::= 0x22
WRITE_RAM_154_                     ::= 0x24
WRITE_RAM_RED_154_                 ::= 0x26
WRITE_VCOM_154_                    ::= 0x2c
WRITE_LUT_154_                     ::= 0x32
WRITE_DUMMY_LINE_PERIOD_154_       ::= 0x3a
SET_GATE_TIME_154_                 ::= 0x3b
BORDER_WAVEFORM_154_               ::= 0x3c
SET_RAM_X_RANGE_154_               ::= 0x44
SET_RAM_Y_RANGE_154_               ::= 0x45
SET_RAM_X_ADDRESS_154_             ::= 0x4e
SET_RAM_Y_ADDRESS_154_             ::= 0x4f
NOP_154_                           ::= 0xff

// For panel setting on 3-color panels.
THREE_COLOR_                       ::= 0x00
TWO_COLOR_                         ::= 0x10

// For panel setting on 7.5 inch 2 color panel.
RESOLUTION_640_480_                ::= 0x00
RESOLUTION_600_450_                ::= 0x40
RESOLUTION_640_448_                ::= 0x80
RESOLUTION_600_448_                ::= 0xc0

LUT_FROM_FLASH_                    ::= 0x00
LUT_FROM_REGISTER_                 ::= 0x20

FLIP_Y_                            ::= 0x08
FLIP_X_                            ::= 0x04

DC_DC_CONVERTER_OFF_               ::= 0x00
DC_DC_CONVERTER_ON_                ::= 0x02

SOFT_RESET_                        ::= 0x00
NO_SOFT_RESET_                     ::= 0x01

// For PLL control on 7.5 inch 2 color panel
FRAME_RATE_100_HZ_                 ::= 0x3a
FRAME_RATE_50_HZ_                  ::= 0x3c

// For power setting on the 2.9 inch 4 gray panel.
// Register POWER_SETTING_ (0x01), byte 0, page 27, GDEW027W3-2.pdf.
EXTERNAL_POWER_VGH_VGL_            ::= 0x00
INTERNAL_POWER_VGH_VGL_            ::= 0x01
EXTERNAL_POWER_VDH_VDL_            ::= 0x00
INTERNAL_POWER_VDH_VDL_            ::= 0x02

// Register POWER_SETING_ (0x01), byte 1, page 27, GDEW027W3-2.pdf.
VCOM_VOLTAGE_ADDITIVE_             ::= 0x00  // VCOMH=VDH+VCOMDC, VCOML=VHL+VCOMDC.
VCOM_VOLTAGE_VGHL_                 ::= 0x04  // VCOMH=VGH, VCOML=VGL.
VCOM_VGHL_LV_MINUS_16_V_           ::= 0x00  // Recommended.
VCOM_VGHL_LV_MINUS_15_V_           ::= 0x01
VCOM_VGHL_LV_MINUS_14_V_           ::= 0x02
VCOM_VGHL_LV_MINUS_13_V_           ::= 0x03

// Register POWER_SETING_ (0x01), bytes 2-4, page 27, GDEW027W3-2.pdf.
// 10V recommended for high voltage, black/white pixel.
// -10V recommended for low voltage, black/white pixel.
// 3V recommended for high voltage, red pixel.
VCOM_VDHL_BASE_                    ::= 2400    // Zero means 2.4V.
VCOM_VDHL_STEP_                    ::= 200     // 0.2V steps.
VCOM_VDHL_10_V_                    ::= 0x26    // ±10 volts.
VCOM_VDHL_11_V_                    ::= 0x2b    // ±11 volts.
VCOM_VDHR_3_V_                     ::= 0x03    // 3 volts.
VCOM_VDHR_4_2_V_                   ::= 0x09    // 4.2 volts.
VCOM_VDHL_MAX_                     ::= 11000   // 11V maximum.

// For VCOM DC setting on the 2.9 inch 4 gray panel.
// Register VCOM_DC_ (0x82), page 40, GDEW027W3-2.pdf.
VCOM_DC_BASE_                      ::= 100     // -100 millivolts.
VCOM_DC_STEP_                      ::= 50      // 50mV steps.
VCOM_DC_MAX_                       ::= 4000    // -4V maximum.
VCOM_DC_MINUS_1_V_                 ::= 0x12    // -1V recommended.

// For panel setting on the 2.9 inch 4 gray panel.
RESOLUTION_320_300_                ::= 0x00
RESOLUTION_300_200_                ::= 0x40
RESOLUTION_296_160_                ::= 0x80  // Datasheet recommends w/ 296x176.
RESOLUTION_296_128_                ::= 0xc0
PANEL_BWR_                         ::= 0x00  // Black-white-red mode (also used for gray).
PANEL_BW_                          ::= 0x10  // Black-white mode.

// For booster soft start settings of the 2.9 inch 4 gray panel.
SOFT_START_10_MS_                  ::= 0x00      // Recommended.
SOFT_START_20_MS_                  ::= 0x40
SOFT_START_30_MS_                  ::= 0x80
SOFT_START_100_MS_                 ::= 0xc0
SOFT_START_DRIVING_STRENGTH_1_     ::= 0x00
SOFT_START_DRIVING_STRENGTH_2_     ::= 0x08
SOFT_START_DRIVING_STRENGTH_3_     ::= 0x10  // Recommended.
SOFT_START_DRIVING_STRENGTH_4_     ::= 0x18
SOFT_START_DRIVING_STRENGTH_5_     ::= 0x20
SOFT_START_DRIVING_STRENGTH_6_     ::= 0x28
SOFT_START_DRIVING_STRENGTH_7_     ::= 0x30
SOFT_START_DRIVING_STRENGTH_8_     ::= 0x38
SOFT_START_MINIMUM_OFF_GDR_270_NS_ ::= 0x00
SOFT_START_MINIMUM_OFF_GDR_340_NS_ ::= 0x01
SOFT_START_MINIMUM_OFF_GDR_400_NS_ ::= 0x02
SOFT_START_MINIMUM_OFF_GDR_540_NS_ ::= 0x03
SOFT_START_MINIMUM_OFF_GDR_800_NS_ ::= 0x04
SOFT_START_MINIMUM_OFF_GDR_1540_NS_ ::= 0x05
SOFT_START_MINIMUM_OFF_GDR_3340_NS_ ::= 0x06
SOFT_START_MINIMUM_OFF_GDR_6580_NS_ ::= 0x07  // Recommended.

abstract class EPaper extends AbstractDriver:
  device_/spi.Device := ?
  // Pin numbers.
  reset_/gpio.Pin? := ?               // Reset line.
  reset_active_high_/bool
  busy_/gpio.Pin? := ?                // From screen to device, active = busy, not active = not busy.
  busy_active_high_/bool

  cmd_buffer_/ByteArray ::= ByteArray 1
  buffer_/ByteArray

  constructor .device_
      --reset/gpio.Pin?
      --reset_active_high/bool=false
      --busy/gpio.Pin?
      --busy_active_high/bool=false:

    reset_ = reset
    reset_active_high_ = reset_active_high
    busy_ = busy
    busy_active_high_ = busy_active_high

    // Also used for sending large repeated arrays - speed vs mem tradeoff.
    buffer_ = ByteArray 128

    if reset_:
      reset_.config --output

    if busy_:
      busy_.config --input

  reset --ms/int=1 -> none:
    if reset_:
      if reset_active_high_:
        reset_.set 1
        sleep --ms=ms
      reset_.set 0
      sleep --ms=ms
      if not reset_active_high_:
        reset_.set 1
        sleep --ms=ms

  send command:
    send_ 0 command

  send command data:
    send_ 0 command
    send_ 1 data

  send command data data2:
    buffer_[0] = data
    buffer_[1] = data2
    send_array command buffer_ --to=2

  send command data data2 data3:
    buffer_[0] = data
    buffer_[1] = data2
    buffer_[2] = data3
    send_array command buffer_ --to=3

  send command data data2 data3 data4:
    buffer_[0] = data
    buffer_[1] = data2
    buffer_[2] = data3
    buffer_[3] = data4
    send_array command buffer_ --to=4

  /// Send a command byte, followed by an array of data bytes.
  // TODO(anders): array should be ByteArray (needs ByteArray literals).
  send_array command array --from=0 --to=array.size:
    send_ 0 command
    if array is not ByteArray:
      array = ByteArray array.size: array[it]
    device_.transfer array --from=from --to=to --dc=1

  /// Send an array of data bytes without any preceeding command bytes.
  send_continued_array array/ByteArray --from=0 --to=array.size:
    device_.transfer array --from=from --to=to --dc=1

  send_repeated_bytes repeats byte:
    bitmap.bytemap_zap buffer_ byte
    List.chunk_up 0 repeats buffer_.size: | _ _ size |
      device_.transfer buffer_ --to=size --dc=1

  send_ dc byte:
    cmd_buffer_[0] = byte
    device_.transfer cmd_buffer_ --dc=dc

  // Send a command with a 16 bit argument, little-endian order.
  send_le command x:
    binary.LITTLE_ENDIAN.put_uint16 buffer_ 0 x
    send_array command buffer_ --to=2

  // Send a command with two 16 bit arguments, little-endian order.
  send_le command x y:
    binary.LITTLE_ENDIAN.put_uint16 buffer_ 0 x
    binary.LITTLE_ENDIAN.put_uint16 buffer_ 2 y
    send_array command buffer_ --to=4

  // Send a command with four 16 bit arguments, little-endian order.
  send_le command x y w h:
    binary.LITTLE_ENDIAN.put_uint16 buffer_ 0 x
    binary.LITTLE_ENDIAN.put_uint16 buffer_ 2 y
    binary.LITTLE_ENDIAN.put_uint16 buffer_ 4 w
    binary.LITTLE_ENDIAN.put_uint16 buffer_ 6 h
    send_array command buffer_ --to=8

  // Send a command with a 16 bit argument, big endian order.
  send_be command x:
    binary.BIG_ENDIAN.put_uint16 buffer_ 0 x
    send_array command buffer_ --to=2

  // Send a command with two 16 bit arguments, big endian order.
  send_be command x y:
    binary.BIG_ENDIAN.put_uint16 buffer_ 0 x
    binary.BIG_ENDIAN.put_uint16 buffer_ 2 y
    send_array command buffer_ --to=4

  // Send a command with four 16 bit arguments, big endian order.
  send_be command x y w h:
    binary.BIG_ENDIAN.put_uint16 buffer_ 0 x
    binary.BIG_ENDIAN.put_uint16 buffer_ 2 y
    binary.BIG_ENDIAN.put_uint16 buffer_ 4 w
    binary.BIG_ENDIAN.put_uint16 buffer_ 6 h
    send_array command buffer_ --to=8

  wait_for_busy:
    if busy_:
      value := busy_active_high_ ? 0 : 1
      e := catch:
        with_timeout --ms=5_000:
          busy_.wait_for value
      if e:
        print "E-paper display timed out waiting for busy pin, which is now $busy_.get"
        throw e  // Rethrow.
    else:
      sleep --ms=5_000

  // Writes part of the canvas to the device.  The canvas is arranged as
  // height/8 strips of width bytes, where each byte represents 8 vertically
  // stacked pixels.  The displays require these be transposed so that each
  // line is represented by width/8 consecutive bytes, from top to bottom.
  dump_ xor array width height:
    byte_width := width >> 3
    transposed := ByteArray byte_width
    row := 0
    for y := 0; y < height; y += 8:
      for in_bit := 0; in_bit < 8 and y + in_bit < height; in_bit++:
        for x := 0; x < byte_width; x++:
          out := 0
          byte_pos := row + (x << 3) + 7
          for out_bit := 7; out_bit >= 0; out_bit--:
            out |= ((array[byte_pos - out_bit] >> in_bit) & 1) << out_bit
          transposed[x] = out ^ xor
        send_continued_array transposed
      row += width

  abstract commit left/int top/int right/int bottom/int -> none

  clean x/int y/int right/int bottom/int:
