#!/usr/bin/env coffee
do ->
  前态 = undefined

  暂 = []

  前行 = 1

  for await 词 from 词法(行迭代)
    [行,列,态,...文] = 词
    if 行!=前行 and not 状态起始.has(态)
      前行 = 行
      yield '\n'+''.padEnd(列)

    文 = 文.join('')
    if 态 == 代码
      文 == 文.trim()
      if not 文
        continue
    if 态 == 被赋值
      yield 'let '
    yield 文
    if 态!=前态
      if 状态起始.has(前态) or 前态 == 多行注释
        switch 前态
          when 多行注释
          when 双引号
            li = []
            暂[0][3]=暂[0][3][1..]
            end = 暂.length-1
            暂[end][3]=暂[end][3][...-1]
            for [_,列,_,文] from 暂
              文= 文.trimEnd()
              if 文
                li.push 文
            yield '"'+li.join('\\n')+'"'
          else
            t = 暂.map((x)=>x[3]).join('\\n')
            if 前态 == 注释
              t = '//'+t[1..]
            yield t

      暂 = []
      前态 = 态
      if 态 == 多行注释
        yield "/*"+文[2..]
        continue

    if [被赋值,赋值].indexOf 态
      yield 文
      continue

    if 状态起始.has(态)
      词 = [行,列,态,文]
      暂.push 词
    #console.log js
    ###
