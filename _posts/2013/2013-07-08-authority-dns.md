---
layout: post
category : tech
title: "authoritative server: 权威DNS"
tagline: ""
tags: [ "dns", "authoritative" ] 
---
{% include JB/setup %}

* toc
{:toc}

# tips

DNS解析的性能更多是取决于NS记录的缓存时间，单独把A记录的TTL调低没太大影响

反向解析比正向解析多，比例约为3:2

lame server表示该dns不负责某个网域的解析，但是却将该网域的ns记录指向此dns

正常情况下，99%的dns查询走udp

global server load balancing (GSLB)-type DNS ：根据发起请求的用户所在地，返回不同的ip


# root

梦里不知身是客！

[dns tampering and root servers](http://www.renesys.com/wp-content/uploads/2013/05/DNS-Tampering-and-Root-Servers.pdf)

# tld 

## tldmon

常见的重点项基本都包括了：[OARC TLDmon Service](https://www.dns-oarc.net/oarc/services/tldmon)

可视化：[结果分块着色](https://tldmon.dns-oarc.net/nagios/)，[趋势](https://tldmon.dns-oarc.net/history/)

# sld

## zone 授权

存在跨层授权。

例如递归已知 aaa.yyy.com / xxx.aaa.yyy.com 都不存在，无法推断 zzz.aaa.yyy.com 是否存在。

因为 zzz.aaa.yyy.com 理论上有可能在 yyy.com 上直接授权。

![dns_authority_nxdomain](/assets/posts/dns_authority_nxdomain.png)

同理，XXX.abc.com (XXX为随机数)，即使已知 abc.com 不存在，也会到 com 查一遍。

## 权威NS更新

对域名testxxx.com做ns记录修改，本地ns服务器ns.new.net提供该域名解析

在域名注册商处修改ns成功：原来是 ns.old.net ，现在是ns.new.net

dig testxxx.com -t ns  本地查询返回ns.old.net

dig testxxx.com -t ns +trace 从根开始问到底，中间在com.处返回ns.new.net；继续问ns.new.net时，又返回ns.old.net

在com.和 ns.new.net返回两次testxxx.com的ns，分别是一新一旧两个记录

这是因为ns.new.net上配置了testxxx.com的ns记录是ns.old.net

在域名注册商处把ns记录换成ns.new.net，父域com.的ns知道有改动了，但是ns.new.net上的旧记录没有更新。

# latency

见：[Measuring Query Latency of Top Level DNS Servers](http://netsec.ccert.edu.cn/duanhx/files/2013/02/latency.pdf)

## 权威dns时延分析

多个分布式探测点，探测权威ns时延

优选方案2)：每个节点每n分钟同时发s个udp包，每个包等5s。支持量化评估权威时延。

| 方案 | 优点 | 缺点 |
| ---- | ---- | ---- |
| 1) 每个节点每n分钟发1个udp包，每个包等5s | 简单 | 受网络丢包影响
| 2) 每个节点每n分钟同时发s个udp包，每个包等5s | 简单 | 权威ns较多时，发包也多
| 3) 每个节点先发1个udp包，超过t秒无返回，再发第2个包，最多重试x次 | 避免偶然丢包的影响 | 某些情况下权威ns查询时延/失败波动被主动忽略

方案3)：
一般用于时延报警策略误报优化，不用于基础数据探测。当等待时延t设置小于某些真实时延时，最终得出的时延与实际情况有偏差，且未知增减：
- ``<=t``秒：无影响
- 重试x次，写入``x*t + succ_rtt``：影响可能偏大
- 重试x次，写入``succ_rtt``：影响偏小
- 重试x次，均未在t秒内返回，返回失败：影响偏大

## NXDOMAIN-QUERY

    client到根的rtt：client 向递归 dns_r 查不存在的tld域名查询，那么递归dns_r就会去根root查。 

    client到递归的rtt：理论上可以发非递归的查询请求（不过实际上经常没用），或者查一个已缓存的域名。

    最终得到 递归dns_r到根root 的时延：``T(dns_r , root) = T(c, root) - T(c,r)``。


这个方法只能得到递归dns_r到指定域（例如root）下的整体时延。

但不清楚是到这个域下的哪个具体ns server的时延，因为递归dns_r对同一个域下的多个ns的选择算法可能不同。

文章中用这个方法测了root，.com / .net / .org 等流行tld。

## KING root

用king法测量递归到13个根的时延，测的是到13个根anycast ip的rtt

注意，这边的误差在于，这些ip做了全球anycast，递归的真实rtt可能不是去到king法选的路径上

用king法测量给出了F、L根的unicast ip的RTT，并与上面anycast ip的rtt做对比，可衡量unicast镜像的作用啥的

此外还用fpdns探测了一下bind版本 

## king end host

[King: Estimating Latency between Arbitrary Internet End Hosts](http://homes.cs.washington.edu/~gribble/papers/king.pdf)

利用dns测两个ip之间的RTT
- ip_a 本地网段有个递归 dns_r
- ip_b 本地网段有个域 somedomain.com 的权威 dns_a
- 认为``RTT(ip_a, ip_b)``可以约等于``RTT(dns_r, dns_a)``


``RTT(dns_r, dns_a)`` 可以用以下方法计算：
- 从节点c 向 dns_r 请求 somedomain.com 下的一个不存在的域名，``RTT(dns_a, c)``
- 从节点c 向 dns_r 发ping包，或查询一个dns cache记录，``RTT(dns_r, c)``
- ``RTT(dns_r, dns_a) = RTT(dns_a, c) - RTT(dns_r, c)``

＝＝＝

这边要考虑 somedomain.com 有多个权威dns_a的情况。

要先确定当前dns_r会去查的是哪个dns_a。

假设dns_r查到somedomain.com的ns
- ns1.somedomain.com
- ns2.somedomain.com

并且 ns1.somedomain.com 对应的dns_a是
- xxx.xxx.xxx.xxx
- yyy.yyy.yyy.yyy

根据dns_r的配置不同选择看法，可能选择查询的dns_a不同 

# rfc

## RFC2845: tsig

tsig 对dns消息做认证：http://backreference.org/2010/01/24/dns-security-tsig/

## RFC9471: DNS Glue Requirements in Referral Responses

权威注意返回所有glue，防cycle。

message size太大就TC=1。
