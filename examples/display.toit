// Copyright (C) 2020 Toitware ApS. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

import font
import pixel-display show TwoColorPixelDisplay
import pixel-display.texture show TEXT-TEXTURE-ALIGN-CENTER
import pixel-display.two-color show TextTexture WHITE BLACK

import .get-device

sans ::= font.Font.get "sans10"

main:
  driver := get-device
  display := TwoColorPixelDisplay driver

  // Create graphics context.
  context := display.context --landscape --font=sans --alignment=TEXT-TEXTURE-ALIGN-CENTER --color=BLACK
  // Add text to the display.
  display.text context 102 50 "Hello, World!"
  // Update display.
  display.draw
