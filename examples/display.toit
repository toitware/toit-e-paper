// Copyright (C) 2020 Toitware ApS. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

import font
import pixel-display show *
import pixel-display.two-color show WHITE BLACK

import .get-device

sans ::= font.Font.get "sans10"

main:
  driver := get-device
  display := PixelDisplay.two-color driver
  display.background = WHITE

  // Create graphics context.
  style := Style --color=BLACK --font=sans { "alignment": ALIGN-CENTER }
  // Add text to the display.
  display.add
      Label --x=102 --y=50 --text="Hello, World!" --style=style
  // Update display.
  display.draw --speed=0
