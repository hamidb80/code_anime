import asyncdispatch, asynchttpserver, ws
import strutils
import options, os

import parser, tunnel

const finalFileName* = "finalizedApp.out"
var ti: Option[TerminalInteractable]

type
  msgErrs = enum
    invalid_input = "invalid input"
    not_running = "no program is running"

func unpackMsg(msg: string): tuple[command: string, data: string] =
  let ci = msg.find(':') # colon index
  assert ci != -1

  (msg[0..^ci], msg[(ci+1)..msg.high])


proc msgHandler*(msg: string): string =
  let parsedMsg = unpackMsg(msg)

  result = "OK"
  template wsErr(err: string): string =
    "ERR::" & err

  case parsedMsg.command:
  of "setFilePath":
    const outFilename = "./temp.nim"
    writeFile(outFilename, replaceWithCustomCode readFile parsedMsg.data)

    ti = some runNimApp compileNimProgram(finalFileName, outFilename)

  of "sendInput":
    if isSome ti:
      ti.get.writeLine parsedMsg.data
    else:
      result = wsErr $not_running

  else:
    result = wsErr $invalid_input

# ---------------------- dispachers ------------------------

proc wsDispatch*(req: Request) {.async, gcsafe.} =
  try:
    let userws = await newWebSocket(req)

    while userws.readyState == Open:
      let msg = await userws.receiveStrPacket()
      let output = msgHandler msg

      await userws.send output

  except WebSocketError:
    echo "Socket Closed"

proc httpDispatch*(req: Request): Future[void] {.async, gcsafe.} =
  var userws: WebSocket

  if req.url.path == "/ws":
    await wsDispatch req

  elif req.url.path == "/":
    await req.respond(Http200, "Welcome")

  else:
    await req.respond(Http404, "Not Found")
