---
layout: post
category : tech
title:  "一些 dns draft 笔记"
tagline: "note"
tags : [ "dns", "draft", "rfc" ] 
---
{% include JB/setup %}

## RFC3123

DNS的APL记录，IP地址前缀列表

## RFC 2782

DNS的SRV记录，用于查询指定域是否提供某些通用服务，以及服务的地址

_Service._Proto.Name TTL Class SRV Priority Weight Port Target

例如 _ldap._tcp.example.com

## RFC6762 Multicast DNS

本地节点zero-config特定的DNS，自己起个名称啥的

## RFC 6763

DNS-SD ( DNS-Based Service Discovery )

如果1楼的人查询 _ipp._tcp.example.com. 的SRV记录，随机选了一个7楼的打印机，显然是不合适的

因此，接着SRV记录的思路，加入服务实例的标识

先PTR查询 _ipp._tcp.example.com.

Service Instance Name = <Instance> . <Service> . <Domain>

得到一堆服务实例域名，然后再选取其中1个实例域名，查询其TXT记录（此时还能支持一些key-value属性对）

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

## draft-valsorda-dnsop-black-lies	  

对于不存在域名，不是返回NXDOMAIN, 而是返回 NODATA，这样只要给一个NSEC+RRSIG，没有传统的NSEC(3)的zone-walking威胁。

## draft-otis-dnssd-scalable-dns-sd-threats	  

dns sd的安全威胁

## draft-jeong-its-iot-dns-autoconf	  

物联网自动配置，id编址

## draft-ietf-dnssd-hybrid	  

服务查询用PTR再转一下

    b._dns-sd._udp.example.com.    PTR   Building 1.example.com.
                                          PTR   Building 2.example.com.
                                          PTR   Building 3.example.com.
                                          PTR   Building 4.example.com.

## draft-wallstrom-dnsop-dns-delegation-requirements

ns授权相关注意事项

## draft-ietf-dnsop-resolver-priming

## draft-ietf-tls-dnssec-chain-extension
