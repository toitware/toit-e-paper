// Copyright (C) 2020 Toitware ApS. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

import font
import two_color show TextTexture WHITE BLACK
import pixel_display show TwoColorPixelDisplay
import texture show TEXT_TEXTURE_ALIGN_CENTER

sans ::= font.Font.get "sans10"
display ::= TwoColorPixelDisplay "eink"

main:
  // Create graphics context.
  context := display.context --landscape --font=sans --alignment=TEXT_TEXTURE_ALIGN_CENTER --color=BLACK
  // Add text to the display.
  display.text context 102 50 "Hello, World!"
  // Update display.
  display.draw
