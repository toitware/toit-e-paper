// Copyright (C) 2023 Toitware ApS.
// Use of this source code is governed by a Zero-Clause BSD license that can
// be found in the EXAMPLES_LICENSE file.

import font
import gpio
import spi

import e-paper.waveshare-gray-2-13d show *
import font-x11-adobe.sans-24-bold
import pixel-display show *
import pixel-display.four-gray
import pixel-display.two-color

big ::= font.Font [sans-24-bold.ASCII]

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
  busy := gpio.Pin.in BUSY --pull-down

  two-color-example device reset busy

  sleep --ms=3000

  four-gray-example device reset busy

two-color-example device reset/gpio.Pin busy/gpio.Pin -> none:
  driver ::= Waveshare2Color213D device 104 212 --reset=reset --busy=busy --no-auto-reset --no-auto-initialize
  display := PixelDisplay.two-color driver
  driver.reset
  driver.initialize

  display.background = two-color.BLACK

  // Add text to the display.
  window-style := Style
      --background = two-color.WHITE
      --border = RoundedCornerBorder --radius=15
  text-style := Style --color=two-color.BLACK --font=big {
      "alignment": ALIGN-CENTER,
  }
  display.add
      Div.clipping --x=16 --y=8 --w=180 --h=88 --style=window-style [
          Label --x=90 --y=42 --text="Hello" --style=text-style,
          Label --x=90 --y=72 --text="World!" --style=text-style --id="world",
      ]

  // Update display.
  duration := Duration.of:
    display.draw --speed=0

  print "Full update $duration"

  world/Label := display.get-element-by-id "world"
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

four-gray-example device reset/gpio.Pin busy/gpio.Pin -> none:
  driver ::= Waveshare2Color213D device 104 212
      --four-gray-mode
      --reset=reset
      --busy=busy
      --no-auto-reset
      --no-auto-initialize

  display := PixelDisplay.four-gray driver
  driver.reset
  driver.initialize

  display.background = four-gray.LIGHT-GRAY

  window-style := Style
      --background = four-gray.WHITE
      --border = SolidBorder --width=3 --color=four-gray.DARK-GRAY
  text-style := Style --color=four-gray.BLACK --font=big {
      "alignment": ALIGN-CENTER,
  }

  display.add
      Div.clipping --x=16 --y=8 --w=180 --h=88 --style=window-style [
          Label --x=90 --y=42 --text="Hello" --style=text-style,
          Label --x=90 --y=72 --text="World!" --style=text-style --id="world",
      ]
  world := display.get-element-by-id "world"

  // Update display.
  duration := Duration.of:
    display.draw --speed=0

  print "Full update $duration"

  world.text = "World"
  // Update display.
  duration = Duration.of:
    display.draw --speed=50

  print "50% update $duration"

  3.repeat:
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
