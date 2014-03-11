---
layout: post
category : tech
title:  "rebol tips"
tagline: "笔记"
tags : [ "rebol" ] 
---
{% include JB/setup %}

## 载入其他文件
``do %/d/myfunctions.r``

## 写一个模块

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
