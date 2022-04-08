<!-- 本文件由 ./make.md 自动生成，请不要直接修改此文件 -->

# @rmw/lang


推荐字体 FiraCode Nerd Font Mono

从这里下载

https://github.com/ryanoasis/nerd-fonts/tree/master/patched-fonts/FiraCode

比如我的 alacritty.yml 配置是

```
font:
  size: 16
  normal:
    family: FiraCode Nerd Font Mono
    style: Retina
```

六书是中国造字的原则︰象形、指事、形声、会意、转注、假借

想设计一个没有关键字的编程语言

可以先作为javascript的方言 ， 类似 coffeescript

## 当前文件路径

.url
.地址

.path
.路径

.run process.argv[1] == .file
.运行

## 变量声明

变量会在第一次赋值的时候用let自动声明
该语法主要用于提升作用域

= a,b,c

= x = 1

=
  a = 1
  b = 2
  c = 3

## 常量声明

- x = 1
-
  y = 2
  z = 3

## 作用域

  x = 1

  |
    x = 2
    $log x

  $log x

输出

2

1


## 求余

-7 % 5 == -2 # The remainder of 7 / 5
-7 %% 5 == 3 # n %% 5 is always between 0 and 4

## 求幂

$log 2 ** 3 # 输出 8

## 整除

$log 3 // 2 # 输出 1

## and

a && b

## or

a || b

## 位运算

~
|
^

## 单引号字符串

'string'

'string
is
string'

## 正则

/\d+/

## 双引号字符串

  "
    a
      b
    c
  "

等价于 'a\n b\nc'


## 字符串数组

yaml

"
  a

    b
  c
"

等价于 'a\nb\nc'
"
a
  b
c
"[]

等价于 'a\nb\nc'.split('\n')

也就是 ['a','b','c']

## 字符串模板

template = 'index.html'

`this is {template}`

## if else

  a > b ?
    $log a
  :
    $log b

## if elseif else

```
a > b ?
  $log a
: a == b
  $log a, b
:
  $log b
```

## switch

a ?
  = 1
    $log 'a=1'
  = 2,3
    $log 'b=1'
  ?
    $log 'else'

## try catch finally

?
  ^Error 'error'
:err
  $log err
.
  $log 'finally'

## 解包

  a,b = [1,2]

  a,b = b,a

  a,b, = [1,2,3,4]

  {a,b:B} = {a:1,b:2,c:3}

## 切片

  li[1:3]
  li[3:]
  li[:]
  li[-1:]
  li[-5:-1]
  li[::-1]

## 异步

a =< http.get 'https://rmw.link'

a =<< xxx()

a = await await xxx()

## 遍历列表

```rmw
i .. li
  $log i
```

```rmw
i .< gen()
  $log
```
等价于
for i of await gen()

.代表遍历
<代表await
.< 代表 遍历+await，也就是of await

```
i <. gen()
```

.代表遍历
<代表await
<. 代表 await+遍历，也就是await i of

等价于
for await i of gen()

## 基于迭代器遍历列表同时解包

  li = [
    [1,2,3]
    [1,2,3,4]
  ]

  a,b, ..li
    $log a,b

## 基于迭代器遍历并从0开始计数

  i = ..li,n
    $log n,i

## 基于迭代器遍历并从1开始计数

  i = ..li,n=1
    $log n,i

## 循环并从1开始计数

  i = ..li,n

## 基于数字循环

  i = ..0:li.length
  i = ..0:len=li.length


## 死循环

  ..
    $log 'loop'

## 死循环并计数

  ..n
    $log n

## break中断循环

  ..
    $log 'loop'
    ^

### break中断两层循环
  ..
    ..
      ^^

### break中断三层循环

  ..
    ..
      ..
        ^^^

## continue

  ..n
    n%2 ?
      >
    :
      $log n

## continue 两层

  ..n
    n%2 ?
      >>
    :
      $log n

## continue 三层

  ..
    ..
      ..n
        n%2 ?
          >>>
        :
          $log n

## label 跳出多重循环

out:
  ..a
    b = ..[1,2,3]
      if b > 2
        out^
      $log a,b

## label 继续多重循环

out:
  ..a
    b = ..[1,2,3]
      if b == 2
        out>
      $log a,b

## 函数定义

func = =>
  < a+b

func = (a,b)=> # 声明的时候如果有参数就必须加括号
  < a+b

func = (
  a
  b
) =>
  < a+b

## 定义并运行函数

$do =>
  $log 1

## 可变参数

func = a,b,..c =>
  < a,b,c

## 有this的函数

func = ->
  $log .

## 生成器(会是一个有this的函数)

func = =>
  i = ..[1,2,3]
    << i

i = ..func()
  $log i

输出

1
2
3

## yield from

func = =>
  << 1
  <<< func()

## 类定义

和函数定义的区别是，不在同一行并且缩进

Admin =

  (.name)->

  .str:->
      < `user {.name}`

  :kind = 1

## 类继承

Admin : User =
  ->
    ^() # 父类的构造函数


## 类原型

$log Admin:

## 类实例

user = User 'tom'

$log user.name
$log user.str()
$log user:kind
$log User:kind
$log user?.kind

## 字典

dict1 = a:1,b:2

dict2 = {
  a :
    b :
      c :
        d : 1
        e : 2
}

dict3 = {
  .. dict1
  .. dict2
  c : 1
}

## 注释

`#`

## 多行注释

```
#|
  多行
  注释
```

开始和结束的缩进需要一致，这样就可以嵌套多行注释

## import 导入模块

> fs net
>
  fs
    . writeFileSync readFileSync
  http
    get post

## await import 异步导入模块

fs =< > fs

{readFileSync} =< > fs

{readFileSync:read} =< > fs

## export 导出变量

< x = =>

< = main = ->

<= main = ->

< ->
  console.log 1


## export from

<> fs

export * from fs

<> fs net

export * from fs
export * from net

<> fs:xxx

export * as xxx from fs

<> fs
  . writeFileSync

export {default,writeFileSync} from fs





## 中文全局对象

globalThis (nodejs中的global，浏览器中的windows在新js标准中称之为globalThis)

$this $予

Map 映射
Set 集合
Date 日期
undefined 未知
NaN  无效
null 空

console.log $log 💬
console.error $err ❌

main = =>
  code != 0 ?
    💬 'console.log'
  :
    ❌ 'console.error'

## iterm2 + Fira Code 配置

```
brew install font-fira-code font-fira-code iterm2
```
![](https://raw.githubusercontent.com/gcxfd/img/gh-pages/APN5LJ.png)

显示效果如下

![](https://raw.githubusercontent.com/gcxfd/img/gh-pages/18iz8Y.png)

### 关于

本项目隶属于**人民网络([rmw.link](//rmw.link))** 代码计划。

![人民网络](https://raw.githubusercontent.com/rmw-link/logo/master/rmw.red.bg.svg)