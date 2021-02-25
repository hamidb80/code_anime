import unittest
import os
import strutils
import sugar

import tunnel

suite "tunnel":
  var ti: TerminalInteractable

  template runPython(filePath: string) =
    ti = newTerminal("python3.8", [filePath])

  setup:
    discard
  teardown:
    ti.terminate

  test "simple i/o":
    runPython "./tests/scripts/ex.py"
    check ti.readLine.strip == "enter your name:"

    ti.writeLine "hamid"
    check ti.readLine.strip == "hello hamid"

  test "stdout event handler":
    runPython "./tests/scripts/loop.py"

    var outs: seq[string]
    ti.onStdout = (s: string) => outs.add(s.strip)

    sleep 500
    check outs == @["0", "1", "2", "3"]
