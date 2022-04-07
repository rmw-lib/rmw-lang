#!/usr/bin/env coffee

import 句法,{层} from './句法.coffee'

编译 = (层)->
  前行 = 0
  run = (层)->
    n = 0
    右括号 = =>
      r = ''.padEnd(n,')')
      n = 0
      r

    li = 层.li.reverse()

    什么层 = undefined

    for [行号,...行] from li
      for i from 行
        if Array.isArray i
          [列,词] = i

          if 什么层 == undefined
            什么层 = 词

          if 行号>前行
            if ~ ['-','='].indexOf 什么层
              switch 词
                when '-'
                  词 = 'const '
                when '='
                  词 = 'let '

            if 前行
              yield '\n'.padEnd(
                行[0][0] - 1
              )

            前行 = 行号


          if 词.startsWith '#'
            if 词.charAt(1) == '|'
              yield '/*'+词[2..]+'*/'
            else
              yield '//'+词[1..]
          else
            switch 词
              when ' '
                yield '('
                ++n
              else
                yield 词
        else
          yield from run i

      if n
        yield 右括号()

      if ~ ['-','='].indexOf 什么层
        yield ','
    if n
      yield 右括号()
  return run(层)

export default (行迭代)->
  yield from 编译(
    await 句法 行迭代
  )
