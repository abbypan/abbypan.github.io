---
layout: post
category : tech
title:  "一些 dns draft 笔记"
tagline: "note"
tags : [ "dns", "draft" ] 
---
{% include JB/setup %}

## RFC3123

DNS的APL记录，IP地址前缀列表

## draft-muks-dnsop-dns-catalog-zones

catalog zone，用于记录与一个域自身配置相关的信息，思路类似于配置通过DNS记录自举

不过把ACL策略放这里让人看总觉得有点那啥……

allow-query.catalog1.example.org. 3600 IN APL (1:192.0.2.0/24 2:2001:db8::/32)


## RFC 2782

DNS的SRV记录，用于查询指定域是否提供某些通用服务，以及服务的地址

_Service._Proto.Name TTL Class SRV Priority Weight Port Target

例如 _ldap._tcp.example.com

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

## RFC6762 Multicast DNS

本地节点zero-config特定的DNS，自己起个名称啥的


