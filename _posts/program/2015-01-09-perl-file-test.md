---
layout: post
category : tech
title:  "Perl : 文件测试，例如找出20分钟内修改过的文件"
tagline: ""
tags : [ "perl", "file" ] 
---
{% include JB/setup %}

见 [-X perldoc](http://perldoc.perl.org/functions/-X.html)

{% highlight perl %}
my $mday = -M "some.txt";
my $minute = $mday * 24 * 60;
if($minute<=20){
    print "some.txt is modify < 20 min ago\n";
}
{% endhighlight %}
