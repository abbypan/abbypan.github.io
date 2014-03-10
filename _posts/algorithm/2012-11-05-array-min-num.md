---
layout: post
category : tech
title:  "给定一个无序数组，找出不在数组中的最小正整数"
tagline: ""
tags : [ "algorithm" ] 
---
{% include JB/setup %}

问题：给定一个无序数组，找出不在数组中的最小正整数，要求O(N)时间，O(1)空间

解法：

遍历数组(`1<=i<=n`，n为数组长度)，依次取出`x = a[i]`检查：
- 如果`1<= x <=n`，且i与x不相等，则交换`a[i]`与`a[x]`的取值，重新开始检查`a[i]`
- 如果`x = i`，则i++，进入下一轮
- 如果`x>n || x<1`，则`a[i]=0`，i++，进入下一轮

检查完毕之后，遍历数组，找出第一个`a[i]=0`的i。如果没找到，就取n+1

{% highlight perl %}
#!/usr/bin/perl
use strict;
use warnings;

my @a = ( 1, 2, 4, -1 );
my $n = scalar (@a);
unshift ( @a, 0 );

my $i = 1;
while ( $i <= $n ) {
    my $v = $a[$i];
    print "iter   : i = $i, v = $vn";

    if ( $v >= 1 and $v <= $n and $i != $v ) {
        @a[ $i, $v ] = @a[ $v, $i ];
        next;
    }

    $a[$i] = 0 unless ( $i == $v );
    $i++;

} ## end while ( $i <= $n )

my $j = $n + 1;
for my $i ( 1 .. $n ) {
    next unless ( $a[$i] == 0 );
    $j = $i;
    last;
}
print "result : $jn";
{% endhighlight %}
