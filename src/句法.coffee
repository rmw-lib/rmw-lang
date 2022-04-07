#!/usr/bin/env coffee

import 词法 from './词法.coffee'
import {sum} from 'lodash-es'

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

左括号 = '({['

export default main = (行迭代)->
  根 = layer = new 层
  前缩进 = 1
  前结尾 = undefined
  括号栈 = [[0,0,0]]

  缩进_层 = {}

  for await line from 词法 行迭代
    [行号,...词组] = line
    缩进 = 词组[0][0]
    if 0 == sum(括号栈[0])
      if 缩进 > 前缩进
        if 前缩进 > 1
          缩进_层[前缩进] = layer
        layer = layer.sub 行号
      else
        if 缩进 < 前缩进
          while 缩进>1
            t = 缩进_层[缩进]
            if t
              break
            --缩进
          if 缩进 == 1
            t = 根
          layer = t
        layer.line 行号

    for 列词 from 词组
      push = =>
        layer.push 列词
        return
      [列,词] = 列词
      pos = '([{'.indexOf 词
      if pos >= 0
        括号栈[0][pos]+=1
        layer = layer.sub 行号
      else
        pos = ')]}'.indexOf 词
        if pos >= 0
          括号栈[0][pos]-=1
          push()
          layer = layer.父
          continue
      push()

    前缩进 = 缩进
    前结尾 = 列词[1]

  return 根
