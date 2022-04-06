#!/usr/bin/env coffee

import 句法,{层} from './句法.coffee'

编译 = (块)->
  前行 = 1
  run = (块)->
    [行号,...行] = 块.li
    for i from 行
      if 行号>前行
        yield '\n'
        前行 = 行号
      if i instanceof 层
        yield from run 块
      else
        [列,词] = i
        yield 词
  return run(块)

export default (行迭代)->
  yield from 编译(
    await 句法 行迭代
  )
