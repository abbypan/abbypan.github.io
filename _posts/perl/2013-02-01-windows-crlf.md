---
layout: post
category : tech
title:  "Perl : linux下读取取windows 文本文件，打印乱码"
tagline: ""
tags : ["perl", "cpan", "crlf" ]
---
{% include JB/setup %}

windows下新建的文本文件拿到linux下读要记得加 :crlf，不然结尾字符串会多一个\r出来，打印字符串的时候就会出错

{% highlight perl %}
#!/usr/bin/perl
use Devel::Peek;

my $message="test";

open my $fh, '<:crlf', $ARGV[0];
while(<$fh>){
        chomp;
        ($n, $name) = /(\d+)\t(.+)/;
        $x =$name.$message;
        print $x, "\n";
        Dump($x);
}
close $fh;

while(<>){
        chomp;
        ($n, $name) = /(\d+)\t(.+)/;
        $x =$name.$message;
        print $x, "\n";
        Dump($x);
}
{% endhighlight %}
