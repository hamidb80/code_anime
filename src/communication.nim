import
  asyncdispatch,
  options,
  os,
  strutils

import ws
import tunnel

type
  Message* = tuple[command: string, data: string]
 
const AppDelay = 10 # per ms

var
  termCh*: Channel[Message]
  wsCh*: Channel[Message]
  wsClients*: seq[WebSocket]

const compiledFilePath* = "./temp/finalizedApp.out"

# ---------- init --------------

termCh.open
wsCh.open

# ---------------------------------

template asyncLoop*(body: untyped) =
  while true:
    body
    await sleepAsync AppDelay

template threadLoop*(body: untyped) =
  while true:
    body
    sleep AppDelay

# ------------------------------------------

proc sendToAll*(msg: Message){.async.} =
  for cs in wsClients:
    {.cast(gcsafe).}:
      await cs.send $msg

proc wsChannel_handler*(){.async.} =
  asyncLoop:
    let (ok, msg) = wsCh.tryRecv
    if ok: 
      await sendToAll msg

# -----------------------------------------

func unpackMsg(msg: string): Message {.inline.} =
  let ci = msg.find ':' # colon index
  assert ci != -1

  (msg[0..<ci].strip, msg[(ci+1)..msg.high].strip)

proc msgBridge*(msg: string) =
  termCh.send(unpackMsg msg)

proc termChannel_handler*(){.thread.} =
  var term: Option[InteractableTerminal]

  template initTerminal(it: InteractableTerminal)=
    term = some it
    term.get.onStdout = proc(s: string) = wsCh.send ("stdout", s)

  threadLoop:
    let (ok, msg) = termCh.tryRecv

    if not ok: continue
    try:
      case msg.command:

      of "hey":
        wsCh.send ("hello", msg.data)

      of "setFilePath":
        compileNimProgram(msg.data, compiledFilePath)
        assert fileExists compiledFilePath

        initTerminal runApp compiledFilePath

      of "runCommand":
        let splitted_command = msg.data.splitWhitespace
        let
          command = splitted_command[0]
          args = splitted_command[1..^1]

        initTerminal newTerminal(command, args)

      elif isSome(term) and not term.get.isDead:
        case msg.command:
        
        of "sendInput": # TODO: make it work for multiline input
          term.get.writeLine msg.data

        of "terminate":
          term.get.terminate
      
      else:
        raise newException(ValueError, "The process is dead")

    except:
      wsCh.send ("Error", getCurrentExceptionMsg())