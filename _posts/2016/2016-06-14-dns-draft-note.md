---
layout: post
category : tech
title:  "一些 dns draft 笔记"
tagline: "note"
tags : [ "dns", "ietf", "ietf" ] 
---
{% include JB/setup %}

## RFC3123

DNS的APL记录，IP地址前缀列表

## draft-huitema-dnssd-privacy 

一个较为复杂的公共服务信息隐藏方案

## draft-ietf-dnsop-attrleaf

域名中间有个下划线开头的 _attr. 标识某种属性

## draft-muks-dnsop-dns-catalog-zones

catalog zone，用于记录与一个域自身配置相关的信息，思路类似于配置通过DNS记录自举

不过把ACL策略放这里让人看总觉得有点那啥……

allow-query.catalog1.example.org. 3600 IN APL (1:192.0.2.0/24 2:2001:db8::/32)

## draft-ietf-dnsop-nsec-aggressiveuse

递归根据nsec/nsec3提供的信息，自动返回该范围内的nxdomain，不需向权威查询

节省查询开销，缩短RTT，缓解随机域名攻击

## draft-ietf-dnsop-no-response-issue	  

无应答的区分

看第７节即可，NOTIMP, FORMERR, NXDOMAIN, NOERROR(no data), REFUSED, BADVERS

## draft-valsorda-dnsop-black-lies	  

对于不存在域名，不是返回NXDOMAIN, 而是返回 NODATA，这样只要给一个NSEC+RRSIG，没有传统的NSEC(3)的zone-walking威胁。

## draft-otis-dnssd-scalable-dns-sd-threats	  

dns sd的安全威胁

## draft-jeong-its-iot-dns-autoconf	  

物联网自动配置，id编址

## draft-wallstrom-dnsop-dns-delegation-requirements

ns授权相关注意事项

## draft-ietf-dnsop-resolver-priming

## draft-ietf-tls-dnssec-chain-extension
