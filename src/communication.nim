type
  Message* = tuple[
    command: string, data: string]

var termCh*: Channel[Message]
var wsCh*: Channel[Message]

termCh.open
wsCh.open
