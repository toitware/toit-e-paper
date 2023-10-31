// Copyright (C) 2023 Toitware ApS.
// Use of this source code is governed by a Zero-Clause BSD license that can
// be found in the EXAMPLES_LICENSE file.

import e_paper.gooddisplay_3_color_2_7 show *

import font
import gpio
import serial.protocols.spi

import pixel_display show ThreeColorPixelDisplay
import pixel_display.texture show TEXT_TEXTURE_ALIGN_CENTER
import pixel_display.three_color show TextTexture WHITE BLACK RED

sans ::= font.Font.get "sans10"

// Pins
BUSY ::= 16
RESET ::= 4
DC ::= 2
CS ::= 14
CLOCK ::= 12
DIN ::= 13

main:
  bus := spi.Bus
    --mosi=gpio.Pin DIN
    --clock=gpio.Pin CLOCK

  device := bus.device
    --cs=gpio.Pin CS
    --dc=gpio.Pin DC
    --frequency=10_000_000

  driver := Gooddisplay3Color27
    device
    --reset=gpio.Pin.out RESET
    --busy=gpio.Pin.in BUSY
  display := ThreeColorPixelDisplay driver

  // Create graphics context.
  context := display.context --landscape --font=sans --alignment=TEXT_TEXTURE_ALIGN_CENTER --color=BLACK
  // Add text to the display.
  display.text context 102 50 "Hello, World!"
  // Update display.
  display.draw
