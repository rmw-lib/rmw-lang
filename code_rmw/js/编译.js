export const 行缩进=(文)=>{
  return 文.length-文.trimStart().length
}
export const 注释=(源码,行,结果)=>{}
export const 导入=(源码,行,结果,模块依赖)=>{
  const 源码行数=源码.length,
    块=[]
  let 开始=行,
    子模块,
    缩进,
    文,
    前缩进
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
      子模块=[]
      块.unshift([模块依赖(文.trimStart()),子模块])
      前缩进=缩进
    }else{
      子模块.push(文.trimStart())
    }
  }
  --行
  结果.push(JSON.stringify(块.reverse()))
  console.log(模块依赖,源码.slice(开始,行))
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
      行=导入(源码,行-1,结果,模块依赖)
      continue
    }
  }
  console.log(结果)
  return 结果
}