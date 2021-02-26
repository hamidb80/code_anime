type
  Message* = tuple[
    command: string, data: string
  ] 

var ch*: Channel[Message]
ch.open