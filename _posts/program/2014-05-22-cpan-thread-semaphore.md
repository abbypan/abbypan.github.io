---
layout: post
category : tech
title:  "perl : Thread::Semaphore 多线程 示例"
tagline: ""
tags : [ "cpan", "thread" ]
---
{% include JB/setup %}

{% highlight perl %}
#!/usr/bin/perl
use threads;
use threads::shared;
use Thread::Semaphore;

my $max_process_num = 3;
my $sem = Thread::Semaphore->new($max_process_num);

my $arr = [ 4, 1, 2, 3, 5, 6 ];
my $work_func = sub {
    my ($i) = @_;

    my $s = $arr->[$i] * $arr->[$i];
    $sem->up;

    return [ $i, $s ];
};

my @threads = map {
    $sem->down;
    threads->create( $work_func, $_ );
} 0 .. $#$arr;

my @res;
for (@threads) {
    my $r = $_->join;
    $res[ $r->[0] ] = $r->[1];
}

print $_, "\n" for @res;
{% endhighlight %}
