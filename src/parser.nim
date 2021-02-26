import nre except toSeq
import strformat, strutils
import sequtils

const EchoSigniture = "::CODE_ANIME::"

type Funcs = enum
  fshow = "show"
  fforget = "forget"

func contains(en: type Funcs, str: string): bool =
  for n in low(en) .. high(en):
    if $n == str:
      return true

func evalArgs*(funcname: string, args: seq[string]): string =
  var new_arg_seq: seq[string]

  case funcname:
  of $fshow:
    # eval their args, also send args with thier values-json like
    # ["i", "n"] => """  "i",i,  "n",n """
    new_arg_seq = args.mapIt(&"\"{it}:\",{it}")

  of $fforget:
    new_arg_seq = args.mapIt(&"\"{it}\"")

  new_arg_seq.join ","

# were gonna match all the comments like that #!\w+
func replaceWithCustomCode*(nimFileContent: string): string =

  func doReplace(m: RegexMatch): string =
    var
      funcname = m.captures[0]
      args_seq = m.captures[1].split(',').mapIt(it.strip)
      args_str = ""

    if funcname in Funcs:
      args_str = evalArgs(funcname, args_seq)
      funcname = &"debugEcho \"{EchoSigniture}{funcname}::\","

    elif funcname == "sleep":
      assert args_seq.len == 1
      args_str = args_seq[0]

    else:
      raise newException(ValueError, &"'{funcname}' has not defiend")

    fmt"{funcname} {args_str}"


  nimFileContent.replace(re"#!(\w+) (.+)", doReplace)
