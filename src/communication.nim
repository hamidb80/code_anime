import
  asyncdispatch,
  options,
  os,
  strformat, strutils

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

const finalFileName* = "finalizedApp.out"

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

func `$`(msg: Message): string =
  fmt"{msg.command}: {msg.data}"

proc sendToAll*(msg: Message){.async.} =
  for cs in wsClients:
    {.cast(gcsafe).}:
      await cs.send $msg

proc wsChannel_handler*(){.async.} =
  asyncLoop:
    let (ok, msg) = wsCh.tryRecv

    if ok: await sendToAll msg

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
    let (command, data) = termCh.recv

    try:
      case command:
      of $Mk.hey:
        wsCh.send ("hello", data)

      of $Mk.setFilePath:
        term = some runApp compileNimProgram(data, finalFileName)
        term.get.onStdout = proc(s: string) = wsCh.send ("stdout", s)

      of $Mk.runCommand:
        let splitted_command = data.splitWhitespace
        let
          first = splitted_command[0]
          others = splitted_command[1..^1]

        let prc = newTerminal(first, others)

        wsCh.send ("output", prc.readLine)

      elif isSome term:
        case command:

        of $Mk.sendInput:
          term.get.writeLine data

      else: sayErr
    except: sayErr