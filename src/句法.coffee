#!/usr/bin/env coffee

import chalk from 'chalk'
{redBright} = chalk
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
  括号栈 = [[0,0,0]]

  缩进_层 = []

  for await line from 词法 行迭代
    [行号,...词组] = line
    缩进 = 词组[0][0]
    if 0 == sum(括号栈[0])
      if 缩进 > 前缩进
        if 前缩进 > 1
          缩进_层.push [前缩进,layer]
        layer = layer.sub 行号
      else
        if 缩进 < 前缩进
          len = 缩进_层.length
          t = undefined
          loop
            x = 缩进_层.pop()
            if x
              [indent,i] = x
              if indent <= 缩进
                t = i
            else
              break
          layer = t or 根
        try
          layer.line 行号
        catch err
          throw new Error "行 #{行号} : "+词组.map((x)=>x[1]).join('')

    有函数 = 0

    for 列词,位 in 词组
      [列,词] = 列词

      push = =>
        try
          layer.push 列词
        catch err
          t = []
          for [col,word] from 词组
            if col == 列
              word = redBright(word)
            t.push word
          throw new Error "行 #{行号} 列 #{列} : "+t.join('')
        return

      if not 词.startsWith '#'
        结尾 = 词

      if ~ ['->','=>'].indexOf(词)
        括号栈.unshift [0,0,0]
        layer = layer.sub(行号)
        ++有函数
      else
        pos = '([{'.indexOf 词
        if pos >= 0
          括号栈[0][pos]+=1
          layer = layer.sub 行号
        else
          pos = ')]}'.indexOf 词
          if pos >= 0
            n = 0
            loop
              if (括号栈[0][pos]-=1) < 0
                括号栈.shift()
                layer = layer.父
                --有函数
              else
                break
            push()
            layer = layer.父
            continue
      if 有函数 > 0
        if ['->','=>'].indexOf(结尾)<0 and not sum(括号栈[0])
          括号栈 = 括号栈[有函数..]
          while 有函数--
            layer = layer.父

      push()

    前缩进 = 缩进

  return 根
