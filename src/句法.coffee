#!/usr/bin/env coffee

import 词法 from './词法.coffee'

缩进前缀 = new Set [
  ':'
  '=>'
  '->'
  '('
  '['
  '{'
  '?'
  '='
]

export class 层
  constructor:(@父)->
    @li = []

  sub:(行号)->
    layer = new 层 @
    layer.line 行号
    @push layer
    layer

  line:(行号)->
    @li.unshift [行号]
    return

  push:(o)->
    @li[0].push o
    return

export default main = (行迭代)->
  根 = layer = new 层
  for await line from 词法 行迭代
    [行号,...词组] = line
    layer.line 行号

    for 列词 from 词组
      push = =>
        layer.push 列词
        return

      [列,词] = 列词
      if ~ '([{'.indexOf 词
        layer = layer.sub 行号
      else if ~ ')]}'.indexOf 词
        push()
        layer = layer.父
        continue
      push()
  return 根
