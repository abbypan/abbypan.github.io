---
layout: post
category : tech
title:  "firefox 加速：把缓存cache从硬盘disk移到内存ram"
tagline: ""
tags : [ "firefox", "ram", "cache", "disk" ] 
---
{% include JB/setup %}

在firefox地址栏打开``about:config``

设置``browser.cache.disk.enable``为``false``

设置``browser.cache.memory.enable``为``true``

新建``browser.cache.memory.capacity``，整数，默认值为-1，也可以输入指定数值，如100000为100M

重启firefox
