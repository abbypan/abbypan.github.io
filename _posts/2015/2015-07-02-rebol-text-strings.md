---
layout: post
category : tech
title:  "rebol 笔记: 字符串处理函数"
tagline: ""
tags : [ "rebol", "function", "text" ] 
---
{% include JB/setup %}

见：[R3 Text Strings](http://video.respectech.com:8080/tutorial/r3/index.r3?cgi=1R5PvjveEvfOMR5FUl5fENPjKmJch9lnBatnSTxavFJL9VgP/hZNf0WAuMg9YpkJXQvAjrd6jETGl16UTg--)

first / second 

myblock/3  相当于 pick myblock 3

next / back

head / tail

at myblock 3  指针跳转到第3个元素前面

skip myblock 3 指针往前跳过3个元素，指到第4个元素前面，->

如果skip myblock -3 就是往后跳过3个元素，<-

insert mystring "add to head"

append mystring "add to tail"
