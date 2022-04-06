#!/usr/bin/env coffee

import 句法 from './句法.coffee'

编译 = (块)->
  前行 = 1
  run = (块)->
    for [行号,...行] from 块
      if 行号>前行
        yield '\n'+''.padEnd(
          行[0][0] - 1
        )
        前行 = 行号
      for i from 行
        [列,词] = i
        yield 词
  return run(块)

export default (行迭代)->
  yield from 编译(
    await 句法 行迭代
  )
