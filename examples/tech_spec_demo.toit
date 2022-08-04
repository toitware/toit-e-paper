// Copyright (C) 2020 Toitware ApS. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

import peripherals.led show *
import peripherals.touch show *
import peripherals.thp show *
import pixel_display show *

import font show *
import font_adobe.sans_18_bold
import pixel_display.texture show *
import pixel_display.two_color show *

import .get_driver

sans ::= Font.get "sans10"
sans_18 ::= Font [sans_18_bold.ASCII, sans_18_bold.LATIN_1_SUPPLEMENT]
logo ::= Font.get "logo"
driver ::= get_driver
display ::= TwoColorPixelDisplay driver

write text:
  display.remove_all
  display.add
    TextTexture 112 60 display.landscape TEXT_TEXTURE_ALIGN_CENTER text sans_18 BLACK
  draw

write_with_logo text:
  display.remove_all
  display.add
    TextTexture 112 85 display.landscape TEXT_TEXTURE_ALIGN_CENTER text sans BLACK
  display.add
    TextTexture 112 60 display.landscape TEXT_TEXTURE_ALIGN_CENTER "A" logo BLACK
  draw

clear:
  display.remove_all
  draw

draw:
  display.draw
  display.draw


leds := null

leds_on:
  leds.do: it.on

leds_off:
  leds.do: it.off

flash_leds --ms=1000:
  leds_on
  sleep --ms=ms
  leds_off

main:
  leds = Led.names.map: Led it
  leds_off
  display.remove_all
  display.draw --speed=0

  touch := Touch.start

  flash_leds --ms=100
  print "ready"

  touch.listen: | button/string event/int |
    if event != Touch.EVENT_TYPE_UP:
      continue.listen

    if button == "TOP LEFT":
      flash_leds
    else if button == "BOTTOM LEFT":
      temp := read_temperature
      write "$(%2.2f temp)°C"
    else if button == "TOP RIGHT":
      t := Time.now.utc
      write "$(%02d t.h):$(%02d t.m):$(%02d t.s)"
    else if button == "BOTTOM RIGHT":
      write_with_logo "Just add batteries..."
