import * as 态 from './态'

import { 行缩进 } from './词法/小函数'
import 导入 from './词法/导入'

export default (源码)=>{
  源码=源码.replaceAll('\r\n','\n').replaceAll('\r','\n').split('\n')
  let 行=0,
    列,
    文,
    文字数,
    缩进
  const 源码行数=源码.length,
    结果=[]
  while(源码行数>行){
    文=源码[行++]
    缩进=行缩进(文)
    列=缩进
    if(缩进==0&&文[列]=='>'){
      源码[行-1]=' '+文.slice(1)
      行=导入(源码,行,结果)
      continue
    }
  }
  return 结果
}