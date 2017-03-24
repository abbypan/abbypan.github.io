---
layout: post
category : tech
title:  "DNS-OARC: 2016.04 阿根廷 会议"
tagline: ""
tags : [ "dns", "oarc" ] 
---
{% include JB/setup %}

资料：[OARC 2016 Spring Workshop](https://indico.dns-oarc.net/event/22/timetable/#all.detailed)

# Recent DDoS attacks against RIPE NCC's DNS servers

8w qps， 1G口，量不大

# How we are developing a next generation DNS API for applications

https://getdnsapi.net

基础库工具，支持 stub / recursive 模式

异步

支持 dnssec/dane 验证， 支持  dns over tls

# Real-Time Analytics of DNS packets

redis

# AAAA Deep Dive: DNS Resolution Anomalies and Performance across a Huge Data Set

配置ipv6/ipv4各种单独、混杂环境的递归，

测试1亿多域名权威是否能正常返回应答

纯v6的servfail比例较大，可以理解

# ENTRADA: The Impact of a TTL Change at the TLD-level

nl顶级域，500w~600w 的二级域名量

zone update interval  2 hour ->  1 hour

NS TTL 7200 -> 3600

SOA NXDOMAIN TTL 900 -> 600

主要影响：峰值domain query double，nxdomain 略升

# Continuous Data-driven Analysis of Root Server System Stability

里面的根区指标图挺不错……

RSSAC002 写的那一堆可以复习一下

# Testing Most Authoritative Servers for Conformance 

gTLD nameservers: a few very quick observations

all gtld zonefiles ...

约 300w NS

约70w not glue records (  a name in .com whose NS 
records are in .net )

glue 跟 not glue 的 timeout 表现不一

如何reduce ? 

其实吧，hot up cold down

# State of the "DNS privacy" project: running code  

dns over tls, port 853

https://dnscrypt.org/

# QNAME minimisation in Unbound

unbound 已支持

draft-vixie-dnsext-resimprove

draft-ietf-dnsop-nxdomain-cut

# Knot DNS Resolver

https://www.knot-resolver.cz

缓存server平台，有些acl啥的增强接口

# Threshold-Cryptography Distributed HSM

libpcks

# Multi-vantage point DNS Diagnostics and Measurement

dnsviz , 调试工具吧

其实跟域名体检差不多

# Review and analysis of attack traffic against A-root and J-root on November 30 and December 1, 2015

895 million src ip ，伪造ip查询

4739 ip send 100+ query

top 200 ip => 68% traffic

主要打 336901.com/916yy.com，动机未明

rrl + filter

# The Quest for the Missing Keytags

就是hash要不要搞长点

# Increasing the Root Zone ZSK Size

response size, bandwidth cost 的差别

# Deckard -- Integration Testing of DNS Servers

又一个体检

# DNS Secondary service for customers, evolution and "meta-slave"

多个备选server也还好吧

# ECDSA - Reviewed

ECDSA 比 RSS 好点，不过支持比例低些

# Zombies

只查一次，ttl=1s，随机数模板，

其实跟临时域名也满像的~

# dns-stats

dns-stats.org

# EDNS Compliance

edns的支持测试以及返回码，可以仔细看看

https://ednscomp.isc.org/compliance/summary.html

https://ednscomp.isc.org/compliance/tld-report.html

# Rolling the Root Key

几年轮一次的……

# Algorithm roll-over experiences

……

# Panel: DNSSEC algorithm flexibility

……

