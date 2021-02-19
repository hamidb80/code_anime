import nre except toSeq
import strformat, strutils
import sequtils 

type Funcs = enum
  fshow = "show"
  fforget = "forget"

proc contains(en: type Funcs, str: string): bool = 
  for n in low(en) .. high(en):
    if $n == str:
      return true

func evalArgs(funcname: string, args: seq[string]): seq[string] =
  case funcname:
    of $fshow:
      discard "eval their args, also send args with thier values-json like"

    of $fforget:
      discard

  args

# were gonna match all the comments like that #!\w+
func replaceWithCustomCode(nimFileContent: string): string =

  func doReplace(m: RegexMatch): string =
    var
      funcname = m.captures[0]
      args_seq = m.captures[1].split(',').mapIt(it.strip)

    if funcname in Funcs:
      args_seq = evalArgs(funcname, args_seq)
      funcname = fmt"""debugEcho "::FROM_CODE_ANIME::{funcname} ","""

    elif funcname == "sleep":
      assert args_seq.len == 1
      args_seq = @[args_seq[0]]

    else:
      raise newException(ValueError, fmt"'{funcname}' does not defiend")

    let args_str = '"' & (args_seq.join ",") & '"'
    fmt"{funcname} {args_str}"


  nimFileContent.replace(re"#!(\w+) (.+)", doReplace)

echo replaceWithCustomCode(
"""
for i in 0 ..< 10:  
  let n = i+1
  #!show i, n

  #!sleep 100
  echo fmt"index {i} gonna be {n}"

#!forget i,n
"""
)
