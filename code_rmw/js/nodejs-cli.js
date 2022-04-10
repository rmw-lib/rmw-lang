import { readFileSync } from 'fs'
import { ntDecode } from '@rmw/nestedtext'
import { walkRel } from '@rmw/walk'
import thisdir from '@rmw/thisdir'

import yargs from 'yargs'

import { hideBin } from 'yargs/helpers'
const yargv=yargs(hideBin(process.argv)).command(
    '[path]',
    '编译文件或文件夹'
  ),
  argv=yargv.parse()
if(argv._[0]){
  console.log(1)
}else{
  yargv.showHelp()
}