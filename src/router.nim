import
  asyncdispatch, asynchttpserver,
  ws

import actions

proc wsDispatch(req: Request) {.async, gcsafe.} =
  try:
    var clientWs = await newWebSocket req

    while clientWs.readyState == Open:
      let msg = await clientWs.receiveStrPacket()

      if msg == "": continue
      try:
        msgHandler msg
      except:
        await clientWs.send "ERROR" & $msg.len

  except WebSocketError:
    echo "Socket Closed"


proc httpDispatch*(req: Request): Future[void] {.async, gcsafe.} =
  if req.url.path == "/ws":
    await wsDispatch req

  elif req.url.path == "/":
    await req.respond(Http200, "Welcome")

  else:
    await req.respond(Http404, "Not Found")