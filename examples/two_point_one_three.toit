// Copyright (C) 2023 Toitware ApS.
// Use of this source code is governed by a Zero-Clause BSD license that can
// be found in the EXAMPLES_LICENSE file.

import font
import gpio
import serial.protocols.spi

import e_paper.waveshare_2_color_2_13 show *
import font_x11_adobe.sans_24_bold
import pixel_display show TwoColorPixelDisplay FourGrayPixelDisplay
import pixel_display.texture show TEXT_TEXTURE_ALIGN_CENTER
import pixel_display.four_gray
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

  two_color_example device reset busy

  sleep --ms=3000

  four_gray_example device reset busy

two_color_example device reset/gpio.Pin busy/gpio.Pin -> none:
  driver ::= Waveshare2Color213 device 104 212 --reset=reset --busy=busy --no-auto-reset --no-auto-initialize
  display := TwoColorPixelDisplay driver
  driver.reset
  driver.initialize

  display.background = two_color.BLACK

  // Create graphics context.
  context := display.context --landscape --font=big --alignment=TEXT_TEXTURE_ALIGN_CENTER --color=two_color.BLACK
  // Add text to the display.
  button := two_color.RoundedCornerWindow 16 8 180 88 context.transform 15 two_color.WHITE
  display.add button
  display.text context 106 50 "Hello"
  world := display.text context 106 80 "World!"
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

four_gray_example device reset/gpio.Pin busy/gpio.Pin -> none:
  driver ::= Waveshare2Color213 device 104 212
      --four_gray_mode
      --reset=reset
      --busy=busy
      --no-auto-reset
      --no-auto-initialize

  display := FourGrayPixelDisplay driver
  driver.reset
  driver.initialize

  display.background = four_gray.LIGHT_GRAY

  // Create graphics context.
  context := display.context --landscape --font=big --alignment=TEXT_TEXTURE_ALIGN_CENTER --color=four_gray.BLACK
  // Add text to the display.
  button := four_gray.SimpleWindow 16 8 180 88 context.transform 3 four_gray.DARK_GRAY four_gray.WHITE
  display.add button
  display.text context 106 50 "Hello"
  world := display.text context 106 80 "World!"
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
