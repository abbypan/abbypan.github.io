---
layout: post
category : perl
title:  "Data::Dumper"
tagline: "笔记"
tags : ["perl", "cpan", "unicode" ] 
---
{% include JB/setup %}

## use utf8 之后 print Dumper 只会打出 unicode 字符

见：[Data::Dumper and UTF-8 by jl_post@hotmail.com](http://groups.google.com/group/comp.lang.perl.misc/browse_thread/thread/6fbd3733c9c56186?hl=en)

用eval执行Dumper，再进行print。

{% highlight perl %}
#!/usr/bin/perl
#此文件是utf8编码
use utf8;
use Data::Dumper;
$Data::Dumper::Terse = 1; # 不要输出 "$VAR1 = "

binmode(STDOUT,":encoding(cp936)");

my $china="中国";
print Dumper($china);  # "\x{4e2d}\x{56fd}"
print eval Dumper($china),"\n";  #中国
{% endhighlight %}
