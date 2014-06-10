---
layout: post
category : tech
title:  "R : map/reduce 向量报错"
tagline: ""
tags : [ "r" ] 
---
{% include JB/setup %}

{% highlight r %}
> f1 <- function(n) { n*2 }
>  f2 <- function(n) { x <- c(1:n); y <- f1(x); Reduce('+', y) }
>  f3 <- function(n) { x <- c(1:n); y <- f2(x); Reduce('+', y) }
> f3(2)
[1] 2
警告信息：
In 1:n : 数值表达式一共有2元素: 只用了第一个
>  f4 <- function(n) { x <- c(1:n); y <- Map(f2,x); Reduce('+', y) }
> f4(2)
[1] 8
{% endhighlight %}

为什么   f1(x)正常，而 f2(x) 报错，要用Map(f2,x)才正常呢?

因为如果用 y <- f2(x) ，相当于 f2( c(1:n) )，到f2函数中，c(1: c(1:n)) 截断了
