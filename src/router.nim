import asyncdispatch, asynchttpserver, ws
import strutils
import os, options

import parser
import tunnel

var ti: Option[TerminalInteractable]

type msgErrs = enum
  invalid_input = "invalid input"
  not_running = "no program is running"

proc msgHandler*(msg: string): string {.inline, gcsafe.}=
  let ci = msg.find(':') # colon index
  let command = msg[0..^ci]
  let data = msg[(ci+1)..msg.high]

  template wsErr(err: string): string =
    "ERR::" & err

  {.cast(gcsafe).}:

    case command:
    of "setFilePath":
      const outFilename = "./temp.nim"
      writeFile(outFilename, replaceWithCustomCode readFile data)

      ti = some runNimApp compileProgram outFilename
      
      result = "OK"

    of "sendInput":
      if isSome ti:
        ti.get.writeLine data
      else:
        result = wsErr $not_running

    else:
      result = wsErr $invalid_input


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
