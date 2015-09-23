---
layout: post
category : tech
title:  "Mordern Perl 笔记"
tagline: ""
tags : [ "booknote", "perl" ] 
---
{% include JB/setup %}

## 正则匹配的``\G``，记住上回匹配的位置

{% highlight perl %}
while ($contents =~ /\G(\w{3})(\w{3})(\w{4})/g)
{
push @numbers, "($1) $2-$3";
}
{% endhighlight %}

## The Empty List

my $count = () = get_all_clown_hats();   #$count表示get_all_clown_hats()返回的数组大小
