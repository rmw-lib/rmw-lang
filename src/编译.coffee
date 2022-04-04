#!/usr/bin/env coffee

import 句法 from './句法.coffee'

编译 = (层,前行=1)->
  for i from 层.li
    if Array.isArray i
      [行,列,词] = i
      if 行!=前行
        前行=行
        yield '\n'+''.padEnd(列-1)
      yield 词
    else
      yield from 编译(i,前行)
  return


export default main = (行迭代)->
  编译 await 句法 行迭代
