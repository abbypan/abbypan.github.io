---
layout: post
category : tech
title:  "dl-ssl.google.com 速度慢的问题"
tagline: ""
tags : [ "google" ] 
---
{% include JB/setup %}

参考：[关于Google近期不能访问问题](http://www.newsmth.net/nForum/#!article/GoogleTech/30862?p=1)

在``/etc/hosts``中添加一行

{% highlight perl %}
203.208.46.200 dl-ssl.google.com 
{% endhighlight %}

比直接ping dl-ssl.google.com 得到的ip快的多
