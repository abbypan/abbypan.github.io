---
layout: post
category : tech
title:  "DNS : 2015.10 加拿大 OARC 会议"
tagline: ""
tags : [ "dns", "oarc" ] 
---
{% include JB/setup %}

资料：[OARC 2015 Fall Workshop Montreal](https://indico.dns-oarc.net/event/24/timetable/#20151003.detailed)

# OARC PROJECT

数据主要是 A/C/H/J/K/L 根镜像，还有AS112收集的异常查询，RFC7534

与5月份相比改动不大

# DNS Software Test Centre Proposal  (nominum)

DNS配置体检工具，内容不外DNSSEC，NS，MX之类。

同学们主要担心销路问题。

# An Overview of DNS Privacy Mechanisms (Verisign)

RFC6973, RFC7256, RFC7624, RFC7626

dnssec, nsec3/nsec5, dns over tls, dns cookie, qname minimization, ...

IETF工作组 dprive

围绕加密，认证，信息隐藏各种展开。

**我还是比较看好dns cookie，qname minimization；不看好nsec5，太折腾了。**

# Using TLS for DNS Privacy in Practice (Sinodun)

dns over tls的benchmarking，表示还得加强tcp fast open，tls session resumption

RFC5077 

TCP 1.3

考虑性能的同时兼顾隐私

# Next Steps in DANE Adoption （Verisign）

COM/NET二级域名配置了DNSSEC的域名比例很少，配置了TLSA的域名比例则更加凄惨。

HTTPS，SMTP，XMPP，SIP等有PKI应用场景的其实都能用。

跟$$$$$$$$近的是 Payment Association Records (PMTA)。

**我觉得如果DNSSEC未来广泛部署到二级域名，DANE很可能大势所趋，毕竟浏览器侧、APP侧的集中式CA服务太依赖大平台了，跟递归侧的篡改风险相比，生意还是可以做。**

# Benchmarking of authoritative DNS servers and DNSSEC impact assessment （cznic）

权威部署dnssec查询，nsec3相关性能测试。一个字，慢。

Impact of unknown EDNS options on the DNS (ISC)

识别EDNS的DNS SERVER检测。

CLIENT把DO=1放REQUEST里SERVER侧的应答。

NOTIMP, FORMERR, BADVERS 等RCODE返回情况，blablabla。

# Benchmarking and profiling DNS systems with modern Linux tools (Farsight)

trafgen 高速包生成

tc流量控制

ifpps 包统计

mpstat 系统资源统计

perf 系统资源统计

# Impact of DNS over TCP - a resolver point of view （Bond Internet Systems）

测了一下递归全用tcp往权威查的资源消耗

说是message size问题不大，主要是超时

# Idea: DNS over QUIC / zone transfer over QUIC or TLS/TCP  (JPNIC)

由于QUIC是基于UDP的，所以比较那啥。。。

# OpenDNS; Managing DDoS Attacks (opendns)

## 大家都在做的

1) 限速（查询类型、域名类型、响应包大小、查询源状态 等等参数）

2) 全局攻击识别（无效查询突增，长域名、大量域名，等等）

3) domain 黑名单不能加热门二级域

4) domain freezelist弄client识别/edns0/tcp/历史查询

## 重点开放递归主动做的，5月份会议也有提过：

1) 监测递归自身到权威的RTT，不要透传攻击流量到权威（选择RTT最短的NS，查询突增的时候限速，或不去响应慢的NS查直接servfail）

## 一些细节优化

1) domain freezelist更新处理

2) nxdomain按域名分层统计，低于3层的域名不弄nxdomain whitelist

3) freezelist-domain whitelist 只针对比较“正常”的域名而言，跳过随机临时字串特征的域名（这种往往更disposable，所以whitelist也没啥用）

# Continuous Integration & Continuous Deployment (denic)

nslconfig 配置  + cobbler_control 任务 + postgreSQL + ansible

再加上虚拟化，能弄到10分钟~30分钟 节点部署，软件升级啥的

# Neutering ANY queries: how we did it  (cloudfare)

cloudfare说any用不上，要废掉，blablabla；反对意见说邮箱、监测、浏览器啥的还是有用，blablabla

之前cloudfare的blog上已经吵过架

# Internet Performance Impacts of Canadian Content Hosting (dyn)

加拿大website的ip、domain配置啥的

# DNS big data analytics （sidn）

nl的查询量没那么大，嗯。

# Cluster the long tailed domains base on passiveDNS.cn （360）

提了域名字符特征啥的做分类（随机域名、新域名）＝》maybe 异常

解析到相同ip的域名加个相似度

# Publishing zone scan data using an open data portal (nzrs)

错误配置，ns状态、dnssec配置、www/mail/ns 地址等等，配置监测，域名体检

# A study of caching behavior with respect to root server TTLs （verisign）

递归侧其实是有缓存优化的，TTL没过期就再去查查根，一般 1 day 差不多

# F-root Anycast Research using RIPE Atlas　(ISC)

根的anycast路由问题，导致查询流量不均。

好吧，这个全世界人民都知道。

**我认为，关键问题在于，在什么层面优化？下沉到本地自治域(本地代管+中间风险) or 递归用本地提供根服务的宣告(hint交互+运维问题) or 递归直接运行根服务(google方案+同步问题)。**

# Thirteen Years of "Old J Root"  (verisign)

已经下线13年的J根旧IP还能收到查询。。。

就让它安心的去吧

# Analyzing the distribution of DNS clients to recursive name servers across the Internet （dyn）

来递归查的都是些啥client

# Real World Impacts of EDNS Client Subnet (opendns)

google的ECS改进，带client ip subnet信息优化cdn命中啥的

**我认为这个问题根源自ip混合了isp信息+递归代理查询。在现阶段subnet太分散可能影响时延，而其实这生意在递归上再优化两下也能做。**

# dnstap-whoami: one-legged exfiltration of resolver queries （fastsight）

递归结构前后端工具。。。

# Happy DNS Eyeballs? （apnic）

dns ipv4 ipv6 双栈情况。

