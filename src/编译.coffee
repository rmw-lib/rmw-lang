#!/usr/bin/env coffee

import 句法,{层} from './句法.coffee'

变量声明 = Symbol('变量声明')

编译 = (层)->
  前行 = 0
  run = (层)->
    n = 0
    右括号 = =>
      r = ''.padEnd(n,')')
      n = 0
      r

    li = 层.li.reverse()

    len = li.length - 1
    态 = 0
    for [行号,...行],pos in li
      ended = ->
        if 态 == 变量声明
          if len == pos
            yield ';'
          else if not (pos==0 and 行.length==1)
            yield ','

      for i from 行

        if Array.isArray i
          [列,词] = i

          if pos == 0
            if 词 == '=>'
              态 = 词
              if li.length > 1
                词 += '{'

          换行 = 行号>前行
          if 换行
            if pos == 0
              switch 词
                when '-','='
                  词 = {
                    '-':'const '
                    '=':'let '
                  }[词]
                  态 = 变量声明
            if 前行
              if not ( 态 == 变量声明 and li[0].length == 2 and pos == 1)
                yield '\n'+''.padEnd(
                  行[0][0] - 1
                )
            前行 = 行号

          注释 = 词.startsWith '#'
          if 注释
            yield from ended()
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
      if not 注释
        yield from ended()

      if n
        yield 右括号()

    if 态 == '=>' and li.length > 1
      yield '}'

      #if ~ ['-','='].indexOf 什么层
      #  if not (行.length == 1 and 行[0][1] == 什么层)
      #    yield ','
    if n
      yield 右括号()
  return run(层)

export default (行迭代)->
  yield from 编译(
    await 句法 行迭代
  )
