---
layout: post
category : tech
title:  "笔记 : R in action (R 语言实战)"
tagline: ""
tags : [ "r" ] 
---
{% include JB/setup %}

指定因子的levels：
{% highlight r %}
status <- factor(status, order=TRUE, levels=c('Poor', 'Improved', 'Excellent'))
{% endhighlight %}

为类别型变量创建值标签，例如性别：
{% highlight r %}
 data$gender <- factor(data$gender, levels = c(1,2), labels = c("male","female"))
{% endhighlight %}

类似于perl中的map :
{% highlight r %}
mydata <- transform(mydata, sumx= x1+x2, meanx=(x1+x2)/2)
{% endhighlight %}

移除含有NA的行：
{% highlight r %}
newdata <- na.omit(leadership)
{% endhighlight %}

按性别升序，按年龄降序 排序：
{% highlight r %}
nexwdata <-  data[order(gender, -age),]
{% endhighlight %}

RCurl & XML 包可以抓取并分析网页数据

选取数据
{% highlight r %}
 newdata <- data[which(data$gender=="M" & data$age > 30), ]
{% endhighlight %}

对矩阵或数据框的指定列进行均值0标准差1的标准化
{% highlight r %}
newdata <- scale(mydata)
{% endhighlight %}

对矩阵或数据框的指定列进行均值50标准差10的标准化转换
{% highlight r %}
newdata <- scale(mydata)*10 + 50
{% endhighlight %}

抽出指定分位数
{% highlight r %}
y <- quantile(score, c(.8, .6, .4, .2))
{% endhighlight %}

R的最大优点之一就是用户可以自行添加函数？！黑的漂亮，这年头还有啥语言不能自己添加函数。。。

我们无论在何时分析数据，第一件要做的事情就是观察它。对于每个变量，哪些值是最常见的？值域是大是小？是否有不寻常的观测？

第6章讲基本图形，很不错

二维统计(行是Treatment，列是Improved）
{% highlight r %}
mytable <- xtabs( ~ Treatment + Improved, data=Arthritis)
{% endhighlight %}

**我们主要的困难有3个：发现有趣的问题，设计一个有用的、可以测量的响应变量，以及收集合适的数据**（说的太对了！）

第11章讲进阶图形，很不错

折线图，阶梯折线图

corrgram包提供的相关图
