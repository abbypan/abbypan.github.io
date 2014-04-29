---
layout: post
category : tech
title:  "perl : 用<>遍历读文件注意@ARGV是逐个shift读出的"
tagline: ""
tags : ["perl", "argv"] 
---
{% include JB/setup %}

用<>遍历读文件注意@ARGV是逐个shift读出的。

也就是说，<>读完之后，@ARGV的内容就清空了。

如果要保留原始参数最好先``my @save_args = @ARGV;``复制一份存着。

{% highlight perl %}
#!/usr/bin/perl
use Devel::Peek;

my $message="test";

print "ARGV[0] : $ARGV[0]\n";
while(<>){
        chomp;
        ($n, $name) = /(\d+)\t(.+)\r/;
        $x =$name.$message;
        print $x, "\n";
}
print "ARGV[0] : $ARGV[0]\n";
{% endhighlight %}
