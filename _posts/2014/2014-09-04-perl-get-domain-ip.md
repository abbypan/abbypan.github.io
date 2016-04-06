---
layout: post
category : tech
title:  "Perl : 调用 Socket 接口 获取指定域名的IP"
tagline: ""
tags : [ "perl", "domain", "ip", "socket" ] 
---
{% include JB/setup %}

{% highlight perl %}
use Socket;
my $dom = 'www.google.com';
my $ip = inet_ntoa(inet_aton($dom));
{% endhighlight %}
