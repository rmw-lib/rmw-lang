import * as 态 from './态'

import { 行缩进 } from './词法/小函数'
import 导入 from './词法/导入'

export default (源)=>{
  源=源.replaceAll('\r\n','\n').replaceAll('\r','\n').split('\n')
  let 行=0,
    列=0,
    行列
  const 源行数=源.length,
    果=[],
    返=(...参)=>{
      果.push(参)
    }
  while(源行数>行){
    列=0
    行=导入(返,源,行,列)
    if(行列>行){
      行=行列
      continue
    }
    ++行
  }
  return 果
}