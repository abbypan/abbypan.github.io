---
layout: post
category : tech
title:  "R : 计算指定曲线在某条横线下方所夹的阴影面积"
tagline: ""
tags : [ "r", "area", "curve" ] 
---
{% include JB/setup %}

``area_line_curve.r`` 代码如下：

{% highlight r %}

#!/usr/bin/r

library(pracma) 

area_line_curve <- function(line_height, curve_df) {

    curve_df[ curve_df$V1>line_height, ] <- line_height
    curve_df$V2 <- line_height

    c <- length(curve_df[ ,1])
    return ((trapz(c(1:c),curve_df$V2) - trapz(c(1:c),curve_df$V1)))
}


opt <- commandArgs(trailingOnly = TRUE)
h <- as.double(opt[1])
d <- read.table(opt[2])

v <- area_line_curve(h,d) 
s <-  paste('height : ', h, ', area : ', v, sep=" ")
write(s[1], stdout())

{% endhighlight %}


``test.curve.txt``曲线数据：

{% highlight bash %}

91.99969481956207
91.99969481956207
90.99870298313878
89.99923704890516
88.99977111467155
87.99877927824826
87.99877927824826
87.99877927824826
87.99877927824826
87.99877927824826
88.99977111467155
90.99870298313878
91.99969481956207
92.99916075379568
93.99862668802929

{% endhighlight %}

假设横线高度为90，计算结果：

``test.curve.txt``曲线数据：

{% highlight bash %}
$ Rscript area_line_curve.r 90 test.curve.txt
height :  90 , area :  12.0073243305105
{% endhighlight %}
