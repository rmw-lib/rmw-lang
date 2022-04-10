#!/usr/bin/env coffee

import 转注释 from './转注释'
import {$log} from './rmw-lang'

export default (li, import_map)->
  模块缩进 = 模块 = undefined

  for [行号,...行],pos in li
    n = 0
    len = 行.length
    cpos = 0
    while cpos < len
      获取新名 = =>
        if 行[cpos]?[1] == ':'
          新名 = 行[++cpos]?[1]
          if 新名
            ++cpos
            return 新名
        return

      [列,词] = 行[cpos++]
      if cpos == 1
        缩进 = 列

      if 模块缩进 and 缩进 <= 模块缩进 and cpos == 1
        yield '\n'

      if 词.startsWith '#'
        yield 转注释(词)
      else
        if '>' != 词
          if not 模块缩进
            模块缩进 = 列

          if 缩进 <= 模块缩进
            模块 = 词
            新名 = 获取新名()
            if 新名
              yield "import { default as #{新名} } from '#{import_map(词)}'"
              continue

            if (行[cpos]?[0] <= 模块缩进) or not 行[cpos]
              yield "import #{词} from '#{import_map(词)}'\n"
          else
            if cpos == 1
              yield 'import { '
            else
              yield ','
            新名 = 获取新名()
            if 词 == '.'
              新名 = 新名 or 模块
              词 = 'default'
            if 新名
              yield 词+" as "+新名
              continue
            yield 词
    if 缩进 > 模块缩进
      yield " } from '#{模块}'"
  if li.length
    yield '\n'
  return
