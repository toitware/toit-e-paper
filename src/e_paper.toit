// Copyright (C) 2023 Toitware ApS. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

// Driver for SPI-connected e-paper displays.  These are two- or three-color displays.

import binary
import bitmap
import gpio
import spi

import pixel-display show AbstractDriver

PANEL-SETTING_                     ::= 0x00  // PSR
POWER-SETTING_                     ::= 0x01
POWER-OFF_                         ::= 0x02  // PWR
POWER-OFF-SEQUENCE_                ::= 0x03
POWER-ON_                          ::= 0x04
POWER-ON-MEASURE_                  ::= 0x05  // PMES
BOOSTER-SOFT-START_                ::= 0x06  // BTST
DEEP-SLEEP_                        ::= 0x07
DATA-START-TRANSMISSION-1_         ::= 0x10
DATA-STOP_                         ::= 0x11
DISPLAY-REFRESH_                   ::= 0x12
DATA-START-TRANSMISSION-2_         ::= 0x13
PARTIAL-DATA-START-TRANSMISSION-1_ ::= 0x14
PARTIAL-DATA-START-TRANSMISSION-2_ ::= 0x15
PARTIAL-DISPLAY-REFRESH_           ::= 0x16
VCOM-LUT_                          ::= 0x20  // LUTC
W2W-LUT_                           ::= 0x21  // LUTWW
B2W-LUT_                           ::= 0x22  // LUTBW/LUTR
W2B-LUT_                           ::= 0x23  // LUTWB/LUTW
B2B-LUT_                           ::= 0x24  // LUTBB/LUTB
VCOM-LUT-2_                        ::= 0x25  // For grayscale.
PLL-CONTROL_                       ::= 0x30
TEMPERATURE-SENSOR-CALIBRATION_    ::= 0x40
TEMPERATURE-SENSOR-SELECTION_      ::= 0x41
TEMPERATURE-SENSOR-WRITE_          ::= 0x42  // TSW
TEMPERATURE-SENSOR-READ_           ::= 0x43  // TSR
VCOM-AND-DATA-SETTING-INTERVAL_    ::= 0x50
LOW-POWER-DETECTION_               ::= 0x51
TCON-SETTING_                      ::= 0x60  // TCON
RESOLUTION-SETTING_                ::= 0x61
SOURCE-AND-GATE-START-SETTING_     ::= 0x62
FLASH-CONTROL_                     ::= 0x65  // 1 = enable, 0 = disable
GET-STATUS_                        ::= 0x71
AUTO-MEASURE-VCOM_                 ::= 0x80  // AMV
VCOM-VALUE_                        ::= 0x81  // VV
VCOM-DC_                           ::= 0x82
PARTIAL-WINDOW_                    ::= 0x90
PARTIAL-IN_                        ::= 0x91  // Enter partial update mode
PARTIAL-OUT_                       ::= 0x92  // Exit partial update mode
PROGRAM-MODE_                      ::= 0xa0  // PGM
ACTIVE-PROGRAM_                    ::= 0xa1  // APG
READ-OTP-DATA_                     ::= 0xa2  // ROTP
TURN-OFF-FLASH_                    ::= 0xb9

// Check code for deep sleep command.
DEEP-SLEEP-CHECK_                  ::= 0xa5

POWER-OPTIMIZATION_                ::= 0xf8

DRIVER-OUTPUT-154_                 ::= 0x01
BOOSTER-SOFT-START-154_            ::= 0x0c
GATE-SCAN-START-POSITION-154_      ::= 0x0f
DEEP-SLEEP-MODE-154_               ::= 0x10
DATA-ENTRY-MODE-154_               ::= 0x11
SOFTWARE-RESET-154_                ::= 0x12
TEMPERATURE-SENSOR-154_            ::= 0x1a
MASTER-ACTIVATION-154_             ::= 0x20
DISPLAY-UPDATE-1-154_              ::= 0x21
DISPLAY-UPDATE-2-154_              ::= 0x22
WRITE-RAM-154_                     ::= 0x24
WRITE-RAM-RED-154_                 ::= 0x26
WRITE-VCOM-154_                    ::= 0x2c
WRITE-LUT-154_                     ::= 0x32
WRITE-DUMMY-LINE-PERIOD-154_       ::= 0x3a
SET-GATE-TIME-154_                 ::= 0x3b
BORDER-WAVEFORM-154_               ::= 0x3c
SET-RAM-X-RANGE-154_               ::= 0x44
SET-RAM-Y-RANGE-154_               ::= 0x45
SET-RAM-X-ADDRESS-154_             ::= 0x4e
SET-RAM-Y-ADDRESS-154_             ::= 0x4f
NOP-154_                           ::= 0xff

// For panel setting on 3-color panels.
THREE-COLOR_                       ::= 0x00
TWO-COLOR_                         ::= 0x10

// For panel setting on 7.5 inch 2 color panel.
RESOLUTION-640-480_                ::= 0x00
RESOLUTION-600-450_                ::= 0x40
RESOLUTION-640-448_                ::= 0x80
RESOLUTION-600-448_                ::= 0xc0

LUT-FROM-FLASH_                    ::= 0x00
LUT-FROM-REGISTER_                 ::= 0x20

FLIP-Y_                            ::= 0x08
FLIP-X_                            ::= 0x04

DC-DC-CONVERTER-OFF_               ::= 0x00
DC-DC-CONVERTER-ON_                ::= 0x02

SOFT-RESET_                        ::= 0x00
NO-SOFT-RESET_                     ::= 0x01

// For PLL control on 7.5 inch 2 color panel
FRAME-RATE-100-HZ_                 ::= 0x3a
FRAME-RATE-50-HZ_                  ::= 0x3c

// For power setting on the 2.9 inch 4 gray panel.
// Register POWER_SETTING_ (0x01), byte 0, page 27, GDEW027W3-2.pdf.
EXTERNAL-POWER-VGH-VGL_            ::= 0x00
INTERNAL-POWER-VGH-VGL_            ::= 0x01
EXTERNAL-POWER-VDH-VDL_            ::= 0x00
INTERNAL-POWER-VDH-VDL_            ::= 0x02

// Register POWER_SETTING_ (0x01), byte 1, page 27, GDEW027W3-2.pdf.
VCOM-VOLTAGE-ADDITIVE_             ::= 0x00  // VCOMH=VDH+VCOMDC, VCOML=VHL+VCOMDC.
VCOM-VOLTAGE-VGHL_                 ::= 0x04  // VCOMH=VGH, VCOML=VGL.
VCOM-VGHL-LV-MINUS-16-V_           ::= 0x00  // Recommended.
VCOM-VGHL-LV-MINUS-15-V_           ::= 0x01
VCOM-VGHL-LV-MINUS-14-V_           ::= 0x02
VCOM-VGHL-LV-MINUS-13-V_           ::= 0x03

// Register POWER_SETTING_ (0x01), bytes 2-4, page 27, GDEW027W3-2.pdf.
// 10V recommended for high voltage, black/white pixel.
// -10V recommended for low voltage, black/white pixel.
// 3V recommended for high voltage, red pixel.
VCOM-VDHL-BASE_                    ::= 2400    // Zero means 2.4V.
VCOM-VDHL-STEP_                    ::= 200     // 0.2V steps.
VCOM-VDHL-10-V_                    ::= 0x26    // ±10 volts.
VCOM-VDHL-11-V_                    ::= 0x2b    // ±11 volts.
VCOM-VDHR-3-V_                     ::= 0x03    // 3 volts.
VCOM-VDHR-4-2-V_                   ::= 0x09    // 4.2 volts.
VCOM-VDHL-MAX_                     ::= 11000   // 11V maximum.

// For VCOM DC setting on the 2.9 inch 4 gray panel.
// Register VCOM_DC_ (0x82), page 40, GDEW027W3-2.pdf.
VCOM-DC-BASE_                      ::= 100     // -100 millivolts.
VCOM-DC-STEP_                      ::= 50      // 50mV steps.
VCOM-DC-MAX_                       ::= 4000    // -4V maximum.
VCOM-DC-MINUS-1-V_                 ::= 0x12    // -1V recommended.

// For panel setting on the 2.9 inch 4 gray panel.
RESOLUTION-320-300_                ::= 0x00
RESOLUTION-300-200_                ::= 0x40
RESOLUTION-296-160_                ::= 0x80  // Datasheet recommends w/ 296x176.
RESOLUTION-296-128_                ::= 0xc0
PANEL-BWR_                         ::= 0x00  // Black-white-red mode (also used for gray).
PANEL-BW_                          ::= 0x10  // Black-white mode.

// For booster soft start settings of the 2.9 inch 4 gray panel.
SOFT-START-10-MS_                  ::= 0x00  // Recommended.
SOFT-START-20-MS_                  ::= 0x40
SOFT-START-30-MS_                  ::= 0x80
SOFT-START-100-MS_                 ::= 0xc0
SOFT-START-DRIVING-STRENGTH-1_     ::= 0x00
SOFT-START-DRIVING-STRENGTH-2_     ::= 0x08
SOFT-START-DRIVING-STRENGTH-3_     ::= 0x10  // Recommended.
SOFT-START-DRIVING-STRENGTH-4_     ::= 0x18
SOFT-START-DRIVING-STRENGTH-5_     ::= 0x20
SOFT-START-DRIVING-STRENGTH-6_     ::= 0x28
SOFT-START-DRIVING-STRENGTH-7_     ::= 0x30
SOFT-START-DRIVING-STRENGTH-8_     ::= 0x38
SOFT-START-MINIMUM-OFF-GDR-270-NS_ ::= 0x00
SOFT-START-MINIMUM-OFF-GDR-340-NS_ ::= 0x01
SOFT-START-MINIMUM-OFF-GDR-400-NS_ ::= 0x02
SOFT-START-MINIMUM-OFF-GDR-540-NS_ ::= 0x03
SOFT-START-MINIMUM-OFF-GDR-800-NS_ ::= 0x04
SOFT-START-MINIMUM-OFF-GDR-1540-NS_ ::= 0x05
SOFT-START-MINIMUM-OFF-GDR-3340-NS_ ::= 0x06
SOFT-START-MINIMUM-OFF-GDR-6580-NS_ ::= 0x07  // Recommended.

abstract class EPaper extends AbstractDriver:
  device_/spi.Device := ?
  // Pin numbers.
  reset_/gpio.Pin? := ?               // Reset line.
  reset-active-high_/bool
  busy_/gpio.Pin? := ?                // From screen to device, active = busy, not active = not busy.
  busy-active-high_/bool

  cmd-buffer_/ByteArray ::= ByteArray 1
  buffer_/ByteArray

  constructor .device_
      --reset/gpio.Pin?
      --reset-active-high/bool=false
      --busy/gpio.Pin?
      --busy-active-high/bool=false:

    reset_ = reset
    reset-active-high_ = reset-active-high
    busy_ = busy
    busy-active-high_ = busy-active-high

    // Also used for sending large repeated arrays - speed vs mem tradeoff.
    buffer_ = ByteArray 128

    if reset_:
      reset_.configure --output

    if busy_:
      busy_.configure --input

  reset --ms/int=1 -> none:
    if reset_:
      if reset-active-high_:
        reset_.set 1
        sleep --ms=ms
      reset_.set 0
      sleep --ms=ms
      if not reset-active-high_:
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
    send-array command buffer_ --to=2

  send command data data2 data3:
    buffer_[0] = data
    buffer_[1] = data2
    buffer_[2] = data3
    send-array command buffer_ --to=3

  send command data data2 data3 data4:
    buffer_[0] = data
    buffer_[1] = data2
    buffer_[2] = data3
    buffer_[3] = data4
    send-array command buffer_ --to=4

  /// Send a command byte, followed by an array of data bytes.
  // TODO(anders): array should be ByteArray (needs ByteArray literals).
  send-array command array --from=0 --to=array.size:
    send_ 0 command
    if array is not ByteArray:
      array = ByteArray array.size: array[it]
    device_.transfer array --from=from --to=to --dc=1

  /// Send an array of data bytes without any preceeding command bytes.
  send-continued-array array/ByteArray --from=0 --to=array.size:
    device_.transfer array --from=from --to=to --dc=1

  send-repeated-bytes repeats byte:
    bitmap.bytemap-zap buffer_ byte
    List.chunk-up 0 repeats buffer_.size: | _ _ size |
      device_.transfer buffer_ --to=size --dc=1

  send_ dc byte:
    cmd-buffer_[0] = byte
    device_.transfer cmd-buffer_ --dc=dc

  // Send a command with a 16 bit argument, little-endian order.
  send-le command x:
    binary.LITTLE-ENDIAN.put-uint16 buffer_ 0 x
    send-array command buffer_ --to=2

  // Send a command with two 16 bit arguments, little-endian order.
  send-le command x y:
    binary.LITTLE-ENDIAN.put-uint16 buffer_ 0 x
    binary.LITTLE-ENDIAN.put-uint16 buffer_ 2 y
    send-array command buffer_ --to=4

  // Send a command with four 16 bit arguments, little-endian order.
  send-le command x y w h:
    binary.LITTLE-ENDIAN.put-uint16 buffer_ 0 x
    binary.LITTLE-ENDIAN.put-uint16 buffer_ 2 y
    binary.LITTLE-ENDIAN.put-uint16 buffer_ 4 w
    binary.LITTLE-ENDIAN.put-uint16 buffer_ 6 h
    send-array command buffer_ --to=8

  // Send a command with a 16 bit argument, big endian order.
  send-be command x:
    binary.BIG-ENDIAN.put-uint16 buffer_ 0 x
    send-array command buffer_ --to=2

  // Send a command with two 16 bit arguments, big endian order.
  send-be command x y:
    binary.BIG-ENDIAN.put-uint16 buffer_ 0 x
    binary.BIG-ENDIAN.put-uint16 buffer_ 2 y
    send-array command buffer_ --to=4

  // Send a command with four 16 bit arguments, big endian order.
  send-be command x y w h:
    binary.BIG-ENDIAN.put-uint16 buffer_ 0 x
    binary.BIG-ENDIAN.put-uint16 buffer_ 2 y
    binary.BIG-ENDIAN.put-uint16 buffer_ 4 w
    binary.BIG-ENDIAN.put-uint16 buffer_ 6 h
    send-array command buffer_ --to=8

  wait-for-busy:
    if busy_:
      value := busy-active-high_ ? 0 : 1
      e := catch:
        with-timeout --ms=5_000:
          busy_.wait-for value
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
    byte-width := width >> 3
    transposed := ByteArray byte-width
    row := 0
    for y := 0; y < height; y += 8:
      for in-bit := 0; in-bit < 8 and y + in-bit < height; in-bit++:
        for x := 0; x < byte-width; x++:
          out := 0
          byte-pos := row + (x << 3) + 7
          for out-bit := 7; out-bit >= 0; out-bit--:
            out |= ((array[byte-pos - out-bit] >> in-bit) & 1) << out-bit
          transposed[x] = out ^ xor
        send-continued-array transposed
      row += width

  abstract commit left/int top/int right/int bottom/int -> none

  clean x/int y/int right/int bottom/int:
