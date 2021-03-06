#!/usr/bin/env coffee

import {walkRel} from '@rmw/walk'
import {mkdirSync,createWriteStream,readFileSync} from 'fs'
import fsline from '@rmw/fsline'
import {dirname,join} from 'path'
import thisdir from '@rmw/thisdir'
import chalk from 'chalk'
import 编译 from './编译.coffee'

ROOT = dirname thisdir import.meta
CODE = join(ROOT,'code')
RMW = join CODE,'rmw'
JS = join(CODE,'js')
import {ntDecode} from '@rmw/nestedtext'
import_map = await do =>
  map = await ntDecode readFileSync(join(RMW,'mod.nt'),'utf8')
  (mod)=>
    map[mod] or mod

if process.argv[1] == decodeURI (new URL(import.meta.url)).pathname
  for await 路径 from walkRel RMW
    if not 路径.endsWith '.rmw'
      continue

    console.log chalk.yellow('\n→'+路径)
    out =join(JS,路径[...-4]+'.js')
    mkdirSync(dirname(out),recursive:true)

    out = createWriteStream out
    for await i from 编译(
      fsline join(RMW,路径)
      import_map
    )
      out.write i
      process.stdout.write i
    resolve = undefined
    p = new Promise(
      (r)=>
        resolve = r
        return
    )
    out.on('finish',resolve)
    out.end()
    await p
  process.exit()
