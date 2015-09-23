---
layout: post
category : tech
title:  "TLS for DNS"
tagline: ""
tags : [ "dns", "encrypt", "rfc" ] 
---
{% include JB/setup %}

https://tools.ietf.org/html/draft-ietf-dprive-start-tls-for-dns-00

这篇内容没啥特别的，就是下层协议支撑overlay跑应用

rcode 加一个 TO 标识，表示TLS OK

客户端查询 STARTTLS/CH/TXT

RTT增加，需要server端keep status，资源消耗增加

。。。

server端state tls优化，参考：[TLS Session Resumption without Server-Side State](https://tools.ietf.org/html/rfc5077)。其实这个有类似kerbos协议的意思，client hello时直接带SessionTicket。

还是觉得加密在 stub -> 递归 之间才搞得起来。。。
