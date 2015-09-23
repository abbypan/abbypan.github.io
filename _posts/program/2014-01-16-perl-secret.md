---
layout: post
category : tech
title:  "perl一些特殊操作符"
tagline: "随便看看就好"
tags : ["perl" ] 
---
{% include JB/setup %}
见：[perl secret](https://metacpan.org/pod/release/BOOK/perlsecret-1.004/lib/perlsecret.pod)

``}{``是模拟END block的最后一行操作

{% highlight bash %}
$ perl -lne '}{print$.'
{% endhighlight %}

``<~>``是HOME环境变量 ``$ENV{HOME}``
