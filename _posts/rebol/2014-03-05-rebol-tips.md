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

### rebol to json

[json.r](http://www.rebol.org/view-script.r?script=json.r)

[rebol-to-json](http://rebol2.blogspot.it/2012/12/json.html)


### 载入其他文件
``do %/d/myfunctions.r``

### 写一个模块

见：[Example of a minimal module](http://www.rebol.net/r3blogs/0344.html)

## form / join / mold 等函数

参考：http://www.rebol.com/docs/words/wreform.html

form 与 reform 的区别是，reform 会对block中的变量求值，form直接当字符串用

form / reform 输出合并后的字符串（中间加空格）

{% highlight rebol %}
probe reform ["the time is:" now/time]
"the time is: 0:59:58"

probe form ["the time is:" now/time]
"the time is: now/time"
{% endhighlight %}

join / rejoin 合并后的类型与第一个参数保持一致，如果最后是字符串（中间不加空格）

mold / remold 输出rebol数据格式的字符串
