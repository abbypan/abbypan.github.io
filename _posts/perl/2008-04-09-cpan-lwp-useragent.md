---
layout: post
category : tech
title:  "perl LWP::UserAgent 提取网页内容"
tagline: "crawler"
tags : ["perl", "cpan", "crawler", "web" ] 
---
{% include JB/setup %}

## 用 LWP提交WEB页面的POST表单

参考：
- [Web Basics with LWP](http://www.perl.com/pub/a/2002/08/20/perlandlwp.html?page=1)
- LWP內的模組](http://blog.pixnet.net/jck11/post/5045536)

{% highlight perl %}
#!/usr/bin/perl
use LWP::UserAgent;

my $browser = LWP::UserAgent->new;
$browser->cookie_jar({});

push @{ $browser->requests_redirectable }, 'POST';
my $response = $browser->post($url,content => [ %form ] );

print $response->error_as_HTML unless $response->is_success;
print $response->content;
{% endhighlight %}

## 指定Referer

{% highlight perl %}
#!/usr/bin/perl
use LWP::UserAgent;

my $browser = LWP::UserAgent->new;
$browser->cookie_jar({});

my $url=$site.'/literature/indextext9.asp?free=100112699&page=101605396';  
my $req = new HTTP::Request GET => $url;  
$req->referer($site);  

my $res = $browser->request($req);  
{% endhighlight %}

## 通过http proxy代理获取网页

见：http://community.activestate.com/forum-topic/lwp-https-requests-proxy 
