import asyncdispatch, asynchttpserver
import ws
import strutils


proc dispatch*(req: Request): Future[void] {.async, gcsafe.} =
  var userws: WebSocket
  # await userws.send(msg)

  if req.url.path == "/ws":
    try:
      userws = await newWebSocket(req)

      while userws.readyState == Open:
        let msg = await userws.receiveStrPacket()

        if msg.startsWith "setFilePath":
          discard

        elif msg.startsWith "sendInput":
          discard

        else:
          discard "unacceptable input"


    except WebSocketError:
      echo "socket closed:"

  elif req.url.path == "/":
    await req.respond(Http200, "welcome")

  else:
    await req.respond(Http404, "Not found")
