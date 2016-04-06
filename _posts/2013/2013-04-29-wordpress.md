---
layout: post
category : tech
title:  "WordPress 搬家"
tagline: "笔记"
tags : [ "wordpress" ] 
---
{% include JB/setup %}

## 迁移wordpress站点，更新数据表

假设原站点为 http://xxx.old.com ，新站点为 http://yyy.new.com

登入mysql的wp数据库，执行

{% highlight bash %}
> update wp_options set option_value='http://yyy.new.com' where option_value='http://xxx.old.com';

> update wp_posts set post_content = replace (post_content,'xxx.old.com','yyy.new.com')
{% endhighlight %}

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

注意参考：http://www.douban.com/note/58389625/

##  WordPress 迁回 Blogger

http://technospecs.wordpress.com/2012/07/01/wordpress-to-blogger-migration/

http://wordpress2blogger.appspot.com/


## 插件

WordPress Backup to Dropbox 将wordpress定期备份到dropbox

cos-html-cache 页面缓存

Yet Another Related Posts Plugin 相关文章

Adminer  查看wordpress数据库连接信息

FileBrowser 管理wordpress目录下的文件 
