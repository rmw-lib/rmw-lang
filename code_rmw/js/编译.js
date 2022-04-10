export const 行缩进=(文)=>{
  return 文.length-文.trimStart().length
}
export const 注释=(源码,行,结果)=>{
  --行
}
export const 导入=(源码,行,结果,模块依赖)=>{
  --行
  let 开始=行,
    块,
    导入内容,
    前缩进,
    缩进,
    文
  const 源码行数=源码.length,
    出=()=>{
      if(!块)return;
      const 暂=[导入,行,缩进,块]
      if(导入内容.length){
        暂.push(导入内容)
      }
      结果.push(暂)
    }
  while(源码行数>行){
    文=源码[行++]
    缩进=行缩进(文)
    if(缩进==文.length){
      continue
    }
    if(缩进==0){
      break
    }
    if(文[缩进]=='#'){
      行=注释(源码,行,结果)
      continue
    }
    if(!前缩进||(前缩进>=缩进)){
      出()
      导入内容=[]
      块=模块依赖(文.trimStart())
      前缩进=缩进
    }else{
      导入内容.push(文.trimStart())
    }
  }
  出()
  --行
  return 行
}
export default (源码,模块依赖)=>{
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
      行=导入(源码,行,结果,模块依赖)
      continue
    }
  }
  console.log(结果)
  return 结果
}