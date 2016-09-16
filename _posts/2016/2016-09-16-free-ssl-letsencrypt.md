---
layout: post
category: tech
title:  "使用 letsencrypt 的 ssl 免费证书 配置 apache 站点"
tagline: ""
tags: [ "ssl", "apache", "tls", "certificate" ] 
---
{% include JB/setup %}

## 资料

[let's encrypt getting started](https://letsencrypt.org/getting-started/)

[certbot user guide](https://certbot.eff.org/docs/using.html#apache)


## 安装 certbot 

以debian为例，安装

{% highlight bash %}
apt-get install python-certbot-apache 
certbot --apache
certbot --apache certonly
{% endhighlight %}

证书信息将保存在``/etc/letsencrypt``目录下

## 更新证书

手动测试更新

{% highlight bash %}
certbot renew --dry-run
{% endhighlight %}

更新，可加入crontab，定期自动更新

{% highlight bash %}
certbot renew --quiet 
{% endhighlight %}

## 添加域名

例如添加某个域名 abc.xxx.com

{% highlight bash %}
certbot certonly --webroot -w /var/www/abc/ -d abc.xxx.com
{% endhighlight %}

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
