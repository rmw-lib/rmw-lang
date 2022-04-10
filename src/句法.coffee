#!/usr/bin/env coffee

import chalk from 'chalk'
import {$log} from './rmw-lang'
{redBright} = chalk
import 词法 from './词法.coffee'
import {sum} from 'lodash-es'

返回 = ['<','<<','<<<']

非空格 = (x)=>x[1]!=' '

export class 层
  constructor:(@父)->
    @li = []

  sub:(args...)->
    layer = new 层 @
    layer.line args
    @push layer
    layer

  line:(args)->
    @li.unshift args
    return

  push:(o)->
    @li[0].push o
    return

左括号 = '({['

单行块 = new Set [
  '<='
  '<>'
  ...返回
]

export default main = (行迭代)->
  根 = layer = new 层
  前缩进 = 1
  括号栈 = []
  扩括号栈 = =>
    括号栈.unshift [0,0,0]
  扩括号栈()
  开头 = 结尾 = undefined

  缩进块 = []

  for await line from 词法 行迭代
    [行号,...词组] = line
    缩进 = 词组[0][0]

    layer_li1 = =>
      layer.li[layer.li.length-1]?[1]

    if layer_li1()?[1] == '>'
      if 缩进==1
        layer = 根
        前缩进 = 1
      else
        li = [line[0]]
        t = undefined
        for i from line[1..]
          if t == undefined
            t = i
          else
            if i[1]==' '
              li.push t
              t = undefined
            else
              t[1]+=i[1]
        if t
          li.push t
        layer.line li
        continue

    寻根 = =>
      li1 = layer_li1()
      if li1
        li11 = li1[1]
        if ~ '-='.indexOf li11
          t = li1[0]
          if 缩进 <= t
            layer = layer.父
            前缩进 = t
        else if 单行块.has li11
          layer = layer.父
          前缩进 = li1[0]

    loop

      if 0 == sum(括号栈[0])
        寻根()

        if 缩进 <= 前缩进
          loop
            t = 缩进块[0]
            if t and t>=缩进
              缩进块.shift()
              括号栈.shift()
              layer = layer.父
            else
              break

        寻根()
      try
        layer.line [行号]
      catch err
        throw new Error "行 #{行号} : "+词组.map((x)=>x[1]).join('')
      break

    函数个数 = 0

    for 列词,位 in 词组
      [列,词] = 列词

      无括号 = 0 == sum(括号栈[0])

      if 无括号 and 列 == 1 and 词 == '>'
        layer = 根.sub ...line.filter(非空格)
        break

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

      if 位 == 0
        if 无括号
          if (
            ~ ['-','=',...返回].indexOf 词
          ) or (
            列 == 1 and (
              ~ ['<=','<>','<'].indexOf 词
            )
          )
            layer = layer.sub 行号

      if not 词.startsWith '#'
        结尾 = 词

      if ~ ['->','=>'].indexOf(词)
        扩括号栈()
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
            while 函数个数>0 and 括号栈.length > 1
              if (括号栈[0][pos]-1) < 0
                括号栈.shift()
                layer = layer.父
                --函数个数
              else
                break
            括号栈[0][pos]-=1
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
