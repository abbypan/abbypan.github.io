---
layout: post
category : tech
title:  "Perl : 用 B::Deparse 取得子程序的文本内容 code text"
tagline: ""
tags : [ "code", "text", "cpan", "perl" ]
---
{% include JB/setup %}

{% highlight perl %}
use B::Deparse;

my $pr = B::Deparse->new;

my $code = sub { $_[0]*$_[0] };
my $code_text = $pr->coderef2text($code);

print $code_text, "\n";
{% endhighlight %}
