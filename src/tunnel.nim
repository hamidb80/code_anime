import osproc, streams
import sugar

type
  TerminalInteractable* = object
    process: Process
    stdin: Stream
    stdout: Stream
    # stderr: Stream
    onStdout: proc(line: string): void

using ti: TerminalInteractable

proc readLine*(ti): string =
  ti.stdout.readLine

proc writeLine*(ti; line_of_code: string) =
  ti.stdin.writeLine line_of_code
  ti.stdin.flush

proc `onStdout=`*(ti; handler: (line: string) -> void) =
  try:
    while true:
      handler ti.readLine
  except:
    discard

proc terminate*(ti; ) =
  ti.process.terminate
# --------------------------------------------------------

proc newProcess*(command: string; options: openArray[string] = []): Process {.inline.} =
  startProcess(command, "", options, nil, {poUsePath, poInteractive})

proc newTerminal*(command: string; options: openArray[string] = []): TerminalInteractable =
  let p = newProcess(command, options)

  TerminalInteractable(
    process: p,
    stdin: p.inputStream,
    stdout: p.outputStream)

proc compileNimProgram*(nimFilePath: string; outputFilePath: string): string =
  let p = newProcess("nim", ["c", nimFilePath, "-o", outputFilePath])

  discard waitForExit p # TODO check for error
  outputFilePath

proc runNimApp*(runnableFilePath: string): TerminalInteractable {.inline.} =
  newTerminal("./" & runnableFilePath)
