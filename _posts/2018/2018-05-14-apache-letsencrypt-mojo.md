---
layout: post
category: tech
title:  "apache环境下perl Mojolicious站点letsencrypt证书renew失败的问题"
tagline: ""
tags: [ "letsencrypt", "tls", "apache", "perl" ] 
---
{% include JB/setup %}

* TOC
{:toc}

以debian为例

# 安装 certbot

{% highlight bash %}
apt-get install python-certbot-apache
certbot --apache
certbot --apache certonly
{% endhighlight %}

证书信息将保存在/etc/letsencrypt目录下

## 更新证书

    certbot renew --quiet

# 配置apache

例如添加某个域名 abc.xxx.com

    certbot certonly --webroot -w /var/www/abc/ -d abc.xxx.com

对应的apache配置文件示例如下：

{% highlight bash %}
<VirtualHost abc.xxx.com:80>
ServerName abc.xxx.com
DocumentRoot "/var/www/abc"
<Directory "/var/www/abc">
</Directory>
</VirtualHost>
<IfModule mod_ssl.c>
<VirtualHost abc.xxx.com:443>
ServerName abc.xxx.com
DocumentRoot "/var/www/abc"
<Directory "/var/www/abc">
</Directory>
SSLCertificateFile /etc/letsencrypt/live/abc.xxx.com/fullchain.pem
SSLCertificateKeyFile /etc/letsencrypt/live/abc.xxx.com/privkey.pem
Include /etc/letsencrypt/options-ssl-apache.conf
</VirtualHost>
</IfModule>
{% endhighlight %}

# Mojolicious 站点处理

假设目录为 /var/www/mojo，站点为 mojo.xxx.com

## mojo 目录示例

{% highlight perl %}
.
├── main.pl
└── static
    ├── css
    │   └── style.css
    ├── js
    ├── view
    └── .well-known

5 directories, 2 files
{% endhighlight %}

注意，main.pl为主文件。

通过Mojolicious::Static将static目录下的静态文件加入 / 路径，效果例如 http(s)://mojo.xxx.com/css/style.css 访问到style.css 样式表

view 目录下存放 Mojo::Template 的模板文件，例如 some.ep

.well-known 用于 letsencrypt 的证书处理

## mojo 程序示例, main.pl

{% highlight perl %}
#!/usr/bin/perl
use strict;
use warnings;

use FindBin;
use JSON;
use Mojo::Template;
use Mojolicious::Lite;
use Mojolicious::Static;

my $static = app->static();
push @{ $static->paths }, "$FindBin::RealBin/static";

get '/' => sub {
  my $self = shift;
  $self->render( template => 'index', format => 'html', handler => 'ep' );
};

post '/do_task' => sub {
  my $self = shift;
  my $text = $self->param('text');
  $self->render( text => "<pre>$text</pre>" );
};

app->start;

__DATA__

@@ index.html.ep
<html>
<head>
<meta http-equiv=Content-Type content="text/html;charset=utf-8">
<link rel="stylesheet" href="css/style.css" />
<title>...</title>
</head>
<body>
...
</body>
</html>
{% endhighlight %}

## apache 配置示例

注意443的配置是在certbot成功生成证书之后添加的

{% highlight bash %}
<VirtualHost mojo.xxx.com:80>
ServerName mojo.xxx.com
DocumentRoot "/var/www/mojo"
<Directory "/var/www/mojo">
</Directory>
<Location />
    SetHandler perl-script
    PerlHandler Plack::Handler::Apache2
    PerlSetVar psgi_app /var/www/mojo/main.pl
</Location>
</VirtualHost>
<IfModule mod_ssl.c>
<VirtualHost mojo.xxx.com:443>
ServerName mojo.xxx.com
DocumentRoot "/var/www/mojo"
SSLCertificateFile /etc/letsencrypt/live/mojo.xxx.com/fullchain.pem
SSLCertificateKeyFile /etc/letsencrypt/live/mojo.xxx.com/privkey.pem
Include /etc/letsencrypt/options-ssl-apache.conf
Options Indexes Includes FollowSymLinks Multiviews
<Directory "/var/www/mojo">
</Directory>
<Location />
    SetHandler perl-script
    PerlHandler Plack::Handler::Apache2
    PerlSetVar psgi_app /var/www/mojo/main.pl
</Location>
</VirtualHost>
</IfModule>
{% endhighlight %}

## certbot 生成证书 

注意这边目录写成 /var/www/mojo/static，因为我们在main.pl里指定了静态文件路径是static子目录

而letsencrypt需要检查的.well-known子目录在static下面

    certbot certonly --webroot -w /var/www/mojo/static -d mojo.xxx.com

如果写成 /var/www/mojo则会失败，原因是如果.well-known直接放在/var/www/mojo下，main.pl中并未设置route到该目录，因此certbot提示找不到路径，renew失败

示例letsencrypt证书更新配置文件（自动生成的）

/etc/letsencrypt/renewal/mojo.xxx.com.conf

{% highlight bash %}
# renew_before_expiry = 30 days
version = 0.10.2
archive_dir = /etc/letsencrypt/archive/mojo.xxx.com
cert = /etc/letsencrypt/live/mojo.xxx.com/cert.pem
privkey = /etc/letsencrypt/live/mojo.xxx.com/privkey.pem
chain = /etc/letsencrypt/live/mojo.xxx.com/chain.pem
fullchain = /etc/letsencrypt/live/mojo.xxx.com/fullchain.pem

# Options used in the renewal process
[renewalparams]
authenticator = webroot
installer = None
account = 6b0e486cbbe399702b1600fd60ea646a
webroot_path = /var/www/mojo/static,
[[webroot_map]]
mojo.xxx.com = /var/www/mojo/static
{% endhighlight %}
