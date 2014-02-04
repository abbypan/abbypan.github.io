---
layout: post
category : tech
title:  "Perl : 删掉中间全空的目录"
tagline: ""
tags : ["perl"] 
---
{% include JB/setup %}

见：[Learning Perl Challenge: Remove intermediate directories](http://www.learning-perl.com/?p=389)

{% highlight perl %}
#!/usr/bin/perl
use strict;
use warnings;

use File::Path qw(remove_tree);
use File::Copy qw(move);

my ($dir) = @ARGV;

short_dir($dir);

sub short_dir {
    my ($start, $now) = @_;
    return unless(-d $start);
    $now ||= $start;

    my @subnodes = glob("$now/*");
    my @subdirs = grep { -d $_ } @subnodes;

    if($#subdirs>0){
        short_dir($_) for @subdirs;
    }elsif($#subdirs==0){
        short_dir($start, $subdirs[0]);
    }else{
        return if($start eq $now);
        move($_, "$start/") for @subnodes;   

        my @dirs = grep { -d $_ } glob("$start/*");
        remove_tree($dirs[0]);
    }
}
{% endhighlight %}
