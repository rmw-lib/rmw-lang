import 词法 from './词法'

export default (源码,模块依赖)=>{
  const
    结果=词法(源码)
  结果.map(console.log)
  return ''
}