#!/usr/bin/env coffee

import 转注释 from './转注释'
import {$log} from './rmw-lang'

export default (li)->
  模块缩进 = 模块 = undefined

  for [行号,...行],pos in li
    n = 0
    len = 行.length
    cpos = 0
    while cpos < len
      [列,词] = 行[cpos++]
      if cpos == 1
        缩进 = 列
      if 词.startsWith '#'
        yield 转注释(词)
      else
        if '>' != 词
          if 模块缩进
            if cpos == 1
              yield '\n'
          else
            模块缩进 = 列
            $log {模块缩进 }

          if 缩进 <= 模块缩进
            模块 = 词
            if 行[cpos]?[1] == ':'
              新名 = 行[++cpos]?[1]
              if 新名
                yield "import { default as #{新名} } from '#{词}'"
                ++cpos
                continue
            if 行[cpos]?[0] <= 模块缩进
              yield "import #{词} from '#{词}'"
          else
            if cpos == 1
              yield 'import {'
            yield 词
    if 缩进 > 模块缩进
      yield "} from '#{模块}'\n"
  if li.length
    yield '\n'
  return
