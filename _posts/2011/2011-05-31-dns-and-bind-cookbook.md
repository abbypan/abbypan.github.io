---
layout: post
category: dns
title:  "Book: DNS and BIND Cookbook"
tagline: ""
tags : [ "dns", "bind" ] 
---
{% include JB/setup %}


几个注册局：APNIC/ARIN/RIPE

rr的顺序：``[owner] [TTL] [class] <type> <RDATA>``

2.6 注意不能直接在zone下直接配CNAME，否则就表示除了CNAME没别的rr，导致不可用

错误：foo.example. 600 IN CNAME www.foo.example. 

正确：foo.example. 600 IN A 202.38.75.11

因为cname有排他性，而foo.example.还要配NS啥的，所以会杯具

2.18 讲泛域名生效的情况，注意泛域名只针对未在zonefile里出现过的域名生效

批量指定rr配置：``$GENERATE 11-20 $.0.168.192.in-addr.arpa. PTR dhcp-$.foo.example.``
