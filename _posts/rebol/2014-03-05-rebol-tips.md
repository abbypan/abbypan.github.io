---
layout: post
category : tech
title:  "rebol tips"
tagline: "笔记"
tags : [ "rebol" ] 
---
{% include JB/setup %}

## 笔记 [REBOL_Programming](http://en.wikibooks.org/wiki/REBOL_Programming)

### 一些函数

| 函数 | 作用 |
| ---- | ---- |
| probe | 按原始格式显示word内容
| source | 显示函数代码
| what-dir | 当前目录
| list-dir | 当前目录下的内容
| change-dir | 切换目录
| size? | 文件大小
| modified? | 修改时间
| info? | 文件信息
| make-dir | 新建目录

### rebol to json

[json.r](http://www.rebol.org/view-script.r?script=json.r)

[rebol-to-json](http://rebol2.blogspot.it/2012/12/json.html)

### 数组操作

取出series_x第i个元素

``pick series_x i``

``series_x/:i``

修改series_x第i个元素

``poke series_x i 3``

``series_x/:i: 1``

### [Control](http://en.wikibooks.org/wiki/REBOL_Programming/Language_Features/Control)

if / either / unless 

case / swithch

for / forall / forskip / foreach / forever

loop / repeat / until / while / break

forall 会给出当前的位置，foreach只是取出当前的值。所以可以在forall循环中修改数组。

forskip 循环一次可以读多个元素

{% highlight rebol %}
areacodes: [
   "Ukiah"         707
   "San Francisco" 415
   "Sacramento"    916
]
forskip areacodes 2 [
    print [first areacodes "area code is" second areacodes]
]

my-series: [1 2 3 4]
forall my-series [ 
    my-series/1: my-series/1 * my-series/1
]
; myseries = [1 4 9 16]
{% endhighlight %}

### object

{% highlight rebol %}
shopping-basket: make object! [
  fruits: 5
  vegetables: 3
  dairy-products: 7
]

shopping-basket: make object! [fruits: 5 vegetables: 3 total: self/fruits + self/vegetables]
{% endhighlight %}

### [Dialects](http://en.wikibooks.org/wiki/REBOL_Programming/Language_Features/Dialects)

**重点**

自定义语法，数据+代码

{% highlight rebol %}
 data: load {"Bob" 21 bob@example.com $100}
 set [name age email payment] data
{% endhighlight %}

### 递归

参考 [函数式编程与Continuation/CPS](http://www.nowamagic.net/academy/detail/1220553)

## 笔记 [Bindology](http://www.rebol.net/wiki/Bindology)

**有闭包的例子**

{% highlight rebol %}
;赋值
x: "ab"
set 'x "cd"

;取值
:x
get 'x
{% endhighlight %}


### 载入其他文件

``do %/d/myfunctions.r``

``do/args %dalmations.r 101``

命令行参数 ``system/options/args``，``system/script/args``

## 笔记 [Learn REBOL](http://re-bol.com/rebol.html)

### 编译成.exe
["Compiling" REBOL Programs - Distributing Packaged .EXE Files](http://re-bol.com/rebol.html#section-7.3)

### 面向对象
{% highlight rebol %}
account: make object! [
    first-name: last-name: address: phone: email-address: none
]

user1: make account [
    first-name: "John"
    last-name: "Smith"
    address: "1234 Street Place  Cityville, USA 12345"
    email-address: "john@hisdomain.com"
    print-full: func [] [
        print first-name
        print last-name
    ]
]

user1/address
get in  user1 'address

set in  user1 'address "test addr"

user1/print-full
{% endhighlight %}

### 作为浏览器插件

[REBOL as a Browser Plugin](http://re-bol.com/rebol.html#section-9.11)

### 写一个模块

见：[Example of a minimal module](http://www.rebol.net/r3blogs/0344.html)

## 笔记 [REBOL 3 Concepts](http://www.rebol.com/r3/docs/concepts.html)

[Series Functions](http://www.rebol.com/r3/docs/concepts/series-functions.html) : 包括 insert / change / remove / reverse 等等

### copy 与 deep copy

嵌套block拷一份全新的要用 copy/deep

### [find 跟 replace](http://www.rebol.com/r3/docs/concepts/series-searching.html)

find/tail 是正着找，find/last 是反着找

find/match 返回的是匹配之后的position

replace/all 是全部替换

{% highlight rebol %}
;从block里抽
colors: [red green blue yellow blue orange gold]
probe find/part colors 'blue

;限定在text的top 15个字符
text: "Keep things as simple as you can."
print find/part text "as" 15
as simple as you can.
[blue yellow blue orange gold]

;限定在start的top n个字符找，n是end的position
text: {
    This is line one.
    This is line two.
}

start: find text "this"
end: find start newline
item: find/part start "line" end
print item
line one.

;循环
blk: load %script.r
while [blk: find blk string!] [
    print first blk
    blk: next blk
]

;在keep之后
str: "Keep things simple."
probe find/match str "keep"
" things simple."
{% endhighlight %}

### 通配符

{% highlight rebol %}
;任意字符
str: "abcdefg"
print find/any str "c*f"
cdefg

;任意单个字符
print find/any str "??d"
bcdefg
{% endhighlight %}

### find 与 select

find 是返回匹配位置之后的一个series，select是返回匹配位置之后的一个item

find之后，如果有remove，那么之前find找到的元素位置，有可能失效，得重新find才行

{% highlight rebol %}
email-book: [
    "George" harrison@guru.org
    "Paul" lefty@bass.edu
    "Ringo" richard@starkey.dom
    "Robert" service@yukon.dom
]

print select email-book "Paul"
lefty@bass.edu
{% endhighlight %}

### sort 排序

sort/skip 每x个元素分一组，按每组的第1个元素排序

sort/compare 在data后面传入排序函数

{% highlight rebol %}
names: [
    "Evie" "Jordan" 43 eve@jordan.dom
    "Matt" "Harrison" 87 matt@harrison.dom
    "Luke" "Skywader" 32 luke@skywader.dom
    "Beth" "Landwalker" 104 beth@landwalker.dom
    "Adam" "Beachcomber" 29 adam@bc.dom
]
sort/skip names 4
foreach [first-name last-name age email] names [
    print [first-name last-name age email]
]

ascend: func [a b] [a < b]
data: [100 101 -20 37 42 -4]
probe sort/compare data :ascend
[-20 -4 37 42 100 101]
{% endhighlight %}

### 集合函数

unique / intersect / union

{% highlight rebol %}
probe exclude [1 2 3 4] [1 2 3 5]
[4]

probe difference [1 2 3 4] [1 2 3 5]
[4 5]
{% endhighlight %}

### part / only / dup

{% highlight rebol %}
str: "abcdef"
blk: [1 2 3 4 5 6]

;把头3个元素换成[1 2 3 4]
change/part str [1 2 3 4] 3
probe str
1234def

;在尾部插入4个字符
insert/part tail str "-ghijkl" 4
probe str
1234def-ghi

;删掉从"d"(包含)到"-"(不包含)的内容
remove/part (find str "d") (find str "-")
probe str
1234-ghi

;从2开始插入一个block替换原有item，展开替换
>> blk: [1 2 3 4 5 6]
== [1 2 3 4 5 6]

>> change (find blk 2) [a b c]
== [5 6]

>> blk
== [1 a b c 5 6]

;把2替换成一个block，insert/only类似
>> blk: [1 2 3 4 5 6]
== [1 2 3 4 5 6]

>> change/only (find blk 2) [a b c]
== [3 4 5 6]

>> blk
== [1 [a b c] 3 4 5 6]

;重复替换4次
str: "abcdefghi"
change/dup str "*" 4
probe str
****efghi
{% endhighlight %}

### 数组 array

{% highlight rebol %}
;一维数组
arr: array 5
probe arr
[none none none none none]

;二维数组
arr: array [2 3]
probe arr
[[none none none] [none none none]]

;初始化
arr: array/initial 5 0
probe arr
[0 0 0 0 0]
{% endhighlight %}

### ``()``相归于一层解引用

嵌套多层时，需要添加``deep``关键字

{% highlight rebol %}
probe compose ["The time is" (now/time)]
["The time is" 10:32:45]

probe compose [a b ([c d])]
[a b c d]

probe compose [a b [c (d e)]]
[a b [c (d e)]]

probe compose/deep [a b [c (d e)]]
[a b [c d e]]
{% endhighlight %}

### 字符串函数

[string functions](http://www.rebol.com/r3/docs/concepts/strings-functions.html)

### form / join / mold 等函数

参考：[reform](http://www.rebol.com/docs/words/wreform.html)

参考：[string convert](http://www.rebol.com/r3/docs/concepts/strings-convert.html)

form 与 reform 的区别是，reform 会对block中的变量求值，form直接当字符串用

form / reform 输出合并后的字符串（中间加空格）

join / rejoin 合并后的类型与第一个参数保持一致，如果最后是字符串（中间不加空格）

mold / remold 输出rebol数据格式的字符串

{% highlight rebol %}
probe reform ["the time is:" now/time]
"the time is: 0:59:58"

probe form ["the time is:" now/time]
"the time is: now/time"
{% endhighlight %}

### checksum

支持 hash、crc等校验和

### 路径处理

``to-file`` 把字符串或block转换为file name或file path

``split-path`` 拆分目录、文件名

``clean-path`` 把相对路径换成绝对路径

### 读写内容

{% highlight rebol %}
;一次读入
text: read %file.txt

;按行读入
lines: read/lines %file.txt

;读入binary数据，例如图片、音乐等
data: read/binary %file.bin

;读入网页
web: read http://www.rebol.com/test.txt

;下载网页
write %test.txt read http:/www.rebol.com/test.txt

;添加
write/append %file.txt "more text"

;按行写入
write/lines %file.txt lines

;写入binary数据
write/binary %file.bin data

;将指定内容远程写入ftp
write ftp://ftp.domain.com/file.txt "save this text"

;读取目录下文件列表
print read %intro/
{% endhighlight %}

### 文件操作

{% highlight rebol %}
;删除多个文件
delete [ %file1 %file2 ]

;删除目录
delete %dir/

;以file开头的文件
delete/any %file*

;以secret.开头，后面加一个字符的文件
delete/any %secret.?
{% endhighlight %}

### 函数

{% highlight rebol %}
sum: func [
    "Return the sum of two numbers."
    arg1 [number! tuple! money!] "first number"
    arg2 [number! tuple! money!] "second number"
][
    arg1 + arg2
]

print sum 1.2.3 3.2.1
4.4.4

;反引号不对变量求值
say: func [`var] [probe var]
say test
test


;refinements设置
sum: func [
    "Return the sum of two numbers."
    arg1 [number!] "first number"
    arg2 [number!] "second number"
    /times "multiply the result"
    amount [number!] "how many times"
][
    either times [arg1 + arg2 * amount][arg1 + arg2]
]
print sum/times 123 321 10
4440
{% endhighlight %}

### local变量

{% highlight rebol %}
;local表示变量只在当前func中生效
average: func [
    block "Block of numbers"
    /local total length
][
    total: 0
    length: length? block
    foreach num block [total: total + num]
    either length > 0 [total / length][0]
]

;匿名函数
sort/compare data func [a b] [a > b]
{% endhighlight %}


local变量如果是block，重复调用记得用copy

{% highlight rebol %}
star-name: func [name] [
    stars: copy "**"
    insert next stars name
    stars
]
print star-name "test"
*test*
print star-name "this"
*this*

;注意这边"**"的local变量没有被copy
star-name: func [name] [
    stars: "**"
    insert next stars name
    stars
]
print star-name "test"
*test*
print star-name "this"
*thistest*
{% endhighlight %}

### 计算

[常见math函数](http://www.rebol.com/r3/docs/concepts/math-operators.html)

{% highlight rebol %}
print 20 / 10
2

print 21 // 10
1

;向量加法
print 100x200 + 10x20
110x220

print 10.20.30 / 10
1.2.3

print 1.2.3 * 1.2.3
1.4.9
{% endhighlight %}
