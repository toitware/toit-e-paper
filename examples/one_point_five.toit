// Copyright (C) 2023 Toitware ApS.
// Use of this source code is governed by a Zero-Clause BSD license that can
// be found in the EXAMPLES_LICENSE file.

import e_paper.waveshare_2_color_1_54 show *

import font
import gpio
import spi

import e_paper.waveshare_2_color_1_54 show *
import font_x11_adobe.sans_24_bold
import pixel_display show *
import pixel_display.two_color show WHITE BLACK

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
  display := PixelDisplay.two-color --inverted driver
  driver.reset
  driver.initialize

  display.background = WHITE

  display.draw --speed=0

  sleep --ms=3000

  driver.reset

  display.background = BLACK

  // Create graphics context.
  label-style := Style --font=big --color=BLACK {
      "alignment": ALIGN-CENTER
  }
  window-style := Style
      --background=WHITE
      --border = RoundedCornerBorder --radius=15

  // Add text to the display.
  display.add
      Div.clipping --x=20 --y=50 --w=160 --h=100 --style=window-style [
          Label --x=80 --y=40 --label="Hello" --style=label-style,
          Label --x=80 --y=70 --label="World!" --style=label-style --id="world",
      ]

  // Update display.
  duration := Duration.of:
    display.draw --speed=0

  print "Full update $duration"

  driver.deep_sleep
  sleep --ms=1000
  driver.reset  // Wake up.

  world/Label := display.get-element-by-id "world"

  world.label = "World"
  // Update display.
  duration = Duration.of:
    display.draw --speed=50

  print "50% update $duration"

  10.repeat:
    world.label = it.stringify
    // Update display.
    duration = Duration.of:
      display.draw --speed=100

    print "100% update $duration"

  world.label = "everyone"
  // Update display.
  duration = Duration.of:
    display.draw --speed=5

  print "5% update $duration"
