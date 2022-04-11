import * as 态 from './态'

import { 行缩进 } from './词法/小函数'
import 导入 from './词法/导入'

export default (源码)=>{
  源码=源码.replaceAll('\r\n','\n').replaceAll('\r','\n').split('\n')
  let 行=0,
    列=0,
    行列
  const 源码行数=源码.length,
    果=[],
    返=果.push.bind(果)
  while(源码行数>行){
    行列=导入(返,源码,行,列)
    if(Array.isArray(行列)){
      [行,列]=行列
    }else{
      if(Number.isInteger(行列)){
        if(行列>行){
          列=0
          行=行列
          continue
        }
      }
    }
    ++行
  }
  return 果
}