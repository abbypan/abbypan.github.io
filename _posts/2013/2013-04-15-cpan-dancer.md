---
layout: post
category : tech
title:  "perl Dancer 网页(web)开发框架"
tagline: "web"
tags : ["perl", "cpan", "mvc", "apache", "dancer" ] 
---
{% include JB/setup %}

{% highlight perl %}
{% endhighlight %}

## 在 Apache 上部署 Dancer 

参考：[Running_from_Apache_with_Plack](http://search.cpan.org/dist/Dancer/lib/Dancer/Deployment.pod#Running_from_Apache_with_Plack)

这边是ubuntu环境，安装 apache、mod_perl

安装 perl模块：Plack、Plack::Handler::Apache2

假设Dancer部署的域名为  mydancer.myxxxdom.com、部署的目录为/var/www/mydancer

在/etc/apache2/httpd.conf中新增如下配置

        <VirtualHost *:80>
        DocumentRoot "/var/www/mydancer"
        ServerName mydancer.myxxxdom.com
        <Directory "/var/www/mydancer">
        Order deny,allow

        Allow from all
        </Directory>
        <Location />
            SetHandler perl-script
            PerlHandler Plack::Handler::Apache2
            PerlSetVar psgi_app /var/www/mydancer/bin/app.pl
        </Location>

        </VirtualHost>

重启apache 
