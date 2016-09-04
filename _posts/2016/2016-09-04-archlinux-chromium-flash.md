---
layout: post
category: tech
title:  "archlinux chromium flashplayer 配置"
tagline: ""
tags: [ "archlinux", "chromium", "flashplayer" ] 
---
{% include JB/setup %}

编译

{% highlight bash %}
git clone https://aur.archlinux.org/chromium-pepper-flash.git
cd chromium-pepper-flash
makepkg
cd pkg/chromium-pepper-flash
sudo cp -r usr/* /usr/
cp usr/lib/PepperFlash/libpepflashplayer.so /usr/lib/chromium/
mkdir /etc/chromium
{% endhighlight %}

假设chromium-pepper-flash的版本为22.0.0.209，编辑``/etc/chromium/default``文件，添加内容

{% highlight bash %}
CHROMIUM_FLAGS="--ppapi-flash-path=/usr/lib/chromium/libpepflashplayer.so --ppapi-flash-version=22.0.0.209"
{% endhighlight %}
