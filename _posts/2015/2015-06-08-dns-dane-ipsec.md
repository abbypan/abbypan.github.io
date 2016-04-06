---
layout: post
category : tech
title:  "Opportunistic Encryption with DANE Semantics and IPsec: IPSECA"
tagline: ""
tags : [ "dns", "dane", "ipsec", "ipseca" ] 
---
{% include JB/setup %}

https://tools.ietf.org/html/draft-osterweil-dane-ipsec-02

英文单词：

eavesdrop 偷听

synergy 协同


新增一个IPSECA RR，RR格式采用DANE设计的样式，

recursive -> authority

_53.ns1.example.com. IN IPSECA (
  0 0 1 XXXXXXXXXXXXXX );

stub -> recursive

_53.2.1.168.192.in-addr.arpa. IN IPSECA (
 3 0 2 XXXXXXXXXXXXXX );

IPSEC的通信，初始化所需信息，通过IPSECA记录交互启动

。。。。。。

IPv6 内置 IPSEC，估计等IPv6推广开的时候，才有人推得动这个。。。

毕竟跟上层目前就可以用 over tls，dns confidential 啥的达到类似的效果，不用协议栈多打开ipv6支持。
