import * as 态 from '../态'

import { 行缩进 } from './小函数'
import { map } from 'lodash-es'
 // < 多行注释 = (源码,行,结果)=>

 //  -- 行

export const 空格切=(文)=>{
  const li=[],
    t=[]
  const
    push=()=>{
      if(t.length){
        li.push(t.join(''))
      }
    }
  map(文,(c)=>{
    if(c!=' '){
      t.push(c)
    }else{
      push()
    }
  })
  push()
  return li
}
export default (源码,行,结果)=>{
  if(源码[行][0]!='>')
    return 行
  let 开始=行,
    块,
    导入内容,
    块缩进,
    行列,
    缩进,
    文
  const 源码行数=源码.length,
    出=()=>{
      if(块){
        结果.push([...行列,态.导入,块,...导入内容])
      }
      行列=[行,缩进]
    }
  while(源码行数>行){
    文=源码[行]
    if(行==开始){
      文=' '+文.slice(1)
    }
    ++行
    缩进=行缩进(文)
    if(缩进==文.length){
      continue
    }
    if(缩进==0){
      break
    }
 //if(文[缩进] == '#'){

 //      行 = 注释 源码,行,结果

 //      continue

 //    }

    if(!块缩进||(块缩进>=缩进)){
      出()
      导入内容=[]
      块=文.trimStart()
      块缩进=缩进
    }else{
      导入内容=导入内容.concat(空格切(文.trimStart()))
    }
  }
  出()
  return --行
}