// Copyright (C) 2020 Toitware ApS. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

// This program will prints if the device is moved.

import peripherals show Accelerometer
import math
import job
import font
import pixel_display show TwoColorPixelDisplay
import pixel_display.texture show TEXT_TEXTURE_ALIGN_CENTER
import pixel_display.two_color show TextTexture WHITE BLACK

import .get_driver

sans ::= font.Font.get "sans10"

class MovementRegulator:
  static THRESHOLD ::= 0.04 /* g */

  limit ::= ?
  max_value ::= ?
  value := 0

  constructor .limit/int=20 .max_value/int=30:

  register f/float:
    if (1 - f).abs > THRESHOLD:
      value -= min 5 value
    else if value < max_value:
      value++

  is_still -> bool:
    return value >= limit

main:
  movement_detection

movement_detection:
  screen "Movement triggered" --with_time
  try:
    regulator := MovementRegulator
    acc := Accelerometer.start
    try:
      print "started"
      while not regulator.is_still:
        m := movement acc
        regulator.register m
        sleep --ms=100
    finally:
      acc.close
  finally:
    screen "Shake to wake!"

// Uses limit*25ms to detect if the device has been moved.
movement acc/Accelerometer -> float:
  limit := 25
  points := []
  limit.repeat:
    points.add
      acc.read.length
    sleep --ms=10
  return mean points

mean points/List/*<float>*/ -> float:
  sum := points.reduce --initial=0.0: | acc/float p/float |
    acc + p
  return sum / points.size

screen text/string --with_time/bool=false:
  driver := get_driver
  // Create graphics context.
  display ::= TwoColorPixelDisplay driver
  try:
    context := display.context --landscape --font=sans --alignment=TEXT_TEXTURE_ALIGN_CENTER --color=BLACK
    // Add text to the display.
    display.text context 102 50 text
    if with_time:
      display.text context 102 90 "$Time.now"
    // Update display.
    display.draw
  finally:
    display.close
