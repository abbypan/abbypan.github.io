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
our $ENGINE_ID CX = '088888888888888888883:txxxxxxxxxo';

my $d = query_xs($API_KEY, $ENGINE_ID, '风尘叹', "items(title,link)");
print Dumper($d);

sub query_xs {
    my ($api_key, $engine_id, $query, $fields) = @_;

    my $url = "https://www.googleapis.com/customsearch/v1?key=$api_key&cx=$engine_id&q=$query";
    $url .= "&fields=$fields" if($fields);

    my $res = HTTP::Tiny->new->get($url);
    return unless $res->{success};

    my $r = decode_json($res->{content});
    return $r;
}
{% endhighlight %}
