---
layout: post
category : tech
title:  "Statistics::R"
tagline: "在perl中调用R进行统计"
tags : ["perl", "cpan", "r", "rjson", "json" ] 
---
{% include JB/setup %}

## 通过 Statistics::R 调用R进行统计

perl -> Statistics::R -> r -> rjson -> JSON

### d_stat.r 统计区间，频数，分位数

rjson 将 r 中的数据结构转换为json字符串

{% highlight r %}
library(rjson)
x <- list( range = range(d), quantile = quantile(d), table = table(d) )
s <- toJSON(x)
{% endhighlight %}

### 在perl中调用d_stat.r

将返回的json字符串解码成perl数据结构

{% highlight perl %}
#!/usr/bin/perl 
use strict;
use warnings;

use Data::Dump qw/dump/;
use Statistics::R;
use JSON;

my @t = ( (1) x 20, (2) x 30, (3) x 20 );

my $r = Statistics::R->new();
$r->set('d', \@t);
$r->run_from_file('d_stat.r');

my $s = $r->get('s');
my $s_ref = from_json $s;

dump($s_ref);
#{
      #quantile => { "0%" => 1, "100%" => 3, "25%" => 1, "50%" => 2, "75%" => 3 },
      #range    => [1, 3],
      #table    => { 1 => 20, 2 => 30, 3 => 20 },
#}
{% endhighlight %}
