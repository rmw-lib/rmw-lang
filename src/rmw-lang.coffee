#!/usr/bin/env coffee

import chalk from 'chalk'

export $log = (...args)=>
  t = []
  for i from args
    if typeof(i) == 'string'
      t.push chalk.yellow i
    else
      t.push i
  console.log ...t
  return
