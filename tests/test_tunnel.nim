import
  unittest,
  os,
  strutils,
  sugar

import tunnel

suite "tunnel":
  var term: InteractableTerminal

  template runPython(filePath: string) =
    term = newTerminal("python3.8", [filePath])

  # for each test
  setup: discard
  teardown: term.terminate

  test "simple i/o":
    runPython "./tests/scripts/ex.py"
    check term.readLine.strip == "enter your name:"

    term.writeLine "hamid"
    check term.readLine.strip == "hello hamid"

  test "stdout event handler":
    runPython "./tests/scripts/loop.py"

    var outs: seq[string]
    term.onStdout = (s: string) => outs.add(s.strip)

    sleep 500
    check outs == @["0", "1", "2", "3"]
