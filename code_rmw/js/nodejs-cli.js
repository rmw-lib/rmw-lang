import { readFileSync } from 'fs'
import { ntDecode } from '@rmw/nestedtext'
import { walkRel } from '@rmw/walk'
import thisdir from '@rmw/thisdir'

import chokidar from 'chokidar'

import yargs from 'yargs'

import { hideBin } from 'yargs/helpers'
import 编译 from './编译'

const yargv=yargs(hideBin(process.argv)).command(
    '[路径]',
    '编译文件或文件夹'
  ).option(
    'watch',
    {
      alias:'w',
      describe:'监控改动并实时编译'
    }
  ).option(
    'outdir',
    {
      alias:'o',
      describe:'文件输出目录'
    }
  ),
  argv=yargv.parse(),
  root=argv._[0],
  compile=(path)=>{
    编译(readFileSync(path,'utf8'))
  }
if(root){
  if(argv.watch){
    const
      watcher=chokidar.watch(root)
    watcher.on(
      'add',
      (path)=>{
        const pos=path.lastIndexOf('.')
        if(~pos){
          if(path.slice(pos+1)=='rmw'){
            compile(path)
          }
        }
      }
    )
  }
}else{
  yargv.showHelp()
}