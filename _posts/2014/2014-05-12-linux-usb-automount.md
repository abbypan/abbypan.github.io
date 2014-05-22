---
layout: post
category : tech
title:  "Linux : 自动挂载(mount) usb / iphone"
tagline: ""
tags : [ "linux", "usb", "iphone", "automount", "mount" ] 
---
{% include JB/setup %}

以 archlinux + openbox 为例

# usb自动挂载

{% highlight bash %}
pacman -S thunar thunar-volman
{% endhighlight %}

在``~/.xinitrc``中指定``exec dbus-launch openbox-session``

# iphone挂载成usb设备

参考 [iphone tethering](https://wiki.archlinux.org/index.php/IPhone_Tethering)
