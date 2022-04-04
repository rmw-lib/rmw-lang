#!/usr/bin/env coffee

文态 = '\'"`'
export 非代码态 = new Set 文态 + '#'
文态 = new Set 文态

多字节符号 = {
  '=':'>=<'
  '!':'='
  '&':'=&'
  '|':'=|'
  '/':'=/'
  '+':'+='
  '-':'-=>'
  '*':'=*'
  '%':'='
  '^':'='
  '>':'='
  '<':'='
}

操作符 = '(){}[],@~:!?;'
符号 = new Set 操作符+Object.keys(多字节符号).join('')
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
      if 态[0] == '#|'
        缩进 = 行长 - 行.trimStart().length
        if 缩进 > 态[1]
          暂.unshift '\n'
          continue
        else
          yield 封()
          态 = 0
      else
        列 = 0
    else
      列始 = 1
      列 = 0
      字 = 暂?[0]
      if 字 == '\\'
        暂.shift()
      else if 字 == ' '
        暂 = []
      else
        yield 封()
        列 = 行长 - 行.trimStart().length
        列始 = 列+1


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
            态 = ['#|',列]
          else
            yield 封()
          列 = 行长
      else if 字 == ' '
        yield 封()
        次 = 行[列]
        if 次 == ' ' or 符号.has(次) or 符号.has(前.charAt(0))
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

        有次 = 多字节符号[字]
        if 有次
          yield 封()
          次 = 行[列]
          暂.unshift 字
          if ~有次.indexOf 次
            暂.unshift 次
            ++ 列
          if 字 == '/'
            if 次 == 字
              if 行[列] == '='
                暂.unshift '='
                ++ 列
            else
              pos = 行.indexOf('/',列)+1
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

          yield 封()
        else if 操作符.has(字)
          yield 封()
          暂.unshift 字
          yield 封()
        else
          暂.unshift 字

  yield 封()
  return

export default (行迭代)->
  for await i from _词法(行迭代)
    if i
      yield i
  return
