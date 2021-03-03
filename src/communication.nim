import 
  asyncdispatch,
  options, 
  os,
  strformat

import ws

import tunnel

type
  Message* = tuple[command: string, data: string]

var 
  termCh*: Channel[Message]
  wsCh*: Channel[Message]

termCh.open
wsCh.open

const AppDelay = 10 # per ms

var wsClients*: seq[WebSocket]

const finalFileName* = "finalizedApp.out"

# ---------------------------------

template asyncLoop*(body:untyped)=
  while true:
    body
    await sleepAsync AppDelay

template threadLoop*(body:untyped)=
  while true:
    body
    sleep AppDelay

# ------------------------------------------

func `$`(msg: Message):string =
  fmt"{msg.command}: {msg.data}"

proc sendToAll*(msg: Message){.async.}=
  for cs in wsClients:
    {.cast(gcsafe).}:
      await cs.send $msg

proc wsChannel_handler*(){.async.} =
  asyncLoop:
    let (ok, msg) = wsCh.tryRecv
      
    if ok:
      await sendToAll msg

proc termChannel_handler*(){.thread.} =
  var term: Option[InteractableTerminal]

  threadLoop:
    let (command, data) = termCh.recv

    if command == "hey":
      wsCh.send ("hello", data)

    elif command == "setFilePath":
      term = some runNimApp compileNimProgram(data, finalFileName)
      term.get.onStdout = proc(s:string)= wsCh.send ("stdout", s)

    elif isSome term:
      case command:
      
      of "sendInput":
        if isSome term:
          term.get.writeLine data

    else:
      wsCh.send ("error", "400")