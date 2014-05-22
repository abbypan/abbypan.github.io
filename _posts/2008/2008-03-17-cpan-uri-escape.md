---
layout: post
category : tech
title:  "perl URI::Escape 处理网址"
tagline: "url"
tags : ["perl", "cpan", "url", "uri" ] 
---
{% include JB/setup %}

{% highlight perl %}
use URI::Escape;
$safe = uri_escape("10% is enough\n");
$verysafe = uri_escape("foo", "\0-\377");
$str  = uri_unescape($safe);
{% endhighlight %}
