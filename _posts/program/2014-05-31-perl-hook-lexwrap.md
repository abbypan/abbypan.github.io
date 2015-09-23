---
layout: post
category : tech
title:  "Perl : 用 Hook::LexWrap 在函数调用前、后加临时操作"
tagline: ""
tags : [ "perl", "cpan", "wrap" ] 
---
{% include JB/setup %}

见 mastering perl : chapter 3 perl debuggers

{% highlight perl %}
#!/usr/bin/perl
use Hook::LexWrap qw/wrap/;

wrap add, 
    pre => sub { print "get arguments : @_\n" }, 
    post => sub { print "return value : $_[-1][0]\n" }
    ;

print "the sum : ", add(1, 2) , "\n";

sub add {
    my ($n, $m) = @_;
    return $n+$m;
}

#get arguments : 1 2 ARRAY(0xdd4cb8)
#return value : 3
#the sum : 3
{% endhighlight %}
