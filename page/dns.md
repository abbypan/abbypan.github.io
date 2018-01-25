---
layout: page
title: "DNS"
tagline: "Domain Name System "
---
{% include JB/setup %}

* toc
{:toc}

## 基础

| 资料 | 说明 |
| ---- | ---- |
| [DNS, Domain Name System](http://www.networksorcery.com/enp/protocol/dns.htm) | 爆全的DNS资料索引，世上还是好人多，感动 |
| [SWITCHlan Services: DNS References ](http://www.switch.ch/network/services/dns/references.html) | DNS RFC 索引，也很全 |
| [Domain Name Service DNS](http://www.freesoft.org/CIE/Topics/75.htm) | 很清晰的DNS基础介绍 |
| [Understanding the DNS Protocol](http://www.windowsnetworking.com/articles_tutorials/understanding-dns-protocol-part1.html) | DNS协议介绍 |
| [DNS包细节](http://www.networksorcery.com/enp/protocol/dns.htm) | 各bit说明 |
| [What's in a Name?](http://www.potaroo.net/ispcol/2015-12/names.html) | 名址问题分析 |


## 工具

| 工具 | 简介 |
| ---- | ---- |
| [Public DNS Server List](https://public-dns.info/) | 公用递归列表
| [new gtld stat](https://ntldstats.com/) | new gtld 的统计信息
| [ultradnstools](https://www.ultratools.com/) | ultradns提供的一系列DNS检测工具
| [DNS Looking Glass](http://www.dns-lg.com/) | 可指定节点查询给定域名的RR，支持正向、反向解析，以WEB API形式提供服务，也是statdns的
| [viewdns](http://viewdns.info/) | 探测工具
| [DiG HOWTO ](http://www.madboa.com/geek/dig/) | 解析工具
| [WhoisMind](https://addons.mozilla.org/zh-CN/firefox/addon/whois-mind/?src=userprofile) | 看域名whois信息的firefox扩展
| [IntoDNS](http://www.intodns.com/) | 检查权威DNS配置
| [dns-tools](http://www.bind10.net/dns-tools) | dns 工具箱
| [Comparison_of_DNS_server_software](http://en.wikipedia.org/wiki/Comparison_of_DNS_server_software) | dns 软件对比
| [just dns lookup](http://just-dnslookup.com/index.php) | 从全球各地探测指定域名
| [massivedns](http://massivedns.com/) | 探测
| [dnstcpbench](http://blog.powerdns.com/2013/06/25/simple-tcpip-dns-benchmarking-tool/) | dns压测工具
| [dns-tools](http://www.bind9.net/dns-tools) | bind 网站整理的
| [chinaz站长dns工具](http://tool.chinaz.com/dns/) | 从国内各地探测指定域名，也可指定dns，还可以traceroute
| [networktools](http://networktools.nl/) | 老外的站长工具
| [ccnso icann tld monitor](http://ccnso.icann.org/resources/tld-ops-secure-communication.htm) |
| [TLD MONITOR](https://tldmonitor.blipp.com/) |
| [DNS-OARC TLD Monitoring](https://tldmon.dns-oarc.net/nagios/) |
| [RIPE Atlas DNS Monitoring](https://atlas.ripe.net/dnsmon) |
| [Thousand Eyes](https://www.thousandeyes.com/) |
| [DNSviz](http://dnsviz.net/d/ca/dnssec/) |
| [DNSSEC Early warning](http://www.dnssek.info/) |
| [DNSSEC Deployment Report](http://rick.eng.br/dnssecstat/) |
| [Zonalizer](https://zonalizer.makeinstall.se) |
| [Zonalizer history](https://zonalizer.makeinstall.se/browse/?ca) |
| [CIRA DNS Checker](http://dnstest.cira.ca/) |
| [DNS Configuration: ROBTEX](https://www.robtex.com/?dns=) |
| [EDNSO Compliance Tester](https://ednscomp.isc.org/) |
| [DDoS Mon  alerting](https://ddosmon.net/) |
| [DNSDB](https://www.dnsdb.info) |
| [Shadowserver Compromised Websites](https://www.shadowserver.org/wiki/pmwiki.php/Services/Reports) |
| [OpenPhish Premium](https://openphish.com/phishing_feeds.html) |
| [VirusTotal](https://www.virustotal.com/) |
| [Secure Domain Foundation](http://www.securedomain.org/) , [API](https://api.securedomain.org/intel/json?key=YOURKEY4&email=xx@xx.xx)
| [DNSDB](https://www.dnsdb.info) |
| [PassiveTotal](https://www.passivetotal.com/) |


## 数据

| 数据 | 简介 |
| ---- | ---- |
| [statdns](http://www.statdns.com) | 每月发布全球com/net/org等域名的统计，上面还有dns相关工具的整理、RFC的列表，非常不错
| [iana 的root zone 数据](http://www.iana.org/domains/root/db) | 根域登记
| [open resolver surveys](http://dns.measurement-factory.com/surveys/openresolvers.html) | open resolver asn 统计
| [openresolverproject.org](http://openresolverproject.org) | open resolver 统计
| [root-servers](http://www.root-servers.org/index.html) | 根镜像
| [j.root-servers](http://j.root-servers.org/metrics.html) | J根

## 节点

- NS记录
- IP库
- 前端LocalDNS
- 后端LocalDNS
- 前后端LocalDNS重合度
- 跨运营商
- 同运营商跨地区
- 用户到运营商
- 运营商到权威
- 权威


## 安全

| 资料 | 说明 |
| ---- | ---- |
| [Attacking the DNS Protocol](http://www.net-security.org/article.php?id=600) | DNS攻击
| [An analysis of the DNS cache poisoning attack](https://labs.nic.cz/files/labs/DNS-cache-poisoning-attack-analysis.pdf) | DNS缓存中毒分析
| [BIND 9 DNS Cache Poisoning](http://landing2.trusteer.com/list-context/publications/bind-9-dns-cache-poisoning) | Bind9 缓存中毒资料
| [BIND 8 DNS Cache Poisoning](http://landing2.trusteer.com/list-context/publications/bind-8-dns-cache-poisoning) | Bind8 缓存中毒资料
| [关于DNSCURVE](http://abbypan.blogspot.com/2011/11/dnscurve.html) | DNSCurve笔记，关于加密DNS解析请求
| [What DNS Is Not](http://queue.acm.org/detail.cfm?id=1647302) | 讨论了些dns nxdomain/cdn 的误用跟滥用


## 厂商

| 厂商 | 简介 |
| ---- | ---- |
| [icann](http://www.icann.org/) | 政策
| [iana](http://www.iana.org/) |  	DNS相关事件
| [dns-oarc](https://www.dns-oarc.net/) |  	DNS相关技术、漏洞及报告
| [caida](http://www.caida.org/) | 数据分析
| [Nominum](http://www.nominum.com/) | 牛X厂商，权威、递归都有

## 书

| 时间 | 书 | 读后感 |
| ---- | -- | ------ |
| 2011 | Pro DNS and BIND | 较详细的协议介绍，以及问题讨论，很全
| 2008 | 构建可扩展的Web站点 | 第9章中讨论负载均衡的段落，涉及TTL影响及GSLB的不足，很不错
| 2006 | DNS and Bind | 必读
| 2006 | DNS in Action | 讲实际配置，简单明白，适合一读
| 2002 | DNS and BIND Cookbook | 问题手册型的书，实际操作比较好找答案 
| 2000 | The Concise Guide to DNS and BIND | 问题手册型的书，快速翻阅之


## RFC

| 时间 | RFC编号 | 简介 |
| ---- | ------- | ---- |
| 2015 | [DNS Terminology](https://www.ietf.org/id/draft-ietf-dnsop-dns-terminology-04.txt) | DNS术语集合，跟查字典差不多
| 2010 | RFC 5966 | 用TCP做DNS查询的相关事项，过一遍
| 2008 | RFC 5358 | DNS反射攻击的预防，比较口水话，随便看看
| 2006 | RFC 4592 | 泛域名，感觉不错，值得一读
| 2005 | RFC 4033 / RFC 4034 / RFC 4035 | 讲DNSSEC， 这几份读的很烦躁
| 2004 | RFC 3833 | 威胁分析，关键资料
| 2003 | RFC 3596 / RFC 3152 / RFC 1886 | DNS的IPv6支持，AAAA方案
| 2002 | RFC 3364 | DNS的IPv6支持讨论，AAAA和A6的优缺点PK，看看不错
| 1998 | RFC 2308 | 否定缓存，写的挺好，值得一读
| 1997 | RFC 2181 | DNS介绍，基础必看
| 1997 | RFC 2136 | 动态更新支持，UPDATE
| 1996 | RFC 1996 | 域更新的通知机制NOTIFY
| 1996 | RFC 1995 | 域配置的增量更新IXFR
| 1989 | RFC 1101 | 域名规范，大概看下
| 1987 | RFC 1034 / RFC 1035 | DNS介绍，基础必看

