import osproc, streams
import threadpool

type
  InteractableTerminal* = object
    process: Process
    stdin: Stream
    stdout: Stream
    # stderr: Stream
    onStdout: proc(line: string): void

using term: InteractableTerminal

proc readLine*(term): string =
  term.stdout.readLine

proc writeLine*(term; line_of_code: string) =
  term.stdin.writeLine line_of_code
  term.stdin.flush

proc outputLoopWrapper(term; handler: proc(line: string)) =
  try:
    while true:
      handler term.readLine
  except:
    discard

proc `onStdout=`*(term; handler: proc(line: string)) =
  spawn outputLoopWrapper(term, handler)

proc terminate*(term) =
  term.process.terminate

# --------------------------------------------------------

proc newProcess*(command: string; options: openArray[string] = []): Process {.inline.} =
  startProcess(command, "", options, nil, {poUsePath, poInteractive})

proc newTerminal*(command: string; options: openArray[string] = []): InteractableTerminal =
  let p = newProcess(command, options)

  InteractableTerminal(
    process: p,
    stdin: p.inputStream,
    stdout: p.outputStream)

proc compileNimProgram*(nimFilePath: string; outputFilePath: string): string =
  let p = newProcess("nim", ["c", nimFilePath, "-o", outputFilePath])

  discard waitForExit p # TODO check for error
  outputFilePath

proc runNimApp*(runnableFilePath: string): InteractableTerminal {.inline.} =
  newTerminal("./" & runnableFilePath)
