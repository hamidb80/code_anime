import strutils

import
  parser,
  communication

const outFilename = "./temp.o"

func unpackMsg(msg: string): Message {.inline.} =
  let ci = msg.find(':') # colon index
  assert ci != -1

  (msg[0..<ci].strip, msg[(ci+1)..msg.high].strip)

proc msgBridge*(msg: string) =
  var (command, data) = unpackMsg msg

  case command:
  of $Mk.setFilePath:
    writeFile(outFilename, replaceWithCustomCode readFile data)
    data = outFilename

  of $Mk.sendInput:
    discard

  termCh.send (command, data)
