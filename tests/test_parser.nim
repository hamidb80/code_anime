import unittest
import os

import parser

# import re, strutils
# proc remove_empty_lines(content: string): string =
#   for line in content.splitLines:
#     if not(line =~ re"\s+\n"):
#       result.add line

suite "parser":
  test "evalArgs::show":
    check evalArgs("show", @["name", "i"]) == "\"name:\",name,\"i:\",i"

  test "evalArgs::forget":
    check evalArgs("forget", @["name"]) == "\"name\""

  test "for loop 1":
    let
      nimCode = replaceWithCustomCode readfile "./tests/examples/for_loop1.nim"
      expected = readfile "./tests/examples/for_loop1.e.nim"

    check expected == nimCode
