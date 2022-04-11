import * as 态 from './态'

import 词法 from './词法'

export const 编译=[]
编译.push((模块依赖,模块,...导入)=>{ // 导入

  const 模块路径=`'${模块依赖(模块)}'`
  let r
  if(导入.length){
    r=[]
    导入=导入.map((x)=>{
        let c=x[0]
        if(c=='.'){
          x='default'+x.slice(1)
        }
        x=x.replace(':',' as ')
        if(c=='*'){
          r.push(`import ${x} from ${模块路径}`)
          x=0
        }
        return x
    },
    ).filter((x)=>{
      return x
    })
    if(导入.length){
      r.push(`import {${ 导入.join(',') }} from ${模块路径}`)
    }
    r=r.join('\n')+'\n'
  }else{
    r=`import ${模块.slice(模块.lastIndexOf("/")+1)} from ${模块路径}\n`
  }
  return r
})
编译.push((模块依赖,文)=>{ // 单行注释

  return '//'+文+'\n'
})
export default (源码,模块依赖)=>{
  const 果=词法(源码)
  const
  js=果.map(([行,列,state,...文])=>{
    return 编译[state](模块依赖,...文)
  },
  ).join('')
  console.log(js)
  return js
}