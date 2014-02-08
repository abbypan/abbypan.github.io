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

##  WordPress搬家

先导出xml文件

超过2M的话，用divXML分割

再用Import WordPress的plugin导入

私人blog可以装Private Only的plugin，设置游客无法访问 

##  WordPress 迁回 Blogger

http://technospecs.wordpress.com/2012/07/01/wordpress-to-blogger-migration/

http://wordpress2blogger.appspot.com/
