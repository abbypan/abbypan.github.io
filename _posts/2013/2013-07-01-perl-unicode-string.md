---
layout: post
category: program
title: "Perl : 中文 unicode, utf8 字符串转换"
tagline: ""
tags: [ "perl", "unicode", "utf8", "chinese" ] 
---
{% include JB/setup %}

## 把``\u4e2d\u56fd``转成``中国``

{% highlight perl %}
#!/usr/bin/perl
use JSON::PP;
use Encode;
use Encode::Locale;

my $r = JSON::PP->new->utf8->allow_nonref->decode(q["\u4e2d\u56fd"]);
print encode(locale =>$r), "\n";  #中国

my $ip_json = q[{"code":0,"data":{"country":"\u4e2d\u56fd","country_id":"CN","area":"\u534e\u4e1c","area_id":"300000","region":"\u5b89\u5fbd\u7701","region_id":"340000","city":"\u5408\u80a5\u5e02","city_id":"340100","county":"","county_id":"-1","isp":"\u6559\u80b2\u7f51","isp_id":"100027","ip":"202.38.64.1"}}];
my $r = decode_json($ip_json);
print encode(locale => $r->{data}{country}), "\n"; 
{% endhighlight %}

## 把中文内容转换成utf8编码串，一般用于web表单提交

{% highlight perl %}
#!/usr/bin/perl 
use utf8;
use Data::Dumper;
use Encode;

my $s = '中国 , 中国';
my $b = uc( unpack( "H*", encode( "utf8", $s ) ) );
$b =~ s/(..)/%$1/g;
print $b, "\n";
# %E4%B8%AD%E5%9B%BD%20%2C%20%E4%B8%AD%E5%9B%BD
{% endhighlight %}
