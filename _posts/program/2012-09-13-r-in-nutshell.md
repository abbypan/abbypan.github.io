---
layout: post
category : tech
title:  "笔记：r in a nutshell"
tagline: ""
tags : [ "r" ] 
---
{% include JB/setup %}

## 数据集为consumption，每种食物Food单独画一副点图，横轴为Year，纵轴为Amount

{% highlight r %}
> library(lattice)
> dotplot(Amount~Year|Food, consumption)
{% endhighlight %}

{% highlight r %}
fun(sym) <- val 相当于 `fun<-`(sym,val)
{% endhighlight %}

## 循环
{% highlight r %}
> i <- 5
> repeat {if (i > 25) break else {print(i); i <- i + 5;}}
{% endhighlight %}

for (i in seq(from=5,to=25,by=5)) print(i)

## 矩阵赋值
{% highlight r %}
m[1:2,1:2] <- matrix(c(1001:1004),nrow=2,ncol=2)
{% endhighlight %}

my.quotes.narrow有3列 $Date、$symbol、$Close，每行表示某天某股票收盘价

my.quotes.oc有4列 $Date、$symbol、$Open、$Close，每行表示某天某股票开盘价、收盘价


## 列为symbol各项s1/s2/s3...，按行列出s1/s2/s3对应的Close值

{% highlight r %}
unstack(my.quotes.narrow,form=Close~symbol) 
{% endhighlight %}

## 还原成两列 Close，symbol，注意此时其他列信息是没有的

stack(unstacked) 

## reshape

reshape(my.quotes.narrow,idvar="symbol",timevar="Date",direction="wide") 

结果为 symbol Close.2009-03-02 Close.2009-02-02

reshape(my.quotes.oc,timevar="Date",idvar="symbol",direction="wide")

结果为 symbol Close.2009-03-02 Open.2009-03-02 Close.2009-02-02 Open.2009-02-02 
