#!/usr/bin/env coffee

import 句法 from './句法.coffee'

export default main = (行迭代)->
  for await [行号,...行] from 句法 行迭代
    for [列,词] from 行
      yield 词
