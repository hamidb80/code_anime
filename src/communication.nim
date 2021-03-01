type
  Message* = tuple[command: string, data: string]

var 
  termCh*: Channel[Message]
  wsCh*: Channel[Message]

termCh.open
wsCh.open

