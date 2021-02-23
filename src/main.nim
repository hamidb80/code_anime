import asyncdispatch, asynchttpserver, ws
import strutils, strformat
import os

import router

proc runWsServer*(p: int) =
  let server = newAsyncHttpServer()
  waitFor server.serve(p.Port, httpDispatch)

proc main =
  let port = paramStr(1).parseInt

  echo fmt"is running on http://localhost:{port}/"
  runWsServer(port)

if isMainModule:
  main()
