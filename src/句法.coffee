#!/usr/bin/env coffee

import 词法 from './词法.coffee'

export default main = (行迭代)->
  for await i from 词法 行迭代
    console.log ''
    console.log i
    yield i
