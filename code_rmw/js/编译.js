export default (txt)=>{
  txt=txt.replaceAll('\r\n','\n').replaceAll('\r','\n').split('\n')
  console.log(txt)
}