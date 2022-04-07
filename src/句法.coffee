#!/usr/bin/env coffee

import chalk from 'chalk'
{redBright} = chalk
import 词法 from './词法.coffee'
import {sum} from 'lodash-es'

缩进前缀 = new Set [
  ':'
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
  括号栈 = []
  括号栈_push = =>
    括号栈.push [0,0,0]
  括号栈_push()
  结尾 = undefined

  缩进块 = []

  for await line from 词法 行迭代
    [行号,...词组] = line
    缩进 = 词组[0][0]
    loop
      if 0 == sum(括号栈[0])
        if 缩进 > 前缩进
          if 缩进前缀.has 结尾
            缩进块.push 缩进
            括号栈_push()
            layer = layer.sub 行号
            break
        else
          if 缩进 < 前缩进
            loop
              t = 缩进块[0]
              if t and t>=缩进
                缩进块.shift()
                括号栈.shift()
                layer = layer.父
              else
                break

      try
        layer.line 行号
      catch err
        throw new Error "行 #{行号} : "+词组.map((x)=>x[1]).join('')
      break

    函数个数 = 0

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
        括号栈_push()
        layer = layer.sub(行号)
        push()
        ++函数个数
        缩进块.unshift 缩进
      else
        pos = '([{'.indexOf 词
        if pos >= 0
          括号栈[0][pos]+=1
          layer = layer.sub 行号
          push()
        else
          pos = ')]}'.indexOf 词
          if pos >= 0
            n = 0
            while 函数个数>0
              if (括号栈[0][pos]-=1) < 0
                括号栈.shift()
                layer = layer.父
                --函数个数
              else
                break
            push()
            layer = layer.父
          else
            push()
      if 函数个数 > 0
        if ['->','=>'].indexOf(结尾)<0 and not sum(括号栈[0])
          括号栈 = 括号栈[函数个数..]
          缩进块 = 缩进块[函数个数..]

          while 函数个数--
            layer = layer.父


    前缩进 = 缩进

  return 根
