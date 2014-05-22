---
layout: post
category : tech
title:  "symbol table / typeglob"
tagline: ""
tags : ["perl", "symbol", "typeglob" ] 
---
{% include JB/setup %}

参考： [perl编程: 浅谈typeglob](http://www.cnitblog.com/gyn/archive/2006/04/13/9094.html)

Perl通过symbol table查找变量名

再根据变量名对应的glob查找对应的type引用
