---
layout: post
category : tech
title:  "DNS in Action"
tagline: "笔记"
tags : [ "dns" ] 
---
{% include JB/setup %}

## chapter 1

windows注册表配置DNS：``HKEY_LOCAL_MACHINE/SYSTEM/CurrentControlSet/Services/Dnscache/Parameters``

stealth name server：不对外公布的权威server，用于帮助zone file传输、备份

dns查询示例图：
![dns_query](/assets/posts/dns_query_1.png)

master与slave示例图：
![dns_master_slave](/assets/posts/dns_master_slave.png)

forwarder dns示例图：
![dns_forwarder](/assets/posts/dns_forwarder.png)

## chapter 2

NXT RR：下一个域名；认证一个不存在的域名及type

DNS数据包

![dns_packet](/assets/posts/dns_packet.png)

有查询&应答的数据包分析，可以看下

## chapter 3

DNS update：rfc3007

可以动态更新域名配置；但只能修改已有的域名配置，不能新增一个域

只能在primary master server上修改

DNS Notify

AXFR & IXFR

Negative Cache：rfc2308

NXDOMAIN 域名不存在(必须缓存，缓存时间不能超过5min)：返回RCODE为NXDOMAIN

NOERROR_NODATA 域名存在，但没有配该类型的RR(必须缓存，缓存时间不能超过5min)：返回RCODE为NOERROR，answer section无内容，authoritative section包含SOA、NS记录

服务器查询失败(可缓存)：返回RCODE为SERVFAIL，原因是zone file配置错误，或问不到master server

服务器不可达(可缓存)


### 否定缓存的规则

否定缓存是肯定要di

非权威的否定应答不缓存

应答里给的权威soa记录也要缓存

没带SOA的否定应答不缓存

已保存的SOA记录得加到应答里面

NXDOMAIN的应答是以QNAME、QCLASS存的

NOERROR_NODATA的应答是以QNAME、QTYPE、QCLASS存的

master file里必须指定$TTL

### IPv6 , DNSSEC 

支持IPV6的DNS，介绍A6、DNAME

DNSSEC，介绍KEY，SIG，NXT

DNS头部的保留字中切出AC（Authenticated Data）、CD（Checking Disabled）

介绍TSIG，TKEY

## chapter 4–chapter 10
介绍常见的几种RR：A/CNAME/NS……

此书作者认为泛域名容易出错，最好别用，除非用作MX、SRV。(PS：个人十分di赞同)

介绍BIND配置

介绍The BIND 9 lightweight resolver library ，简称lwres

一些DNS排障的工具，rfc1713

dnswalk检查DNS配置错误

NS记录的内容必须是一个域名，而不是一个IP

PTR、MX、NS、CNAME记录的内容不能是别名

6.1，6.2 讲子域授权，glue record，非常清楚！

## chapter 7 讲IP反查的配置

## chapter 8 讲管域名，IP的组织

## chapter 9 讲内网DNS配置

## chapter 10 讲内外网配置＋防火墙
