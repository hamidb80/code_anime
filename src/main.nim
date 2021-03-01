import asyncdispatch, asynchttpserver, threadpool
import strutils, strformat
import os

import router, actions

proc runServer*(p: int) =
  let server = newAsyncHttpServer()

  spawn terminal_websocket_bridge()
  asyncCheck websocket_channel_wrapper()
  waitFor server.serve(p.Port, httpDispatch)

proc main =
  let port = paramStr(1).parseInt

  echo fmt"is running on http://localhost:{port}/"
  runServer(port)

if isMainModule:
  main()
