import 
  parser,
  communication

const outFilename = "./temp.nim"

func unpackMsg(msg: string): Message {.inline.} =
  let ci = msg.find(':') # colon index
  assert ci != -1

  (msg[0..<ci], msg[(ci+1)..msg.high])

proc msgHandler*(msg: string) =
  let (command, data) = unpackMsg msg

  case command:
  of "setFilePath":
    writeFile(outFilename, replaceWithCustomCode readFile data)
    # termCh.send ("setFilePath", data)

  of "sendInput":
    # termCh.send ("input", data)
    discard

  termCh.send (command, data)