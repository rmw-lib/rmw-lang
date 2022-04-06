#!/usr/bin/env coffee

import 词法 from './词法.coffee'

缩进前缀 = new Set [
  ':'
  '=>'
  '->'
  '('
  '['
  '{'
  '='
]

export default main = (行迭代)->
  for await line from 词法 行迭代
    yield line
      ###
    [行号,...词组] = line
    if not li.length
      li.push 行号
      if 没有括号 没有缩进
      if ~ '([{'.indexOf 词
        块 = new 层 行号,块
      else if ~ ')]}'.indexOf 词
        块.push i
        块 = 块.父
        continue
      块.push i
      ###
  return
