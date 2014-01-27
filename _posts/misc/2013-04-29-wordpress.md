---
layout: post
category : tech
title:  "WordPress"
tagline: "笔记"
tags : ["wordpress"] 
---
{% include JB/setup %}

##  WordPress 需要访问您网页服务器的权限

假设：
- web server：apache
- wordpress的目录：/var/www/wp

解决：
{% highlight bash %}
> chown www-data -R /var/www/wp
> chmod 775 -R /var/www/wp 
{% endhighlight %}