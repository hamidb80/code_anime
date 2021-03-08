import
  asyncdispatch, asynchttpserver,
  ws
import communication

proc wsDispatch(req: Request) {.async, gcsafe.} =
  try:
    let thisClient = await newWebSocket req

    {.cast(gcsafe).}:
      wsClients.add thisClient

      while thisClient.readyState == Open:
        let msg = await thisClient.receiveStrPacket

        if msg == "": continue # ws handshake :-|
        try: msgBridge msg
        except:
          await thisClient.send "ERROR:" & getCurrentExceptionMsg()

  except WebSocketError:
    echo "Socket Closed"
proc httpDispatch*(req: Request): Future[void] {.async, gcsafe.} =
  if req.url.path == "/ws":
    await wsDispatch req

  elif req.url.path == "/":
    await req.respond(Http200, "Welcome")

  else:
    await req.respond(Http404, "Not Found")
