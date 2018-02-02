---
layout: post
category: tech
title:  "DNSSD Privacy"
tagline: ""
tags: [ "dns", "dnssd", "privacy" ] 
---
{% include JB/setup %}

* TOC
{:toc}

# 资料

[DNS-SD Privacy](https://datatracker.ietf.org/meeting/100/materials/slides-100-dnssd-04-stuart-privacy/)

https://mailarchive.ietf.org/arch/msg/dnssd/g25DoRJUZu4fGdJ0PkHqbW-EQhk

https://mailarchive.ietf.org/arch/msg/dnssd/58a8lFvzsHBmOQ0AlYCXSweFFXQ

https://tools.ietf.org/html/draft-ietf-dnssd-privacy-03

https://tools.ietf.org/html/draft-ietf-dnssd-pairing-03

https://tools.ietf.org/html/draft-ietf-dnssd-pairing-info-00

# 背景

apple提供本地服务发现，共享数据等功能

其中涉及dnssd/mdns的解析查询，例如 someuser._photo_tcp.local 之类

由于初始设计是本地局域网使用，因此没有任何隐私及验证的设计

然而在公共wifi的场景下，就会产生严重的安全与隐私问题

# 问题 

安全与隐私的粒度设计选择

按设备验证 or 按应用验证 or 按用户验证，取舍与系统安全相关

验证方面：共享对称密钥／PGP式的非对称密钥交互／服务端公钥

服务域名方面，在于服务子域名的hash混淆

client及server端的握手随机数选择，与时间相关的nounce

密钥泄露与防重放问题

# 分析

个人认为。。。

从交互场景看，按应用验证是最保险的，但是目前设计是按设备验证。

从使用的便利性看，人工确认操作/输入pin码的操作是辅助增强。对称密钥难以摆脱重放等问题。与用户id挂钩的公钥信息是关键。

服务端域名混淆如果没有自动化的hash比对机制，误传的可能性也比较大。

apple这个功能，主要提供共享服务的关键场景是 1 v 1，还是兼顾传统的 1 v N，选择明显不同。

目前比较确定保证的隐私提升效果还是 over tls 查询。
