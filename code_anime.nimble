# Package

version = "0.1.0"
author = "hamidb80"
description = "A new awesome nimble package"
license = "MIT"
srcDir = "src"


# Dependencies

requires "nim >= 1.4.2"
requires "ws >= 0.4.3"

# ----------------- tasls --------------------
import os, strutils

task start, "starts the app":
  let args = commandLineParams()

  try:
    let port = parseInt args[^1]
    exec "nim -d:ssl r src/main.nim " & $port
  
  except:
    echo "enter port"