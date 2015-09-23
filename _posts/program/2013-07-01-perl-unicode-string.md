---
layout: post
category : tech
title: "Perl : unicode 字符串转换"
tagline: ""
tags: [ "perl", "unicode" ] 
---
{% include JB/setup %}

例如把``\u4e2d\u56fd``转成``中国``

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
