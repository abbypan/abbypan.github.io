---
layout: post
category: dns
title:  "dnssec keytrap"
tagline: ""
tags: [ "dnssec", "dns", "cve" ] 
---
{% include JB/setup %}

* TOC
{:toc}

# doc

[KeyTrap: Serious Vulnerability in the Internet Infrastructure](https://www.athene-center.de/en/keytrap)

[The KeyTrap Denial-of-Service Algorithmic Complexity Attacks on DNS](https://www.athene-center.de/fileadmin/content/PDF/Keytrap_2401.pdf)

(zone name, algorithm, key-tag) 支持多tag，多key，多signature，且key-tag不是唯一标识（rfc4034）。

构造多个key下的多个invalid signature，使得resolver校验失败，消耗cpu。

这个主要考验多少resolver打开dnssec又不升级，连带影响解析服务。
