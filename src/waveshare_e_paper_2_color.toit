// Copyright (C) 2018 Toitware ApS. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

// Driver for the two-color Waveshare e-paper displays. eg the 640x384 7.5 inch
// 2 color display or the 1.54 inch with partial update.

// TODO: Should return to deep sleep after a while to avoid damage to the panel.

import .waveshare_e_paper

abstract class WaveshareEPaper2Color extends WaveshareEPaper:
  constructor device reset busy:
    super device reset busy
