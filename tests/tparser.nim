import unittest
import re, strutils

import parser

proc remove_empty_lines(content:string): string=
  for line in content.splitLines:
    if not(line =~ re"\s+\n"):
      result.add line

suite "parser":
  setup:
    discard
  teardown:
    discard

  # test "for loop 1":
  #   let
  #     nimCode = replaceWithCustomCode readfile "./examples/for_loop1.nim"
  #     expected = readfile "./examples/for_loop1.e.nim"

  #   check remove_empty_lines(expected) == remove_empty_lines(nimCode)
