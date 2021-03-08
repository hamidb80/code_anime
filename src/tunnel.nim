import
  osproc, streams,
  threadpool,
  strutils

type
  InteractableTerminal* = object
    process: Process
    stdin: Stream
    stdout: Stream
    # stderr: Stream
    onStdout: proc(line: string): void

# ------------------ InteractableTerminal -----------------

using term: InteractableTerminal

proc readLine*(term): string =
  term.stdout.readLine
proc readAll*(term): string =
  term.stdout.readAll
proc writeLine*(term; line: string) =
  term.stdin.writeLine line
  term.stdin.flush
proc outputLoopWrapper(term; handler: proc(line: string)) =
  try:
    while true:
      handler term.readLine

  except: discard
proc `onStdout=`*(term; handler: proc(line: string)) =
  spawn outputLoopWrapper(term, handler)
proc isDead*(term): bool =
  term.process.peekExitCode != -1
proc terminate*(term) =
  term.process.terminate

# ---------------- other functionalities --------------------------

proc newProcess(command: string; options: openArray[string] = []): Process {.inline.} =
  startProcess(command, "", options, nil, {poUsePath, poInteractive})
proc newTerminal*(command: string; options: openArray[string] = []): InteractableTerminal =
  let p = newProcess(command, options)

  InteractableTerminal(
    process: p,
    stdin: p.inputStream,
    stdout: p.outputStream)
proc compileNimProgram*(nimFilePath: string; outputFilePath: string) =
  let p = newProcess("nim", ["c", "-o:"&outputFilePath, nimFilePath])
  discard waitForExit p

  if p.peekExitCode != 0:
    raise newException(ValueError, "error during compilation of " & nimFilePath)
proc runApp*(runnableFilePath: string): InteractableTerminal {.inline.} =
  newTerminal((if runnableFilePath.startsWith "./": "" else: "./") & runnableFilePath)
