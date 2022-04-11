import { join } from 'path'
import { readFileSync,writeFileSync } from 'fs'
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
  utf8='utf8',
  compile=(root,path,outdir,模块依赖)=>{
    console.log('→',path)
    writeFileSync(
      join(outdir,path.slice(0,-4)+'.js'),
      编译(
        readFileSync(join(root,path),utf8),
        模块依赖
      )
    )
  }
if(root){
  if(argv.watch){
    const
      watcher=chokidar.watch(root)
    const
      mod_nt=await(ntDecode(readFileSync(join(root,'mod.nt'),utf8)))
    const
      模块依赖=(mod)=>{
        return mod_nt[mod]||mod
      }
    const
      outdir=argv.outdir||root
    const
      文件改动=(path)=>{
        path=path.slice(root.length+1)
        const pos=path.lastIndexOf('.')
        if(~pos){
          if(path.slice(pos+1)=='rmw'){
            compile(root,path,outdir,模块依赖)
          }
        }
      }
    watcher.on('add',文件改动)
    watcher.on('change',文件改动)
  }
}else{
  yargv.showHelp()
}