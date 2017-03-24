---
layout: post
category: tech
title:  "dns root: ICANN RSSAC Root Scheme Analysis"
tagline: ""
tags: [ "root", "icann", "dns" ] 
---
{% include JB/setup %}

* TOC
{:toc}

# 资料

ICANN RSSAC Technical Analysis of the Naming Scheme Used For Individual Root Servers

# priming query

递归根据初始配置，查 . 的 NS，开启edns0至少1024字节

# 方案

## 5.1 The Current Naming Scheme 

原有的架构，root -> root-servers.net 信息分层zone存放

root-servers.net 没签名

. 的 13个 NS 有一个 RRSIG

## 5.2 The Current Naming Scheme, with DNSSEC 

root-servers.net 在该权威上签名

由于root不是root-servers.net的权威，根服务器对应的RRSIGs是存在root-servers.net上面的，如果net不幸挂掉，会影响root-servers.net的DS。链式验证root-servers.net的dnssec记录时，还要先验证.net的dnssec记录

## 5.3 In-zone NS RRset 

root zone直接作为权威，根服务器统一新命名如 a.root-servers 之类。

priming query的应答answser section包含13个NS记录，Additional section包含13个A，13个AAAA的26个RRSIG。

DNSSEC记录管理比之前简单，但应答包较大。

## 5.4  Shared Delegated TLD

新设置一个tld，把根服务器挪过去。

priming query时answer section是13个NS+1个RRSIG。

如果additional section没带a/aaaa的rrsig，dnssec验证时还是要找shared tld查。

## 5.5 Names Delegated to Each Operator

统一root server命名，如a.root-servers之类

priming query时answer section是13个NS+1个RRSIG。Additional section是 a/aaaa glue，没有RRSIG。也就是说13个NS的A如果要验证的话，就要跑去13个NS的权威上各查1遍。

## 5.6 Single Shared Label for All Operators

单个命名，例如all-root-servers，而该命名对应13个a/aaaa

priming query的answer section有1个NS+1个RRSIG，Additional section里带所有的a/aaaa glue+2个RRSIG

有个问题是如果priming query查到servfail/refuse，现行的一些软件可以就中断本次查询

如果软件根据ns名称做查询量负载均衡，也有小概率出问题

# 对比

第6章的大表跟对比挺全的。

同步；

依赖其他zone；

验证链断掉导致风险；

长验证chain；

rtt延长；

priming response包增大；

某些场景异常；

命名冲突；

根服务器自治

# Recommendations

加签名

根NS信息与根区文件数据存一起

减少长DNSSEC链验证

减小应答包长度研究，例如算法调整，物联网设备接收应答包短一点，向不同源返回自适应glue

# 讨论

5.6 管理简单一些，5.4 预期过渡平稳一些

自适应响应的话，区域同步时效需要考虑
