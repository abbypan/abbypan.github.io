---
layout: post
category : tech
title:  "rebol 笔记: 嵌套函数 nesting function"
tagline: "指针"
tags : [ "rebol", "function", "point" ] 
---
{% include JB/setup %}

见： [R3 Nesting Functions](http://video.respectech.com:8080/tutorial/r3/index.r3?cgi=erHgEZRxvVhhnrHq/fHwv3xMhc3zKHbIqgTI5pOVc52EOhdvnh5FQyWGZG/0454hm1KL/3sEMlsmRGWrYJ0/g8ph)

其实就是指针的偏移

{% highlight rebol %}
>> myblock: [the fox jumped over the dogs]
== [the fox jumped over the dogs]
>> head insert back tail insert next myblock [quick brown] [lazy]
== [the quick brown fox jumped over the lazy dogs]
>> head insert back tail insert next myblock [quick brown] [lazy]
== [the quick brown quick brown fox jumped over the lazy lazy dogs]
{% endhighlight %}

next myblock 指到 "fox" 前面

insert (next myblock) [quick brown] ：变成 the quick brown fox ...

tail 跳到 myblock 字符串 末尾

back 跳到 "dogs" 的前面

insert (back (tail (insert (next myblock) [quick brown]))) [lazy] ：变成 ... the lazy dogs 

head 再跳回 myblock 字符串 开头
