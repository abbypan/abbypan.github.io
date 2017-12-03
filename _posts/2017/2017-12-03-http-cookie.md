---
layout: post
category: tech
title: "笔记：curl / perl HTTP::Tiny 使用浏览器保存的 http cookie"
tagline: ""
tags: [ "cookie", "cookie_jar" ]
---
{% include JB/setup %}

* TOC
{:toc}

以firefox为例

# 取出cookie

## cookie string 方式

提取出HTTP的Cookie头部字段，假设为 "name1=value1; name2=value2"

从firefox的HTTP请求记录中直接提取Cookie

或者

从cookies.sqlite文件中提取指定域名的Cookie信息拼接成cookie string

{% highlight perl %}
    $cookie_file='/home/xxx/.mozilla/firefox/xxxx/cookies.sqlite';
    $dom = 'jjwxc.net';
    my $sqlite3_cookie = `sqlite3 "$cookie_file" "select name,value from moz_cookies where baseDomain='$dom'"`;
    my @segment = map { my @c = split /\|/; "$c[0]=$c[1]" } ( split /\n/, $sqlite3_cookie );
    my $cookie_string = join( "; ", @segment );
{% endhighlight %}

## cookie file 方式

导出 Netscape HTTP Cookie File 格式的文本文件，假设文件名为 cookie.txt

使用 [extract_cookies.sh](https://gist.github.com/spk/5014421) 工具自动导出

或者 

firefox安装 [Export Cookies](https://addons.mozilla.org/en-US/firefox/addon/export-cookies/) 扩展手动导出


# curl 使用上述 cookie

    $ curl -b "name1=value1; name2=value2" "http://m.jjwxc.net/vip/217747/33" -o 33.html

    $ curl -b cookie.txt -c cookie.txt "http://m.jjwxc.net/vip/217747/33" -o 33.html

# perl 的 HTTP::Tiny 模块使用上述cookie

HTTP::Tiny 速度比较快，Cookie功能可以直接使用HTTP::CookieJar的接口，也可以自定义支持add和cookie_header的简单接口

## HTTP::CookieJar

HTTP::CookieJar的load_cookies负责导入cookie数组，单行cookie示例

    PSTM=1512280000; Expires=Fri, 21 Dec 2085 10:26:40 GMT; Domain=baidu.com; Path=/; Creation_Time=1512285153; Last_Access_Time=1512285153

{% highlight perl %}
#!/usr/bin/perl
use HTTP::Tiny;
use HTTP::CookieJar;
use Path::Tiny;
 
my $jar_file = path("jar.txt");
$jar_file->touch;
 
my $jar = HTTP::CookieJar->new->load_cookies( $jar_file->lines );
my $ua = HTTP::Tiny->new( cookie_jar => $jar );
$ua->get('http://www.baidu.com');
 
$jar_file->spew( join "\n", $jar->dump_cookies( {persistent => 1} ) );
{% endhighlight %}

## 自定义支持add和cookie_header的简单接口

阅读 HTTP::CookieJar 的源码，add函数负责增加name=value字段（不对cookie做调整则可以忽略），cookie_header负责提供"name1=value1; name2=value2"格式的cookie_string

示例如下

{% highlight perl %}
package Novel::Robot::Browser::CookieJar;

sub new {
  my ( $self, %opt ) = @_;
  bless \%opt, __PACKAGE__;
}

sub add {
  my ( $self, $url, $cookie ) = @_;
  return $self->{cookie};
}

sub cookie_header {
  my ( $self, $url ) = @_;
  return $self->{cookie};
}

1;
{% endhighlight %}

{% highlight perl %}
#!/usr/bin/perl
use HTTP::Tiny;
use Novel::Robot::Browser::CookieJar;

my $jar = Novel::Robot::Browser::CookieJar->new();
my $ua = HTTP::Tiny->new( cookie_jar => $jar );

my $cookie_string = "name1=value1; name2=value2";
$ua->{cookie_jar}{cookie} = $cookie_string;

my $url = "http://m.jjwxc.net/vip/217747/33";
my $res=$ua->get($url);
print $res->{content};
{% endhighlight %}
