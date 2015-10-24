---
layout: post
category : tech
title:  " Raspberry Pi 2 : 安装 archlinux "
tagline: ""
tags : [ "raspberry", "archlinux" ] 
---
{% include JB/setup %}

# 准备

网线

sd卡，刻录参考：[sdcard creation](http://archlinuxarm.org/platforms/armv7/broadcom/raspberry-pi-2)

无线网卡，例如rtl8188cus，淘宝22块包邮

# 安装

用网线将raspberry pi与路由器wlan口相连

将sd卡插入raspberry pi

通电开机

在路由器dhcp列表查看raspberry pi的IP，假设为 192.168.0.53

用默认用户密码 alarm:alarm，root:root登陆。

# 配置wifi

安装所需无线软件： pacman -S wireless_tools wpa_supplicant dialog

查看硬件是否正常： lsusb

假设essid为 myess，密码为 mypasswd

新建文件 /etc/netctl/wlan0-home ，内容如下：

{% highlight bash %}
Description='A simple WPA encrypted wireless connection'
Interface=wlan0
Connection=wireless
Security=wpa
IP=dhcp
ESSID='myess'
Key='mypasswd'
#Hidden=yes
#Priority=10
{% endhighlight %}

测试：netctl start wlan0-home

设置自动连接：netctl enable wlan0-home

重启，查看是否自动连接wifi

# 图形界面

pacman -S sudo lxde tigervnc

初始化vnc参考：[tigervnc](https://wiki.archlinux.org/index.php/TigerVNC)

vncserver -geometry 1440x800 -alwaysshared -dpi 96 :1

