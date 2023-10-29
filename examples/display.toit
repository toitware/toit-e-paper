// Copyright (C) 2020 Toitware ApS. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

import font
import pixel_display show TwoColorPixelDisplay
import pixel_display.texture show TEXT_TEXTURE_ALIGN_CENTER
import pixel_display.two_color show TextTexture WHITE BLACK

import .get_device

sans ::= font.Font.get "sans10"

main:
  driver := get_device
  display := TwoColorPixelDisplay driver

  // Create graphics context.
  context := display.context --landscape --font=sans --alignment=TEXT_TEXTURE_ALIGN_CENTER --color=BLACK
  // Add text to the display.
  display.text context 102 50 "Hello, World!"
  // Update display.
  display.draw
