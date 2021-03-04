import
  asyncdispatch,
  options,
  os,
  strutils

import ws
import tunnel

type
  Message* = tuple[command: string, data: string]

  Mk* = enum # message kinds
    setFilePath = "setFilePath"
    sendInput = "sendInput"
    runCommand = "runCommand"
    hey = "hey"

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

    if ok: await sendToAll msg

# -----------------------------------------

func unpackMsg(msg: string): Message {.inline.} =
  let ci = msg.find ':' # colon index
  assert ci != -1

  (msg[0..<ci].strip, msg[(ci+1)..msg.high].strip)

proc msgBridge*(msg: string) =
  termCh.send(unpackMsg msg)

proc termChannel_handler*(){.thread.} =
  var term: Option[InteractableTerminal]

  template sayErr=
    wsCh.send ("error", getCurrentExceptionMsg())

  threadLoop:
    let (ok, msg) = termCh.tryRecv

    if not ok: continue
    try:
      case msg.command:
      of $Mk.hey:
        wsCh.send ("hello", msg.data)

      of $Mk.setFilePath:
        compileNimProgram(msg.data, compiledFilePath)

        assert fileExists compiledFilePath

        term = some runApp compiledFilePath
        term.get.onStdout = proc(s: string) = wsCh.send ("stdout", s)

      of $Mk.runCommand:
        let splitted_command = msg.data.splitWhitespace
        let
          command = splitted_command[0]
          args = splitted_command[1..^1]

        let prc = newTerminal(command, args)

        wsCh.send ("stdout", prc.readLine)

      elif isSome term:
        case msg.command:
        of $Mk.sendInput:
          term.get.writeLine msg.data

      else: sayErr
    except: sayErr