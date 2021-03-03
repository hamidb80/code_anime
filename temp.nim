import strformat, os

let nums = [1, 5, 4, 8, 9]

for i in 0 ..< nums.len:
  let n = nums[i]
  debugEcho "::CODE_ANIME::show::", "i:",i,"n:",n

  sleep 100
  echo fmt"index {i} gonna be {n}"
  sleep 100

debugEcho "::CODE_ANIME::forget::", "i"
echo "the end"
