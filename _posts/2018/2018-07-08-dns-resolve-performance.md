---
layout: post
category: tech
title:  "DNS解析性能影响参数"
tagline: ""
tags: [ "dns", "resolve" ] 
---
{% include JB/setup %}

* TOC
{:toc}

最近又被问起，整理一下

# 服务器配置项

 -  是否支持EDNS0
 -  最大EDNS0长度
 -  是否支持TCP
 -  是否支持ANY查询
 -  权威是否限制区传输的请求源IP
 -  是否支持DNSSEC
 -  是否支持NSEC
 -  是否支持NSEC3
 -  递归是否支持NSEC Aggressive
 -  是否支持DNS Cookie

# 域名配置项

 -  NS记录TTL取值
 -  热点子域名A记录TTL取值
 -  SOA记录中的否定缓存时间nxdomain ttl
 -  是否支持DNSSEC
 -  是否支持NSEC
 -  是否支持NSEC3
 -  DNSSEC算法类型（RSA/ECDSA/。。。）
 -  DNSSEC算法公钥长度（RSA2048/ECDSA256/。。。）
 -  是否有易被攻击放大的TXT记录

# 部署及查询项

 -  RTT（探测点到递归，递归到权威，探测点直接到权威）
 -  是否热点域名
 -  服务器的国家、地区、运营商分布（geolocation）
 -  服务器是否做了Anycast
 -  Anycast服务的源IP的geolocation分布是否合理
 -  源IP的类型是否合理
 -  递归是否缓存、迭代前后分离
 -  源IP到递归的链路状态
 -  递归到权威的链路状态
 -  服务的域名数
 -  服务的源IP数
