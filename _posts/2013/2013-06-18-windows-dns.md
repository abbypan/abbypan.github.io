---
layout: post
category : tech
title:  "Windows : DNS 客户端 查询递归的 处理步骤"
tagline: ""
tags : ["windows", "dns"] 
---
{% include JB/setup %}

 
见：[DNS server selection by Brent Hu](http://social.technet.microsoft.com/Forums/en-US/winserverNIS/thread/963abb4f-c050-4725-9a92-2be59be3d1d9)

dns client service：
-  先从 优先级最高的适配器 读取配置的首个dns，发查询，等1秒
-  1秒内没收到应答，读取所有适配器配置的首个dns，发查询，等2秒
-  2秒内没收到应答，读取所有适配器配置的所有dns，发查询，等2秒
-  2秒内没收到应答，读取所有适配器配置的所有dns，发查询，等4秒
-  4秒内没收到应答，读取所有适配器配置的所有dns，发查询，等8秒
-  8秒内没收到应答，就返回time out
-  中间如果有收到应答，就将应答结果写入缓存，停止查询

并且，如果某个适配器上配置的所有dns都没有返回过dns应答包，那么在下一个30秒内，dns client service再收到任何发往这个适配器的、这些dns的查询包，都不去查，而是直接返回time out

参考 [DNS Processes and Interactions](http://technet.microsoft.com/en-us/library/cc772774%28WS.10%29.aspx#w2k3tr_dns_how_gaxc)
