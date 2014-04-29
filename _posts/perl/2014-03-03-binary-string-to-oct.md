---
layout: post
category : tech
title:  "Perl : 二进制(binary)字符串转十进制数(octal)"
tagline: "邮件"
tags : ["perl", "binary", "octal", "oct" ] 
---
{% include JB/setup %}

{% highlight perl %}
#!/usr/bin/perl
use strict;
use warnings;

my $bin = "11110000";
my $oct = oct("0b".$bin);
{% endhighlight %}
