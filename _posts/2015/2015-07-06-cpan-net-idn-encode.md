---
layout: post
category : tech
title:  "cpan : Net::IDN::Encode 中文域名punycode转换"
tagline: ""
tags : [ "domain", "cpan", "perl", "idn", "punycode" ] 
---
{% include JB/setup %}

$in 为命令行输入的中文域名，例如

海底捞.中国  => xn--fxt99hsvk.xn--fiqs8s.

{% highlight perl %}
#!/usr/bin/perl
use Encode;
use Encode::Locale;
use Net::IDN::Encode ':all';
use utf8;

my ($in) = @ARGV;
my $unicode = decode(locale=>$in);
my $e = domain_to_ascii($unicode);

print $e,"\n";
{% endhighlight %}
