export const 行缩进=(文)=>{
  return 文.length-文.trimStart().length
}
export const 导入=(源码,行)=>{
  const 源码行数=源码.length
  let 缩进,
    文
  while(源码行数>行){
    文=源码[行++]
    缩进=行缩进(文)
    if(缩进==文.length){
      continue
    }
    if(缩进==0){
      break
    }
  }
  return 行-1
}
export default (源码)=>{
  源码=源码.replaceAll('\r\n','\n').replaceAll('\r','\n').split('\n')
  let 行=0,
    列,
    文,
    文字数,
    缩进
  const 源码行数=源码.length
  while(源码行数>行){
    文=源码[行++]
    缩进=行缩进(文)
    列=缩进
    if(缩进==0&&文[列]=='>'){
      行=导入(源码,行)
      continue
    }
    console.log(文)
  }
}