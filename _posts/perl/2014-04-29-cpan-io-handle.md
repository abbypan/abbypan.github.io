---
layout: post
category : tech
title:  "Perl IO::Handle 指定autoflush，立即写入"
tagline: "file"
tags : ["perl", "cpan", "file" ] 
---
{% include JB/setup %}

autoflush 表示不缓冲，立即写入

{% highlight perl %}
use IO::Handle;

open my $fhw, '>', $filename;
$fhw->autoflush(1);

print $fhw $data1, "\n";
#....
print $fhw $datan, "\n";

close $fhw;
{% endhighlight %}
