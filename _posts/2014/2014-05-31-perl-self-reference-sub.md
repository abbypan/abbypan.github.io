---
layout: post
category : tech
title:  "Perl : 用 __SUB__ 新建匿名递归函数"
tagline: ""
tags : [ "perl", "cpan", "sub" ] 
---
{% include JB/setup %}

见 mastering perl : chapter 8 dynamic subroutines

{% highlight perl %}
#!/usr/bin/perl

my $factorial = sub {
    my ($n) = @_;
    return 1 if $n==1;
    return ( $n * __SUB__->($n-1) );
}
{% endhighlight %}
