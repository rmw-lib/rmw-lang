#!/usr/bin/env coffee

export default class 变量层
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

  ###
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
  ###
