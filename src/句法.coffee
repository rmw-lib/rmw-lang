#!/usr/bin/env coffee

import 词法 from './词法.coffee'

export default main = (行迭代)->
  前行 = 1
  for await [行,列,词] from 词法 行迭代
    if 行!=前行
      前行 = 行
      yield '\n'
    yield 行+'\t'+列+'\t'+JSON.stringify(词)[1...-1]+'\n'
  return
