---
layout: post
category: tech
title:  "Perl : Mojolicious::Lite 的app部署到 Apache 上"
tagline: "Web"
tags: [ "perl", "cpan", "mojo", "web", "apache" ] 
---
{% include JB/setup %}

假设app为 /var/www/someapp/main.pl，部署web路径为 http://someweb.xxx.com/

app的代码示例参考[Mojolicious::Lite](https://metacpan.org/pod/Mojolicious::Lite)

安装plack库
{% highlight bash %}
cpanm Plack::Handler::Apache2
{% endhighlight %}

在apache的http.conf的配置示例
{% highlight bash %}
<VirtualHost *:80>
DocumentRoot "/var/www/someapp"
ServerName someweb.xxx.com
<Directory "/var/www/someapp">
Order deny,allow
Allow from all
</Directory>
<Location />
    SetHandler perl-script
    PerlHandler Plack::Handler::Apache2
    PerlSetVar psgi_app /var/www/someapp/main.pl
</Location>
</VirtualHost>
{% endhighlight %}
