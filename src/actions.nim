import threadpool, options

import parser, tunnel, communication

# type
#   msgErrs = enum
#     invalid_input = "invalid input"
#     not_running = "no program is running"

#   msgKinds = enum
#     setFilePath = "setFilePath"
#     sendInput = "sendInput"


func unpackMsg(msg: string): Message {.inline.}=
  let ci = msg.find(':') # colon index
  assert ci != -1

  (msg[0..<ci], msg[(ci+1)..msg.high])

proc msgHandler*(ch: var Channel[Message], msg: string) =
  let (command, data) = unpackMsg(msg)

  case command:
  of "setFilePath":
    const outFilename = "./temp.nim"
    writeFile(outFilename, replaceWithCustomCode readFile data)

    ch.send (command, data)

  of "sendInput":
    ch.send (command, data)

const finalFileName* = "finalizedApp.out"

proc terminalController(msg: Message){.thread.}=
  var ti: Option[TerminalInteractable]

  while true:
    let msg = ch.recv

    if msg.command == "setFilePath":
      ti = some runNimApp compileNimProgram(msg.data, finalFileName)
    
    elif msg.command == "sendInput":
      if isSome ti:
        ti.get.writeLine msg.data
        echo "ehys"
    
    else:
      discard