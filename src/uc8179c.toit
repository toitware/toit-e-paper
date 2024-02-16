// Copyright (C) 2024 Toitware ApS. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

// Constants for the UC8179C e-paper display chip.
// See the pdf in third_party/docs/UC8179C.pdf for more information.

// Most of the commands match up with the ones in e-paper.toit, but
// there are a few special ones.


// These are not supported (no partial transmision).
// PARTIAL-DATA-START-TRANSMISSION-1_ ::= 0x14
// PARTIAL-DATA-START-TRANSMISSION-2_ ::= 0x15
// PARTIAL-DISPLAY-REFRESH_           ::= 0x16

DUAL-SPI_                      ::= 0x15
AUTO-SEQUENCE_                 ::= 0x17

// The data sheet uses K2W and W2K instead of B2W and W2B.
// This matches the print industry, where K is black as in CMYK.
K2W-LUT_                       ::= B2W-LUT_
W2K-LUT_                       ::= W2B-LUT_
K2K-LUT_                       ::= B2B-LUT_

// Not supported.
// VCOM-LUT-2_                        ::= 0x25

BORDER-LUT_                    ::= 0x25
LUTOPT_                        ::= 0x2A
KW-LUT-OPTION_                 ::= 0x2B
PANEL-BREAK-CHECK_             ::= 0x44
END-VOLTAGE-SETTING_           ::= 0x52
REVISION_                      ::= 0x70

// Not supported.
// AUTO-MEASURE-VCOM_                 ::= 0x80  // AMV
// TURN-OFF-FLASH_                    ::= 0xb9

CASCADE-SETTING_               ::= 0xe0  // CCSET
POWER-SAVING_                  ::= 0xe3  // PWS
LVD-VOLTAGE-SELECT_            ::= 0xe4  // LVSEL
FORCE-TEMPERATURE_             ::= 0xe5  // TSSET
TEMPERATURE-BOUNDARY-PHASE-C2_ ::= 0xe7  // TSBDRY

// For PANEL-SETTING_.
// Use SOFT-RESET_ and NO-SOFT-RESET_ to reset the panel.
// Use DC-DC-CONVERTER-ON_ and DC-DC-CONVERTER-OFF_ to turn on or off the panel
// booster.
// Use PANEL-BWR_ and PANEL-BW_ to set two-color or three-color mode.
// Use LUT-FROM-FLASH_ and LUT-FROM-REGISTER_ to select the LUT source.
// Use FLIP-X_ and FLIP-Y_ to flip the display.

// For POWER-SETTING_, data byte 0.
// Use EXTERNAL-POWER-VGH-VGL_ and INTERNAL-POWER-VGH-VGL_.
// Use EXTERNAL-POWER-VDH-VDL_ and INTERNAL-POWER-VDH-VDL_.
EXTERNAL-POWER-VDHR_            ::= 0x00
INTERNAL-POWER-VDHR_            ::= 0x04  // VSR_EN.
BORDER-LDO-DISABLE_             ::= 0x00
BORDER-LDO-ENABLE_              ::= 0x10  // BD_EN.

// For POWER-SETTING_, data byte 1.
VGH-VGL-9-V_                    ::= 0x00  // Set VGH to 9V, VGL to -9V.
VGH-VGL-10-V_                   ::= 0x01
VGH-VGL-11-V_                   ::= 0x02
VGH-VGL-12-V_                   ::= 0x03
VGH-VGL-17-V_                   ::= 0x04
VGH-VGL-18-V_                   ::= 0x05
VGH-VGL-19-V_                   ::= 0x06
VGH-VGL-20-V_                   ::= 0x07
VCOM_SKEW_                      ::= 0x10  // "The value is fixed".

// For POWER-SETTING_, data byte 2.
VDH-BASE_                       ::=  2400  // 2.4V.
VDH-STEP_                       ::=   200  // 0.2V increments.
VDH-MAX_                        ::= 15000  // 15V max.

// For POWER-SETTING_, data byte 3.
VDL-BASE_                       ::=  2400  // 2.4V.
VDL-STEP_                       ::=   200  // 0.2V increments.
VDL-MAX_                        ::= 15000  // 15V max.

// For POWER-SETTING_, data byte 4.
VDHR-BASE_                      ::=  2400  // 2.4V.
VDHR-STEP_                      ::=   200  // 0.2V increments.
VDHR-MAX_                       ::= 15000  // 15V max.

// For POWER-OFF-SEQUENCE_.
POWER-OFF-1-FRAME_              ::= 0x00
POWER-OFF-2-FRAMES_             ::= 0x10
POWER-OFF-3-FRAMES_             ::= 0x20
POWER-OFF-4-FRAMES_             ::= 0x30

// For DUAL-SPI_.
MM-INPUT-PIN-DISABLE_           ::= 0x00
MM-INPUT-PIN-ENABLE_            ::= 0x10
DUAL-SPI-MODE-DISABLE_          ::= 0x00
DUAL-SPI-MODE-ENABLE_           ::= 0x20

// For AUTO-SEQUENCE_.
// This check byte causes power on, refresh, power off.
AUTO-SEQUENCE-CHECK_            ::= 0xa5
// This check byte causes power on, refresh, power off, deep sleep.
AUTO-SEQUENCE-DEEP-SLEEP-CHECK_ ::= 0xa7

// VCOM-LUT_ takes 10 packets of 6 bytes each.
// Documentation is not clear, but best guess (big endian ordering within
// bytes):
// struct command_structure {
//   unsigned int level0 : 2;
//   unsigned int level1 : 2;
//   unsigned int level2 : 2;
//   unsigned int level3 : 2;
//   uint8_t level0_frames;
//   uint8_t level1_frames;
//   uint8_t level2_frames;
//   uint8_t level3_frames;
//   uint8_t times_to_repeat;
// }
// The 2-bit level fields are determined by:
SELECT-LEVEL-VCOM-DC_           ::= 0x0
SELECT-LEVEL-VDH-PLUS-VCOM-DC_  ::= 0x1
SELECT-LEVEL-VDL-PLUS-VCOM-DC_  ::= 0x2
SELECT-LEVEL-FLOATING_          ::= 0x3

// Frame rates for PLL-CONTROL_.  These values do not match the
// values of FRAME-RATE-100-HZ_ and FRAME-RATE-50-HZ_ in e-paper.toit.
UC8179C-FRAME-RATE-5-HZ_        ::= 0x00
UC8179C-FRAME-RATE-10-HZ_       ::= 0x01
UC8179C-FRAME-RATE-15-HZ_       ::= 0x02
UC8179C-FRAME-RATE-20-HZ_       ::= 0x03
UC8179C-FRAME-RATE-30-HZ_       ::= 0x04
UC8179C-FRAME-RATE-40-HZ_       ::= 0x05
UC8179C-FRAME-RATE-50-HZ_       ::= 0x06
UC8179C-FRAME-RATE-60-HZ_       ::= 0x07
UC8179C-FRAME-RATE-70-HZ_       ::= 0x08
UC8179C-FRAME-RATE-80-HZ_       ::= 0x09
UC8179C-FRAME-RATE-90-HZ_       ::= 0x0a
UC8179C-FRAME-RATE-100-HZ_      ::= 0x0b
UC8179C-FRAME-RATE-110-HZ_      ::= 0x0c
UC8179C-FRAME-RATE-130-HZ_      ::= 0x0d
UC8179C-FRAME-RATE-150-HZ_      ::= 0x0e
UC8179C-FRAME-RATE-200-HZ_      ::= 0x0f

// For RESOLUTION-SETTING_ the order is hres, vres. Both are 16 bit
// values, big endian, for 4 bytes of data.
