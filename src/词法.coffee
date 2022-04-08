#!/usr/bin/env coffee
import {$log} from './rmw-lang'

文态 = '\'"`'
export 非代码态 = new Set 文态 + '#'
文态 = new Set 文态

双字符 = {
  '=':'>=<'
  '!':'='
  '&':'=&'
  '|':'=|'
  '/':'=/'
  '+':'+='
  '-':'-=><'
  '*':'=*'
  '%':'='
  '^':'='
  '>':'=>'
  '<':'=<>'
}

三字符 = '*<>'

下一个非转义字符 = (str, sub, begin)=>
  n = begin
  len = str.length
  while n < len
    switch str[n]
      when '\\'
        n+=2
      when '/'
        return n
      else
        ++n
  -1

export 非调用前缀 = new Set [
  '('
  '['
  '{'
  '..'
  ','
]

do =>
  for [k,v] from Object.entries 双字符
    非调用前缀.add k
    for i from v
      非调用前缀.add k+i

  for i from '/'+三字符
    非调用前缀.add(i+i+'=')
  return

非调用后缀 = new Set(
  非调用前缀.keys()
)

do =>
  for i from ')]}'
    非调用后缀.add i
  for i from '( [ { => -> =< -< -- ++'.split(' ')
    非调用后缀.delete i
  return

非调用前缀 = new Set [
  '<<<'
  ...非调用前缀
]

操作符 = '(){}[],@~:!?;'
操作符 = new Set 操作符

_词法 = (行迭代)->
  态 = 0
  暂 = []
  行始 = 行号 = 列 = 0
  列始 = 1
  前 = ''

  封 = =>
    if 暂.length
      前 = 暂.reverse().join('')
      暂 = []
      值 = [行始,列始,前]
    列始 = 列
    行始 = 行号
    值

  for await 行 from 行迭代
    ++行号

    行长 = 行.length
    if 态
      暂.unshift '\n'
      if 态[0] == '#:'
        缩进 = 行长 - 行.trimStart().length
        if 缩进 > 态[1]
          暂.unshift 行
          continue
        else
          yield 封()
          态 = 0
      else
        列 = 0
    else
      列 = 行长 - 行.trimStart().length
      列始 = 列+1
      行始 = 行号

    while 列 < 行长
      字 = 行[列++]
      if 态
        暂.unshift 字
        if 字 == '\\'
          if 列 == 行长
            暂.shift()
          else
            暂.unshift 行[列]
            ++列
          continue
        if 字 == 态
          yield 封()
          态 = 0
      else if 字 == '#'
          文 = 行[--列..]
          暂.unshift 文
          if 文[1] == '|'
            态 = ['#:',列]
          else
            yield 封()
          列 = 行长
      else if 字 == ' '
        yield 封()
        while 列 < 行长
          次 = 行[列]
          if 次 == ' '
            ++列
          else
            break
        if 非调用前缀.has(前) or 列 == 行长
          列始 = 1+列
          continue
        else
          暂.unshift 字
          yield 封()
      else if 文态.has 字
        yield 封()
        态 = 字
        暂.unshift 字
      else
        if 字 == '.'
          次 = 行[列]
          if 次 == 字
            暂.unshift 行[列-1..列]
            ++列
            yield 封()
            continue

        有次 = 双字符[字]
        if 有次
          yield 封()
          次 = 行[列]
          暂.unshift 字
          if ~有次.indexOf 次
            暂.unshift 次
            ++ 列
          switch 字
            when '/'
              if 次 == 字
                if 行[列] == '='
                  暂.unshift '='
                  ++ 列
              else
                begin = 列

                pos = 下一个非转义字符(行,'/',begin)+1
                if pos
                  while pos < 行长
                    if '. igm'.indexOf(行[pos]) < 0
                      break
                    ++pos

                  正则 = false

                  if pos == 行长
                    正则 = true
                  else if ~ ',)'.indexOf 行[pos]
                    正则 = true

                  if 正则
                    暂.unshift 行[列...pos]
                    列 = pos
          if ~ 三字符.indexOf(字)
            if 次 == 字
              t = 行[列]
              if t == '=' or ( t == '<' and 字 == '<' )
                暂.unshift t
                ++ 列
          yield 封()
        else if 操作符.has(字)
          yield 封()
          暂.unshift 字
          yield 封()
        else
          暂.unshift 字

    字 = 暂[0]
    if 字 == '\\'
      pos = 0
      n = 0
      loop
        if 暂[++pos] == '\\'
          ++n
        else
          break
      if n%2
        if not 态
          yield 封()
          行始 = 行+1
      else
        暂.shift()
    else if not 态
      yield 封()

  yield 封()
  return

export default (行迭代)->

  行数组 = []
  前行 = 1
  封 = =>
    结果 = [前行]
    行数组.reverse()
    for i,pos in 行数组
      if i[1]==' '
        t = 行数组[pos+1]?[1]
        if 非调用后缀.has(t) or t.startsWith('#')
          continue
        else if (行数组[pos-1]?[1] == ')') and ~['=>','->'].indexOf(行数组[pos+1]?[1])
          continue
      结果.push i
    结果

  for await 块 from _词法(行迭代)
    if 块
      [行,列,词] = 块
      if 行!=前行
        if 行数组.length > 0
          yield 封()
        前行 = 行
        行数组 = []
      行数组.unshift [列,词]
  if 行数组.length > 0
    yield 封()
  return
