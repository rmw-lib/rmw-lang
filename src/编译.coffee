#!/usr/bin/env coffee

import 句法 from './句法.coffee'

编译 = (层)->
  for i from 层.li
    if Array.isArray i
      [行,列,词] = i
      yield JSON.stringify([行,列,词])[1...-1].replaceAll('\\\\','\\')+'\n'
    else
      yield from 编译(i)
  return


export default main = (行迭代)->
  编译 await 句法 行迭代
