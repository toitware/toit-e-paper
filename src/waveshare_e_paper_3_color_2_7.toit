// Copyright (C) 2018 Toitware ApS. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

// Driver for the Waveshare 2.7 inch e-paper.  This is a 264x176 three-color
// display.

import font
import .esp32
import .waveshare_e_paper_3_color


WAVESHARE_E_PAPER_2_7_WIDTH ::= 176
WAVESHARE_E_PAPER_2_7_HEIGHT ::= 264

class WaveshareEPaper3Color27 extends WaveshareEPaper3Color:
  constructor device reset busy:
    w := WAVESHARE_E_PAPER_2_7_WIDTH
    h := WAVESHARE_E_PAPER_2_7_HEIGHT
    super device reset busy w h
