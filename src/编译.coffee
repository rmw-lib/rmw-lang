#!/usr/bin/env coffee

import 句法,{层} from './句法.coffee'
import chalk from 'chalk'
import {$log} from './rmw-lang'
import _变量层 from './变量层'
import 转注释 from './转注释'

变量声明 = Symbol('变量声明')


导入 = (li)->
  模块缩进 = 模块 = undefined

  for [行号,...行],pos in li
    n = 0
    len = 行.length
    cpos = 0
    while cpos < len
      [列,词] = 行[cpos++]
      if cpos == 1
        缩进 = 列
      if 词.startsWith '#'
        yield 转注释(词)
      else
        if '>' != 词
          if 模块缩进
            if cpos == 1
              yield '\n'
          else
            模块缩进 = 列

          if 缩进 <= 模块缩进
            模块 = 词
            if 行[cpos]?[1] == ':'
              新名 = 行[++cpos]?[1]
              if 新名
                yield "import { default as #{新名} } from '#{词}'"
                ++cpos
                continue
            if 行[cpos]?[0] <= 模块缩进
              yield "import #{词} from '#{词}'"
          else
            if cpos == 1
              yield 'import {'
            yield 词
    if 缩进 > 模块缩进
      yield "} from '#{模块}'\n"
  if li.length
    yield '\n'
  return

编译 = (层)->
  变量层 = new _变量层()
  前行 = 0
  行缩进 = {}
  前层 = undefined

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

      for i,cpos in 行

        if Array.isArray i
          [列,词] = i

          switch 词
            when '>'
              if cpos==0 and 列==1
                yield from 导入(层.li)
                return

          if not (行号 of 行缩进)
            行缩进[行号] = 列-1

          if pos == 0
              块缩进 = 行缩进[行号]
              switch 词
                when '<='
                  if cpos==0 and 列==1
                    词 = 'export default '
                    变量名 = 行[1]?[1]
                    if 变量名
                      if 变量层.upsert 变量名
                        词 += 'const '
                when '<'
                  if cpos==0 and 列==1
                    词 = 'export '
                    if 行[1]?[1] == '='
                      行[1][1] = 'default '
                      变量名 = 行[2]?[1]
                      if 变量名
                        if 变量层.upsert 变量名
                          行[1][1] += 'const '
                    else
                      if 行[2]?[1] != '='
                        词 += 'default '
                      else
                        变量名 = 行[1][1]
                        if 变量层.upsert 变量名
                          词 += 'const '
                  else
                    词 = 'return '
                when '<<'
                  词 = 'yield '
                when '<<<'
                  词 = 'yield* '

            switch 词
              when '('
                态 = 词
              when '->'
                态 = 词
                词 = 'function'
                if cpos==0
                  词 += '()'
                词 += '{'
              when '=>'
                态 = 词
                if cpos==0
                  词 = '()'+词
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
              if 态 == '('
                if (pos > 1 and pos < len) or (
                  pos == 1 and li[0].length > 2
                ) or (
                  pos == len and li[len].length > 2
                )
                  yield ','

              if not ( 态 == 变量声明 and li[0].length == 2 and pos == 1)
                yield '\n'+''.padEnd(
                  行[0][0] - 1
                )
            前行 = 行号

          注释 = 词.startsWith '#'
          if 注释
            yield from ended()
            yield 转注释(词)
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

    switch 态
      when '=>','->'
        if li.length > 1 or 词.startsWith('#')
          yield '\n'+''.padEnd(块缩进)
        yield '}'

      #if ~ ['-','='].indexOf 什么层
      #  if not (行.length == 1 and 行[0][1] == 什么层)
      #    yield ','
    if n
      yield 右括号()
    前层 = 层
    return

  return run(层)

export default (行迭代)->
  yield from 编译(
    await 句法 行迭代
  )
