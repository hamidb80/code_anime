# This is just an example to get you started. You may wish to put all of your
# tests into a single file, or separate them into multiple `test1`, `test2`
# etc. files (better names are recommended, just make sure the name starts with
# the letter 't').
#
# To run these tests, simply execute `nimble test`.

import unittest
import parser

suite "parser":
  # echo "started"
  
  setup:
    echo "run before each test"
  
  teardown:
    echo "run after each test"
  
  
  test "essential truths":
    # give up and stop if this fails
    require(true)
  
  test "slightly less obvious stuff":
    # print a nasty message and move on, skipping
    # the remainder of this block
    check("asd"[2] == 'd')
  
  test "out of bounds error is thrown on bad access":
    let v = @[1, 2, 3]  # you can do initialization here
    
    expect(IndexDefect):
      discard v[4]
  
  echo "suite teardown: run once after the tests"
