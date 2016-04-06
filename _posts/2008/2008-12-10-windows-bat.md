---
layout: post
category : tech
title:  "bat"
tagline: "笔记"
tags : ["windows", "bat"] 
---
{% include JB/setup %}

## for 循环
{% highlight bat %}
for %e in (File::Slurp Term::Menus)
do
ppm install %e
{% endhighlight %}
