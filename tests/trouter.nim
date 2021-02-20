import unittest
import router

suite "routers":
  discard  
  test "send input":
    check((msgHandler "sendInput: 1,2,3") == "OK")
