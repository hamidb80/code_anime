import asyncdispatch
import options
import ws
import parser, tunnel, communication


func unpackMsg(msg: string): Message {.inline.} =
  let ci = msg.find(':') # colon index
  assert ci != -1

  (msg[0..<ci], msg[(ci+1)..msg.high])

proc msgHandler*(msg: string) =
  let (command, data) = unpackMsg msg

  case command:
  of "setFilePath":
    const outFilename = "./temp.nim"
    writeFile(outFilename, replaceWithCustomCode readFile data)
    # ch.send (command, data)

  of "sendInput":
    # ch.send (command, data)
    discard

  termCh.send (command, data)

const finalFileName* = "finalizedApp.out"

proc websocket_channel_wrapper*(wsclient:ptr WebSocket){.thread.} =
  while true:
    let (_, data) = wsCh.recv
    waitFor wsclient[].send data


proc terminal_websocket_bridge*(){.thread.} =
  var term: Option[InteractableTerminal]

  while true:
    let (command, data) = termCh.recv

    case command:
    of "setFilePath":
      term = some runNimApp compileNimProgram(data, finalFileName)

    of "sendInput":
      if isSome term:
        term.get.writeLine data

    of "hey":
      wsCh.send ("hello", data)

    else:
      discard
