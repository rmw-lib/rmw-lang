#!/usr/bin/env coffee

import {walkRel} from '@rmw/walk'
import {readFileSync} from 'fs'
import fsline from '@rmw/fsline'
import {dirname,join} from 'path'
import thisdir from '@rmw/thisdir'
import chalk from 'chalk'
import 编译 from './编译.coffee'


ROOT = dirname thisdir import.meta
CODE = join(ROOT,'code')
RMW = join CODE,'rmw'

if process.argv[1] == decodeURI (new URL(import.meta.url)).pathname
  for await 路径 from walkRel RMW
    if not 路径.endsWith '.rmw'
      continue
    console.log chalk.yellow('\n→'+路径)
    for i from await 编译 fsline join(RMW,路径)
      process.stdout.write i
  process.exit()
