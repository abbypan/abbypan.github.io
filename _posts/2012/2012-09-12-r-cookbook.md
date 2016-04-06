---
layout: post
category : tech
title:  "笔记 : R cookbook (R语言经典实例)"
tagline: ""
tags : [ "r" ] 
---
{% include JB/setup %}


## 取pkgname里内置的dsname变量

data(dsname, package="pkgname") 

## 选CRAN镜像

chooseCRANmirror() 

## 调用R脚本scriptfile，其中取命令行参数列表``argv <- commandArgs(TRUE)``

Rscript scriptfile arg1 arg2 arg3 

## 取表格数据

XML库中的readHTMLTable

## 取满足条件的子集

{% highlight r %}
subset(dfrm, select=c(predictor,response), subset=(response > 0)) 
{% endhighlight %}

## with可以省敲字

{% highlight r %}
z <- (suburbs$pop - mean(suburbs$pop)) / sd(suburbs$pop)
z <- with(suburbs, (pop - mean(pop)) / sd(pop))
{% endhighlight %}

## 按Origin分组，得到对应MPG.city的列表

{% highlight r %}
split(Cars93$MPG.city, Cars93$Origin)  
{% endhighlight %}

## 时间序列

{% highlight r %}
seq(from=s, to=e, by =1)
seq(from=s, by=1, len=4)
{% endhighlight %}

## 统计initial各种值出现的次数

table(initial) 

initial值为行，outcome值为列，统计对应出现的次数

table(initial, outcome) 

## 求x中小于4的元素比例

mean(x<4) 

## 区间统计

{% highlight r %}
> breaks <- c(-3,0,2)
> f <- cut(x, breaks)
{% endhighlight %}

也可以继续打标签：

{% highlight r %}
f <- cut(x, breaks, labels=c("Low","Middle","High"))
{% endhighlight %}

## 排序

按key排序
{% highlight r %}
dfrm <- dfrm[order(dfrm$key),]  
{% endhighlight %}

先按month，再按day排序
{% highlight r %}
dfrm[order(dfrm$month,dfrm$day),] 
{% endhighlight %}

## 对list求均值前，先unlist成vector

mean(unlist(numbers)) 

## 对list里的元素逐一执行function

do.call(function, list) 

{% highlight r %}
> lists <- list(col1=list(7,8,9), col2=list(70,80,90), col3=list(700,800,900))
> do.call(cbind, lists)
    col1 col2 col3
    [1,] 7 70 700
    [2,] 8 80 800
    [3,] 9 90 900
{% endhighlight %}

## 时间序列

a/b 访问某个网站上各种网页的顺序 能分析出 a/b 是同一类用户？统计果然神奇。
