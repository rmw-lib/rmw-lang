#!/usr/bin/env coffee

import 词法 from './词法.coffee'

class _层
  constructor:(@父)->
    @li = []

  push:(i)->
    @li.push i
    i

export default main = (行迭代)->
  层 = new _层()
  前行 = 1
  列 = 0
  for await [行,...li] from 词法 行迭代
    for 块 from li
      [列,词] = 块
      块 = [行].concat 块
      if ~ '({['.indexOf 词
        层.push 块
        层 = 层.push new _层(层)
        continue
      if ~ ')}]'.indexOf 词
        层 = 层.父
      层.push 块
    #yield 行+'\t'+列+'\t'+JSON.stringify(词)[1...-1]+'\n'
  层
