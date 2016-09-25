---
layout: post
category : tech
title:  "vps 安装图形界面，设置远程登录vnc"
tagline: ""
tags : [ "vps", "linux", "vnc" ] 
---
{% include JB/setup %}

## 参考

[Ubuntu VPS配置轻量级图形桌面LXDE和VNC](http://www.lijiejie.com/ubuntu-vps-config-lxde-vnc/)

[小内存Linux安装LXDE挂机](http://blog.nicky1605.com/small-memory-linux-installed-lxde-hang-up.html)

[windows下使用vnc viewer远程连接Linux桌面](http://nameyjj.blog.51cto.com/788669/582965)

## 安装配置

以debian为例，安装

{% highlight bash %}
$ apt-get install tightvncserver xfce4

$ vncpasswd
#设置密码
{% endhighlight %}

配置 ~/.vnc/xstartup

{% highlight bash %}
#!/bin/bash
export XKL_XMODMAP_DISABLE=1
startxfce4 &
{% endhighlight %}

运行vncserver，默认端口为5900，假设开启:1000

{% highlight bash %}
$ vncserver -geometry 1600x900 :1000
{% endhighlight %}

vnc客户端的连接端口为6900，常用的vnc客户端例如realvnc
