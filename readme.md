# Code Anime!
convert your code into visual algorigthm

## alert
this project is under developments

## idea / algorithm:
the idea is that, that we are going to read the code
```nim
  let nums = [1,5,4,8,9]

  for i in 0 ..< nums.len:  
    let n = nums[i]
    #!show i indexof numsW; n;

    #!sleep 100
    echo i+1
    #!sleep 100
```
then we replace these lines (#!show, #!sleep, ...)s, with our code 

[i know it's a damn idea but it works, also we lose stack tracing but working with gdb is painful] 
[also maybe with lsp we can do this someday]

we compile new code, 

----------
## common mistakes:
1. **the comments must be aligned with the code**

```nim
  for i in 0 ..< nums.len:  
    let n = nums[i]
    #!show i indexof numsW; n;
    ...
```
up: correct - down: wrong
```nim
  for i in 0 ..< nums.len:  
    let n = nums[i]
#!show i indexof numsW; n;
    ...
```

----------
## keywords:
1. **!show** var1 [, var2, var3]
2. **!sleep** (time in ms)
3. **!forget** var1 [, var2, var3]
4. ...

----------

## how to use it:
obviously you can't use it now because it's under development