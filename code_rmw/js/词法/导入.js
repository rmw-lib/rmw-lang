import * as 态 from '../态'

import { 行缩进 } from './小函数'
import { map } from 'lodash-es'
 // < 多行注释 = (源码,行,返)=>

 //  < 行

export const 空格切=(返,文)=>{
  const li=[]
  let t=[]
  const
    push=()=>{
      if(t.length){
        li.push(t.join(''))
      }
      t=[]
    }
  map(文,(c,pos)=>{
    if(c==' '){
      push()
    }(else{
      if(c=='#'){
         // TODO

      }else{
        t.push(c)
      }
    })
  })
  push()
  return li
}
export default (返,源码,行,列)=>{
  if(列!=0||(源码[行][0]!='>'))
    return 
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
        块=空格切(返,块)
        const
          终=块.pop()
        块.map((i)=>{
          返([...行列,态.导入,i])
        })
        返([...行列,态.导入,终,...导入内容])
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

 //      行 = 注释 源码,行,返

 //      continue

 //    }

    if(!块缩进||(块缩进>=缩进)){
      出()
      导入内容=[]
      块=文.trimStart()
      块缩进=缩进
    }else{
      导入内容=导入内容.concat(空格切(返,文.trimStart()))
    }
  }
  出()
  return 行
}