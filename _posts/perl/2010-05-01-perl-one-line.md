---
layout: post
category : tech
title:  "Perl : 单行命令"
tagline: ""
tags : ["perl"] 
---
{% include JB/setup %}

参考：http://sial.org/howto/perl/one-liner/

## 排序、反转文件内容
perl -e 'print sort <>' file

perl -e 'print reverse <>' file

## 把连续空行全换成1个空行(0777表示读入文件所有内容)
perl -0777 -pe 's/\n+/\n/g' file
