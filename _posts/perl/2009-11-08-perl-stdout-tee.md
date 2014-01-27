---
layout: post
category : tech
title:  "perl 同时把stdout的输出写入到三个文件中"
tagline: ""
tags : ["perl", "tee", "stdout"] 
---
{% include JB/setup %}

见：　Pleac Perl-File Access

{% highlight perl %}
open (STDOUT, "| tee file1 file2 file3") or die "Teeing off: $!\n";
print "whatever\n"                       or die "Writing: $!\n";
close(STDOUT)                            or die "Closing: $!\n";
{% endhighlight %}
