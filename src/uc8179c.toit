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

// For panel setting on the 7.5 inch three-color display.
PANEL-RESET_                   ::= 0x00
PANEL-NO-RESET_                ::= 0x01
PANEL-BOOSTER-OFF_             ::= 0x00
PANEL-BOOSTER-ON_              ::= 0x02
PANEL-SOURCE_SHIFT_LEFT_       ::= 0x00
PANEL-SOURCE_SHIFT_RIGHT_      ::= 0x04
PANEL-GATE-SCAN-DOWN_          ::= 0x00
PANEL-GATE-SCAN_UP_            ::= 0x08
// Use PANEL-BWR_ and PANEL-BW_ to set two-color or three-color mode.
// Use LUT-FROM-FLASH_ and LUT-FROM-REGISTER_ to select the LUT source.

