---
layout: post
category : tech
title:  "rebol 笔记: 字符串处理函数"
tagline: ""
tags : [ "rebol" ] 
---
{% include JB/setup %}

[R3 More Blocks](http://video.respectech.com:8080/tutorial/r3/index.r3?cgi=TIfWJ6JHi25XqIfcy8fGiUp6s/vFHkD+nDL+0KWDZYuSLAEZwAAdr9IZfyeCS29gde7TxYERS4ST8Tjy)

[R3 Text Strings](http://video.respectech.com:8080/tutorial/r3/index.r3?cgi=1R5PvjveEvfOMR5FUl5fENPjKmJch9lnBatnSTxavFJL9VgP/hZNf0WAuMg9YpkJXQvAjrd6jETGl16UTg--)

## 跳转

first / second 

myblock/3  相当于 pick myblock 3

next / back

head / tail

at myblock 3  指针跳转到第3个元素前面

skip myblock 3 指针往前跳过3个元素，指到第4个元素前面，->

如果skip myblock -3 就是往后跳过3个元素，<-

## 修改

insert mystring "add to head"

append mystring "add to tail"

change 修改myblock为指定内容，与perl中的substr有相通之处

{% highlight rebol %}
>> myblock: [the quick brown fox]
== [the quick brown fox]
>> myblock: next myblock
== [quick brown fox]
>> change/part myblock [black] 2
== [fox]
>> head myblock
== [the black fox]
{% endhighlight %}
