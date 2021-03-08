import
  asyncdispatch, asynchttpserver, threadpool,
  strutils, strformat,
  os
import router, communication

proc runServer*(port: int) =
  let server = newAsyncHttpServer()

  spawn termChannelHandler()
  asyncCheck wsChannelHandler()
  waitFor server.serve(port.Port, httpDispatch)

if isMainModule:
  if paramCount() != 1:
    echo "enter port"

  else:
    let port = paramStr(1).parseInt
    echo fmt"is running on http://localhost:{port}/"
    runServer port