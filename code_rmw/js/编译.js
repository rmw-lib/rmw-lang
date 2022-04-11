import * as 态 from './态'

import 词法 from './词法'

export default (源码,模块依赖)=>{
  const 结果=词法(源码)
  结果.map(([行,列,state,...li])=>{
    console.log(state)
    if(态.导入==state){
      console.log(li)
    }
  })
  return ''
}