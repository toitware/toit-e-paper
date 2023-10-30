// Copyright (C) 2023 Toitware ApS.
// Use of this source code is governed by a Zero-Clause BSD license that can
// be found in the EXAMPLES_LICENSE file.

import e_paper.waveshare_2_color_1_54 show *

import font
import gpio
import serial.protocols.spi

import e_paper.waveshare_2_color_1_54 show *
import font_x11_adobe.sans_24_bold
import pixel_display show TwoColorPixelDisplay
import pixel_display.texture show TEXT_TEXTURE_ALIGN_CENTER
import pixel_display.two_color show TextTexture WHITE BLACK
import pixel_display.two_color

big ::= font.Font [sans_24_bold.ASCII]

main:
  BUSY ::= 5
  RESET ::= 18
  DC ::= 19
  CS ::= 23
  CLOCK ::= 22
  DIN ::= 21
  bus := spi.Bus
    --mosi=gpio.Pin DIN
    --clock=gpio.Pin CLOCK

  device := bus.device
    --cs=gpio.Pin CS
    --dc=gpio.Pin DC
    --frequency=20_000_000

  reset := gpio.Pin.out RESET
  busy := gpio.Pin.in BUSY --pull_down

  driver ::= Waveshare2Color154 device --reset=reset --busy=busy --no-auto-reset --no-auto-initialize
  display := TwoColorPixelDisplay driver
  driver.reset
  driver.initialize

  display.background = WHITE

  display.draw --speed=0

  sleep --ms=5000

  driver.deep_sleep

  display.background = BLACK

  // Create graphics context.
  context := display.context --landscape --inverted --font=big --alignment=TEXT_TEXTURE_ALIGN_CENTER --color=BLACK
  // Add text to the display.
  button := two_color.RoundedCornerWindow 20 50 160 100 context.transform 15 WHITE
  display.add button
  display.text context 100 90 "Hello"
  world := display.text context 100 120 "World!"
  // Update display.
  duration := Duration.of:
    display.draw --speed=0

  print "Full update $duration"

  world.text = "World"
  // Update display.
  duration = Duration.of:
    display.draw --speed=50

  print "50% update $duration"

  10.repeat:
    world.text = it.stringify
    // Update display.
    duration = Duration.of:
      display.draw --speed=100

    print "100% update $duration"

  world.text = "everyone"
  // Update display.
  duration = Duration.of:
    display.draw --speed=5

  print "5% update $duration"
