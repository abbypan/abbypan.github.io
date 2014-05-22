---
layout: post
category : tech
title:  "Linux 环境下解压 Windows系统的压缩档(例如zip)里面的文件名乱码"
tagline: "笔记"
tags : ["zip", "unicode", "gbk", "utf8"] 
---
{% include JB/setup %}

需要安装 7za、convmv 

{% highlight bash %}
#!/bin/bash
LC_ALL=zh_CN.GBK 7za e $1 | grep '^Extracting' |awk '{print $2}'|xargs convmv -f gbk -t utf8 --notest --nosmart
{% endhighlight %}
