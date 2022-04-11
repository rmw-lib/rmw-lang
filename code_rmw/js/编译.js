import 词法 from './词法'

export default (源码,模块依赖)=>{
  const 结果=词法(源码)
  console.log(结果)
  return ''
}