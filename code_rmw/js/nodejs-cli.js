import { readFileSync } from 'fs'
import { ntDecode } from '@rmw/nestedtext'
import { walkRel } from '@rmw/walk'
import thisdir from '@rmw/thisdir'

import yargs from 'yargs/yargs'

import { hideBin } from 'yargs/helpers'
yargs(hideBin(process.argv)).command(
  '[dir]',
  'compile file or dir',
  (yargs)=>{
    console.log(yargs)
  }
)