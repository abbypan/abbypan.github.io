---
layout: post
category: tech
title:  "IP Anonymization 匿名化处理"
tagline: ""
tags: [ "ip", "privacy" ] 
---
{% include JB/setup %}

* TOC
{:toc}

RSSAC近期讨论的问题：Recommendations on Anonymization Processes for Query Data Submitted for Future Analysis

主要涉及query log中的source ip隐私问题

讨论3个方案：

1) AES-128算法，random key加密。IPv6密文长度不变，IPv4截断到32位。因此IPv6可以恢复，IPv4无法恢复。

2) [Crypto-PAn](https://www.cc.gatech.edu/computing/Telecomm/projects/cryptopan/) 根据random key做加密变换，一个重要特征是相同前缀的IP地址加密后，前缀仍然相同（隐私暴露风险）。Perl实现 [IP::Anonymous](http://search.cpan.org/dist/IP-Anonymous/lib/IP/Anonymous.pm)。解析pcap并处理 [Dnsanon](https://ant.isi.edu/software/dnsanon/)。

3) [ipcrypt](https://github.com/veorq/ipcrypt) 根据random key对IPv4做加密变换，还在讨论中 [Analysis of ipcrypt?](https://www.ietf.org/mail-archive/web/cfrg/current/msg09494.html)。

场景其实是有限的，root query log嘛……

可是 recursive query log，大家又都知道……
