---
layout: post
category : tech
title:  "Perl Scalar::Util 避免循环引用"
tagline: "Circular References"
tags : ["perl", "ref", "cpan" ] 
---
{% include JB/setup %}

{% highlight perl %}
use Scalar::Util 'weaken';
{% endhighlight %}
