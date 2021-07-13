// Copyright (C) 2018 Toitware ApS. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

// Driver for the Waveshare 2.7 inch e-paper.  This is a 264x176 three-color
// display.

import .three_color

WAVESHARE_E_PAPER_2_7_WIDTH_ ::= 176
WAVESHARE_E_PAPER_2_7_HEIGHT_ ::= 264

class Waveshare3Color27 extends EPaper3Color:
  constructor device reset busy:
    w := WAVESHARE_E_PAPER_2_7_WIDTH_
    h := WAVESHARE_E_PAPER_2_7_HEIGHT_
    super device reset busy w h
