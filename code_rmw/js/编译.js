import * as 态 from './态'

import 词法 from './词法'

export default (源码,模块依赖)=>{
  const 果=词法(源码)
  果.map(([行,列,state,...li])=>{
    if(态.导入==state){
      console.log(li)
    }
  })
  return ''
}