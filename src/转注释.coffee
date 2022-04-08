#!/usr/bin/env coffee

export default (词)=>
  if 词.charAt(1) == '|'
    return '/*'+词[2..]+'*/'
  else
    return ' //'+词[1..]+'\n'
