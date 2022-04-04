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
  for await 块 from 词法 行迭代
    console.log 块
    [行,列,词] = 块
    if 行!=前行
      层.push [
        行
        0
        '\n'
      ]
      前行 = 行
    if ~ '({['.indexOf 词
      层.push 块
      层 = 层.push new _层(层)
      continue
    if ~ ')}]'.indexOf 词
      层 = 层.父
    层.push 块
    #yield 行+'\t'+列+'\t'+JSON.stringify(词)[1...-1]+'\n'
  层
