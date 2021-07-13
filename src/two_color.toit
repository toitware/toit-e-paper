// Copyright (C) 2018 Toitware ApS. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

// Driver for two-color e-paper displays. eg the 640x384 7.5 inch
// 2 color display or the 1.54 inch with partial update.

// TODO: Should return to deep sleep after a while to avoid damage to the panel.

import .e_paper

abstract class EPaper2Color extends EPaper:
  constructor device reset busy:
    super device reset busy
