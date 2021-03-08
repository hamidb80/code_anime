import nre except toSeq
import strformat, strutils, sequtils
import shared

type Funcs = enum
  fnew = "new"
  fforget = "forget"
  fshow = "show"
  fsleep = "sleep"
func contains(en: type Funcs, str: string): bool =
  for n in low(en) .. high(en):
    if $n == str:
      return true

func evalArgs*(funcname: string, args: seq[string]): string =
  var new_arg_seq: seq[string]

  case funcname:
  of $fshow:
    ## eval their args, also send args with thier values-json like
    ## ["i", "n"] => """  "i",i,  "n",n """
    new_arg_seq = args.mapIt(&"\"{it}:\",{it}")
  of $fforget:
    new_arg_seq = args.mapIt(&"\"{it}\"")

  new_arg_seq.join ","
func doReplace(m: RegexMatch): string =
  var
    funcname = m.captures[0]
    args_seq = m.captures[1].split(',').mapIt(it.strip)
    args_str = ""

  if funcname == $fsleep:
    assert args_seq.len == 1
    args_str = args_seq[0]
  elif funcname in Funcs:
    args_str = evalArgs(funcname, args_seq)
    funcname = &"debugEcho \"{EchoSigniture}{funcname}::\","
  else:
    raise newException(ValueError, &"'{funcname}' has not defiend")

  fmt"{funcname} {args_str}"
func replaceWithCustomCode*(nimFileContent: string): string =
  ## were gonna match all the comments like that #!\w+
  nimFileContent.replace(re"#!(\w+) (.+)", doReplace)
