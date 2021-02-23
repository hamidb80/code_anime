import strformat, os

let nums = [1, 5, 4, 8, 9]

for i in 0 ..< nums.len:
  let n = nums[i]
  debugEcho "::CODE_ANIME::", "i indexof nums, n"

  sleep 100
  echo fmt"index {i} gonna be {n}"
  sleep 100

debugEcho "::CODE_ANIME::", "forget ", "i indexof nums, n"
echo "the end"
