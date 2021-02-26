import asyncdispatch, asynchttpserver, ws

import actions, communication

proc wsDispatch(req: Request) {.async, gcsafe.} =
  try:
    let userws = await newWebSocket req

    while userws.readyState == Open:
      let msg = await userws.receiveStrPacket()  
      var resp: string
      try:
        ch.msgHandler msg
        resp = "OK"
      except:
        resp = "ERROR"

      await userws.send resp

  except WebSocketError:
    echo "Socket Closed"

proc httpDispatch*(req: Request): Future[void] {.async, gcsafe.} =
  if req.url.path == "/ws":
    await wsDispatch req

  elif req.url.path == "/":
    await req.respond(Http200, "Welcome")
    
  else:
    await req.respond(Http404, "Not Found")
