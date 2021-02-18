import asyncdispatch, asynchttpserver
import strutils, strformat
import os

import router


proc main =
  let
    port = paramStr(1).parseInt
    server = newAsyncHttpServer()

  echo fmt"is running on http://localhost:{port}/"

  waitFor server.serve(Port(port), dispatch)

if isMainModule:
  main()
