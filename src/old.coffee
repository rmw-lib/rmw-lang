#!/usr/bin/env coffee

import chalk from 'chalk'
import thisdir from '@rmw/thisdir'
import {dirname,join} from 'path'
import {walkRel} from '@rmw/walk'
import {readFileSync} from 'fs'
import fsline from '@rmw/fsline'
import {sum} from 'lodash-es'
import yaml from 'js-yaml'
import json5 from 'json5'

$log = (args...)=>
  console.log chalk.green('\n\t→'),...args

对象翻转 = (obj) =>
  m = new Map()
  Object.entries(obj).map(
    ([k,v]) =>
      m.set v,k
      return
  )
  m

ROOT = dirname thisdir import.meta
CODE = join(ROOT,'code')
RMW = join CODE,'rmw'

代码 = Symbol '代码'
终结 = Symbol '终结'
函数 = Symbol '函数'
行缩进 = Symbol '行缩进'
空白 = Symbol '空白'
转义 = Symbol '转义'
字符串数组 = Symbol '字符串数组'
注释 = '#'
多行注释 = Symbol '多行注释'
正则 = '/'
单引号 = "'"
双引号 = '"'
字符串模板 = '`'
被赋值 = Symbol '被赋值'
赋值 = Symbol '赋值'
括号 = '{[(}])'

状态起始 = new Set([
  正则
  单引号
  双引号
  字符串模板
  注释
])

词法 = (行迭代)->
  行号 = 0
  状态 = 代码

  for await 行 from 行迭代
    ++ 行号
    无缩进行 = 行.trimStart()
    无缩进行长 = 无缩进行.length

    if ~[多行注释,代码].indexOf(状态) and 0==无缩进行长
      continue

    行长 = 行.length
    缩进长 = 行长 - 无缩进行长
    if 暂存
      yield 暂存

    暂存 = [行号,缩进长,状态]
    位置 = 缩进长-1

    `外层循环: //`
    while ++位置 < 行长
      i = 行[位置]
      switch 状态
        when 代码
          if 状态起始.has i
            if 位置 > 缩进长
              yield 暂存
              暂存 = [行号,位置,i]
            else
              暂存[2] = i
            if i == 注释
              txt = 行[位置..]
              暂存.push txt
              if 无缩进行.startsWith '#|'
                暂存[2] = 状态 = 多行注释
                块缩进 = 缩进长
              `break 外层循环`
            else
              状态 = i
              暂存.push i
              `continue 外层循环`
          else
            if ~括号.indexOf(i)
              yield 暂存
              yield [行号,位置,i,i]
              暂存 = [行号,位置+1,代码]
            else
              if ~ '-='.indexOf(i) and 行[位置+1] == '>'
                yield 暂存
                ++位置
                暂存 = [行号,位置]
                暂存 = 暂存.concat [函数,i+'>']
                yield 暂存
                暂存 = [行号,位置+1,状态]
              else
                if i == '='
                  yield 暂存
                  暂存 = [行号,位置,'=','=']
                  yield 暂存
                  暂存 = [行号,位置+1,状态]
                else
                  暂存.push i

        when 多行注释
          if 缩进长 > 块缩进
            暂存.push 无缩进行
            `break 外层循环`
          else
            暂存[2] = 状态 = 代码
            位置 = 缩进长-1
            continue
        else
          begin = 位置
          loop
            end = 行.indexOf(状态,位置)
            if ~end
              位置 = end

              转义字符数 = 0

              pos = end
              loop
                if 行[--pos]=='\\'
                  ++转义字符数
                  continue
                break
              if 转义字符数%2
                continue

              暂存.push 行[begin..end]
              状态 = 代码
              位置_1 = 位置+1
              if 位置_1 < 行长
                yield 暂存
                暂存 = [行号,位置_1,状态]
                `continue 外层循环`
              else
                `break 外层循环`
            暂存.push 行[begin..]
            位置 = 行长
            `break 外层循环`

  if 暂存
    yield 暂存
  yield [++行号,0,终结] # 哨兵
  return

# ( 函数调用
# { 字典声明
# [ 数组

非代码态 = (态)=>
  状态起始.has(态) or 态 == 多行注释

注释态 = (态)=>
  ~[多行注释,注释].indexOf 态

class _层
  constructor:->
    @li = [new Set()]

  add:(key)->
    len = @li.length-1
    @li[len].add key

  has:(key)->
    for i from @li
      if i.has(key)
        return true
    false

  new:->
    @li.push new Set()
    return

  pop:(n)->
    while n-- > 0
      @li.pop()
    return

  变量声明:(纯,r)->
    if 纯 == '='
      pre = r[0][3]
      trim = pre.trimEnd()
      p = trim.length
      t = []
      while --p >= 0
        c = trim[p]
        if c == '.'
          t = 0
          break
        if ~ ', '.indexOf c
          break

        t.unshift c

      if t
        t = t.join ''
        ppre = r[1]?[3]
        if ppre == '='
          for i,pos in r[1..]
            i = i[3]
            if i.startsWith 'let '
              p = i.indexOf(';')
              if ~p
                i = i[...p]+','+t+i[p..]
                r[pos+1][3] = i
                break
        else
          if not @has t
            @add t
            pre = pre.trimStart()
            if t == trim
              pre = 'let '+pre
            else
              pre = 'let '+t+';'+pre
            r[0][3] = pre
    return

export default 句法 = (行迭代)->
  r = []
  层 = new _层()
  声明 = 0
  前文 = 前行 = 前态 = undefined
  行缩进 = 0
  暂 = []
  括号栈 = [[0,0,0]]
  函数块 = []

  for await 词 from 词法(行迭代)
    [行,列,态,...文] = 词

    rt = (txt)=>
      r.unshift [行,列,态,txt]

    if not 文.length and 态 != 终结
      continue

    文 = 文.join('')

    态变 = 态!=前态
    换行 = 行!=前行

    if 换行
      行缩进 = 列

    前态是注释 = 注释态 前态

    if 态变
      if 非代码态(前态) and not 前态是注释
        暂2文 = (split)=>
          暂.map((x)=>x[3]).join(split)

        switch 前态
          when 双引号
            li = []
            for [_,_,_,t] from 暂
              li.push t
            rt json5.stringify yaml.load li.join('\n')[1...-1]
          else
            rt 暂2文 '\\n'

    if 声明 and ( (换行 and 态 == 代码) )
      if 列 < 声明
        声明 = 0
        rt ';'
      else
        if ['const','let'].indexOf(r[0][3]) < 0
          rt ','

    if 态变 and 前态是注释
      switch 前态
        when 多行注释
          rt '\n'+暂2文('\n').replace('#|','/*')+'\n'+''.padEnd(暂[0][1])+'*/'
        when 注释
          rt 暂2文('').replace('#','//')

    if 态变
      暂 = []

    前态 = 态

    if 换行
      前行 = 行
      缩进 = ''.padEnd(列)
      文 = 文
    else
      缩进 = ''

    if 非代码态 态
      文= 缩进+文
      词 = [行,列,态,文]
      暂.push 词
    else
      单行函数结束判断 = false
      if 换行
        单行函数结束判断 = true
      else
        pos = 括号[3..].indexOf(文)
        if ~pos
          if 括号栈[0][pos] < 1
            单行函数结束判断 = true

      if 单行函数结束判断
        n = 0
        for [_,indent,单行函数] from 函数块
          if 单行函数
            rt '}'
            ++n
          else if 行缩进 <= indent
            ++n
            rt '\n'+''.padEnd(indent)+'}'
          else
            break
        if n
          层.pop n
          函数块 = 函数块[n..]
          括号栈 = 括号栈[n..]

      if typeof(态) == 'string'
        p = 括号.indexOf 态
        if ~p
          if p<3
            括号栈[0][p]+=1
          else
            括号栈[0][p%3]-=1


      if 换行 and 行>1
        t = []
        pos = do =>
          for i from r
            if i[0] < 行
              return i[0]
        for i from r
          if i[0] == pos
            t.unshift i
        函数调用 t

        rt '\n'
        if 缩进
          rt 缩进

      纯 = 文.trim()
      if 纯
        if 0 == sum(括号栈[0])
          if 纯.startsWith '<'
            文 = 'return'+纯[1..]
          else
            for [缀,符] from Object.entries {
              '-':'const'
              '=':'let'
            }
              if 换行 and 纯.以前缀开始 缀
                t = 纯[1..].trim()
                if t
                  t = ' '+t
                文 = 符+t
                声明 = 列+1
                break

            if not 声明
              层.变量声明 纯,r
        else
          文 = 文.replaceAll '..','...'
        if 态 == 函数
          函数块.unshift [
            行
            行缩进
            false # 单行函数
          ]
          层.new()
          括号栈.unshift [0,0,0]
          if 前文?.endsWith(')')
            if 纯 == '->'
              len = r.length
              if len
                --len
                p = 0
                n = 0
                `wp: //`
                while p++ < len
                  t = r[p]
                  switch t[2]
                    when ')'
                      ++n
                    when '('
                      --n
                      if n == 0
                        t[3] = 'function'+t[3]
                        `break wp`
                文=''
          else
            if 纯 == '->'
              文 = 'function()'
            else
              文 = '()'+纯
          文 += '{'
        else
          for [line],pos in 函数块
            if line == 行
              函数块[pos][2] = true
              if 纯.startsWith('<')
                文 = 'return'+纯[1..]
            else
              break
        rt 文
        前文 = 纯
  return r

String::以前缀开始 = (缀)->
  (@ == 缀) or @startsWith 缀+' '


编译 = (行迭代)->
  for [行,列,态,文] from (await 句法(行迭代)).reverse()
    yield 文
  return

函数调用 = (单行)=>
  ignore = '<>;,+-*/?%.|^!&'
  for [行,列,态,文],pos in 单行
    if 态 == 代码
      文 = 文.trimStart().replace(/ +/g,' ').split(' ')
      len = 文.length
      if len<=1
        continue
      --len
      n = 0
      插括号 = false
      t = []
      for i,p in 文
        if ignore.indexOf(i.charAt(0)) < 0
          if p == 0
            if ['return','let','const'].indexOf(i) < 0
              c = 单行[pos-1]?[3]
              if c != '='
                ++n
                i = i+'('
          else
            cursor = p
            while ++cursor < len
              c = 文[cursor].trimStart()
              if c
                if ignore.indexOf(c)<0
                  ++n
                  i = i+'('
                break
            if cursor == len
              $log i, 单行[pos+1]
        if i
          t.unshift i
      单行[pos][3] = t.reverse().join(' ')
  return


if process.argv[1] == decodeURI (new URL(import.meta.url)).pathname
  for await 路径 from walkRel RMW
    if not 路径.endsWith '.rmw'
      continue
    console.log '\n→',路径
    for await i from 编译(fsline join(RMW,路径))
      process.stdout.write i
      null
  process.exit()
