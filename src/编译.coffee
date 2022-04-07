#!/usr/bin/env coffee

import 句法,{层} from './句法.coffee'

编译 = (层)->
  前行 = 1
  run = (层)->
    n = 0
    右括号 = =>
      r = ''.padEnd(n,')')
      n = 0
      r

    for [行号,...行] from 层.li.reverse()
      for i from 行
        if Array.isArray i
          if 行号>前行
            if n
              yield 右括号()
            yield '\n'+''.padEnd(
              行[0][0] - 1
            )
            前行 = 行号
          [列,词] = i
          if 词 == ' '
            yield '('
            ++n
          else
            yield 词
        else
          yield from run i
    if n
      yield 右括号()
  return run(层)

export default (行迭代)->
  yield from 编译(
    await 句法 行迭代
  )
