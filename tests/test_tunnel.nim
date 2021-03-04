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


  test "compile & run .nim":
    let finalFileName = "./temp/a.out"
    compileNimProgram("./tests/examples/sample.nim", finalFileName)

    term = runApp finalFileName
    check term.readAll.strip == "sample"