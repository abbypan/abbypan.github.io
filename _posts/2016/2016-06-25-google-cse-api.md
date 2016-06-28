---
layout: post
category: tech
title:  "google custom search engine api 自定义搜索引擎api"
tagline: ""
tags: [ "google" ] 
---
{% include JB/setup %}

## 获取 search engine ID

[Google CSE SETUP](https://cse.google.com/cse/setup/) 

## 获取 api 的 key

[Setting up Google API keys](https://support.google.com/cloud/answer/6158862)

## custom search engine api

[Using REST to Invoke the CSE API](https://developers.google.com/custom-search/json-api/v1/using_rest)

[Google Custom Search JSON API](http://stackoverflow.com/questions/30565137/google-custom-search-json-api)

取下一页内容：start=11&num=10，注意 num<=10

## 例子

{% highlight perl %}
#!/usr/bin/perl
use strict;
use warnings;

use HTTP::Tiny;
use JSON;
use Encode;

use Data::Dumper;

# https://www.googleapis.com/customsearch/v1?key=$KEY&cx=$CX&q=$query&fields=items(title,link)
our $API_KEY = 'AIxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxY';
our $ENGINE_ID = '088888888888888888883:txxxxxxxxxo';

my $d = query_xs( { key => $API_KEY, cx => $ENGINE_ID, q=> '风尘叹', fields=> "items(title,link)"} );
print Dumper($d);
my $d2 = query_xs( { key => $API_KEY, cx => $ENGINE_ID, q=> '风尘叹', fields=> "items(title,link)",
        start => 11,
        num => 10,
    } );
print Dumper($d2);

sub query_xs {
    my ($r) = @_;

    my $s = join("&", map { "$_=$r->{$_}" } keys(%$r));
    my $url = "https://www.googleapis.com/customsearch/v1?$s";

    my $res = HTTP::Tiny->new->get($url);
    return unless $res->{success};

    my $d = decode_json($res->{content});
    return $d;
}
{% endhighlight %}
