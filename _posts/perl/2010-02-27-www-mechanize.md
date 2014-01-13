---
layout: post
category : tech
title:  "WWW::Mechanize"
tagline: "crawler"
tags : ["perl", "cpan", "web", "crawler" ] 
---
{% include JB/setup %}

## 用WWW::Mechanize取html时的乱码问题

用WWW::Mechanize取html时总是有部分解出乱码，原因：
- WWW::Mechanize的content()函数会自动调用decoded_content()解码，失败才返回原始的LWP::UserAgent::content()内容，具体见[leeym-踩到 WWW::Mechanize 的地雷](http://blog.leeym.com/2007/03/wwwmechanize.html)。
- decoded_content()解码后的部分内容有时也是乱码。

因此，WWW::Mechanize模块直接取content()或decoded_content()都不靠谱。

一种解决方案是：
- 指定decoded_content(charset => 'none')避免自动解码，取回原始html内容
- 再用Encode::Detect::CJK::detect()检测其编码
- 根据测出来的编码将原始html解码成unicode处理

{% highlight perl %}
#!/usr/bin/perl
use strict;
use warnings;
use utf8;
use Carp;
use Encode::Detect::CJK qw/detect/;
use Encode;
use WWW::Mechanize;
 
my $browser =
    WWW::Mechanize->new( onerror => undef, onwarn => \&Carp::carp, );
$browser->add_header(
    'Accept-Language' => "zh-cn,zh-tw;q=0.7,en-us,*;q=0.3" );
$browser->add_header( 'Accept-Charset' =>
        'gb2312,gbk,utf-8,gb18030,big5,;q=0.7,*;q=0.3' );
$browser->add_header( 'Keep-Alive' => 300 );
$browser->add_header( 'Connection' => 'keep-alive' );
 
my $url  = 'http://www.jjwxc.net/onebook.php?novelid=404264&chapterid=4';
#my $url  = 'http://www.dddbbb.net/93345_5194303.html';
my $flag = $browser->get($url);
exit unless ( $browser->success() );
 
#将html内容解码成unicode
my $html = $browser->response->decoded_content( charset => 'none' );
my $charset = detect($html);
$html = decode( $charset, $html, Encode::FB_XMLCREF );
 
$html=~s[<font color='#.{6}'>.*?</font>][]g;
open my $fh, '>:utf8', 'test.html';
print $fh $html;
close $fh;
{% endhighlight %}

## GET 请求失败(403等等)时自动exit

初始化时，禁掉autocheck就好了：
``my $mech = WWW::Mechanize->new(autocheck=>0);``

## 显示下载进度

{% highlight perl %}
#!/usr/bin/perl
use strict;
use warnings;
  
use WWW::Mechanize;
my $browser = WWW::Mechanize->new();
$browser->show_progress(1);
$browser->get('http://www.ustc.edu.cn');
{% endhighlight %}

显示的进度样式如下： ** GET http://www.ustc.edu.cn ==> 200 OK (3s)

LWP::UserAgent 也是一样，``show_progress``
