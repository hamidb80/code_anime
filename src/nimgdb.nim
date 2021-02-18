import osproc, streams

type
  TerminalInteractable* = object
    process: Process
    stdin: Stream
    stdout: Stream
    # stderr: Stream

using ti: TerminalInteractable

proc readLine*(ti): string =
  ti.stdout.readLine

proc writeLine*(ti; line_of_code: string) =
  ti.stdin.writeLine line_of_code
  ti.stdin.flush

# --------------------------------------------------------

proc newProcess(command: string, options: openArray[string]): Process {.inline.} =
  startProcess(command, "", options, nil, {poUsePath, poInteractive})

proc compileProgram*(nimFilePath: string): string =
  const finalFileName = "final_gdb_ized.out"

  let
    p = newProcess("nim",
      ["c", "--debugger:native", nimFilePath, "-o", finalFileName])

  discard waitForExit p # TODO check for error
  finalFileName

proc connect2nimgdb*(nimFilePath: string): TerminalInteractable =
  let
    p = newProcess("nim-gdb", [nimFilePath])

  TerminalInteractable(
    process: p,
    stdin: p.inputStream,
    stdout: p.outputStream)


# TODO 
proc getVars: seq[string]=
  result