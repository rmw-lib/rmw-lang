#!/usr/bin/env coffee

import 句法 from './句法.coffee'

编译 = (层)=>
  前行=1
  run = (layer)->
    for i from layer.li
      if Array.isArray i
        [行,列,词] = i
        if 行!=前行
          前行=行
          yield '\n'+''.padEnd(列-1)
        yield 词
      else
        yield from run(i)
    return
  run 层


export default main = (行迭代)->
  编译(await 句法 行迭代)
