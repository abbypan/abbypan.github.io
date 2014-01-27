---
layout: post
category : tech
title:  "递归DNS笔记"
tagline: "recursive dns"
tags : ["dns","security", "recursive", "edns0", "dnssec"] 
---
{% include JB/setup %}

## 端口随机性 port randomness test

见：https://www.dns-oarc.net/oarc/services/porttest

把porttest.dns-oarc.net查询CNAME到z.y.x.w.v.u.t.s.r.q.p.o.n.m.l.k.j.i.h.g.f.e.d.c.b.a.pt.dns-oarc.net，计算这随后26个查询包源端口的标准差 

## 测试递归是否支持DNSSEC查询

{% highlight bash %}
> dig com. SOA +dnssec @8.8.8.8
; <<>> DiG 9.7.1-P2 <<>> com. SOA +dnssec @8.8.8.8
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 24457
;; flags: qr rd ra; QUERY: 1, ANSWER: 2, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags: do; udp: 512
;; QUESTION SECTION:
;com.                           IN      SOA

;; ANSWER SECTION:
com.                    446     IN      SOA     a.gtld-servers.net. nstld.verisign-grs.com. 13823440
83 1800 900 604800 86400
com.                    446     IN      RRSIG   SOA 8 1 900 20131028082803 20131021071803 22625 com.
 bFG5IudlnYZcfa0jIGg3PAnfLx+oO20nfLAn4cdO8eUs9P5aZRoZughY bznMoqRzRoRnOQMZH83/EPBW7YBFK7Zuvvw3jZ67n+
Z6JRmQMB0tU+cC dnvfVRMV8Cr/RC6utuH2IW7usXihWQ3IDh7Dv5ZJlAcFF6q44JSbLKRJ keM=

;; Query time: 124 msec
;; SERVER: 8.8.8.8#53(8.8.8.8)
;; WHEN: Mon Oct 21 16:36:03 2013
;; MSG SIZE  rcvd: 268 
{% endhighlight %}

## 测试递归DNS是否支持EDNS0

{% highlight bash %}
> dig com. ns +bufsize=4096 @61.139.2.69
; <<>> DiG 9.7.1-P2 <<>> com. ns +bufsize=4096 @61.139.2.69
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 30671
;; flags: qr rd ra; QUERY: 1, ANSWER: 13, AUTHORITY: 0, ADDITIONAL: 16

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4000
;; QUESTION SECTION:
;com.                           IN      NS

;; ANSWER SECTION:
com.                    139458  IN      NS      e.gtld-servers.net.
com.                    139458  IN      NS      b.gtld-servers.net.
com.                    139458  IN      NS      a.gtld-servers.net.
com.                    139458  IN      NS      l.gtld-servers.net.
com.                    139458  IN      NS      j.gtld-servers.net.
com.                    139458  IN      NS      d.gtld-servers.net.
com.                    139458  IN      NS      c.gtld-servers.net.
com.                    139458  IN      NS      m.gtld-servers.net.
com.                    139458  IN      NS      k.gtld-servers.net.
com.                    139458  IN      NS      f.gtld-servers.net.
com.                    139458  IN      NS      i.gtld-servers.net.
com.                    139458  IN      NS      h.gtld-servers.net.
com.                    139458  IN      NS      g.gtld-servers.net.

;; ADDITIONAL SECTION:
b.gtld-servers.net.     163926  IN      A       192.33.14.30
b.gtld-servers.net.     165446  IN      AAAA    2001:503:231d::2:30
a.gtld-servers.net.     149230  IN      A       192.5.6.30
a.gtld-servers.net.     149229  IN      AAAA    2001:503:a83e::2:30
l.gtld-servers.net.     165481  IN      A       192.41.162.30
j.gtld-servers.net.     165410  IN      A       192.48.79.30
d.gtld-servers.net.     165417  IN      A       192.31.80.30
c.gtld-servers.net.     162827  IN      A       192.26.92.30
m.gtld-servers.net.     161893  IN      A       192.55.83.30
k.gtld-servers.net.     156410  IN      A       192.52.178.30
f.gtld-servers.net.     155317  IN      A       192.35.51.30
i.gtld-servers.net.     161893  IN      A       192.43.172.30
h.gtld-servers.net.     165410  IN      A       192.54.112.30
g.gtld-servers.net.     165411  IN      A       192.42.93.30
e.gtld-servers.net.     165429  IN      A       192.12.94.30

;; Query time: 156 msec
;; SERVER: 61.139.2.69#53(61.139.2.69)
;; WHEN: Mon Oct 21 16:33:18 2013
;; MSG SIZE  rcvd: 520 
{% endhighlight %}

## 测试递归可支持的RESPONSE长度

见：[OARC s DNS Reply Size Test Server](https://www.dns-oarc.net/oarc/services/replysizetest)

用户 <-> 递归（前端cache，后端forwarder）<-> 权威

### 总结

oarc这个服务只能测单个链路(递归<->oarc权威)的edns支持情况，是否支持edns0的结论一般跟实际情况差别不会太大，测出的支持edns0最大长度则可能与实际不太一致（因为不同链路实际情况不同）。

当然是否支持edns0的结论也可能出错，当 用户<->某个递归 edns0正常，但是该递归<->oarc权威 edns0失败，就会出现不一致的探测结果。


### 分析

如果递归不支持EDNS，则无法接收超过512字节的数据

如果递归所在的防火墙过滤IP碎片或过滤>512字节的DNS应答包，则大块的RESPONSE数据可能会被丢掉

BIND 9.5.0 之后，递归查询如果time out，会把edns的buffer长度设回512

测试：``dig +short rs.dns-oarc.net txt @8.8.8.8``

跟递归说支持1024的buffer：``dig +bufsize=1024 rs.dns-oarc.net txt @8.8.8.8``

 注意这里1024只是dig查询时跟递归8.8.8.8说的，8.8.8.8查询的时候再转，跟 8.8.8.8 <-> dns-oarc权威实际支持的长度无关

 Nominum CNS只在收到truncated应答时才会发起带EDNS的查询，因此，针对Nominum CNS型的递归xxx.xxx.xxx.xxx，应答时TC置位迫使其用EDNS查：

``dig tcf.rs.dns-oarc.net txt @xxx.xxx.xxx.xxx``
 

### 检测原理

    一次查询多次CNAME检测

    每次查询，server通过填充authority/additional域数据，得到多个不同长度的应答包（CNAME域名里带了这个长度信息），按从大到小的次序发出。

    假设每次收到的应答包长度都是可接受的最长的，几次CNAME折半后就能逼近最终长度

    最终返回TXT记录，包含了上述测试的长度，以及是否支持EDNS的判断

### 注意

这个只能测 递归<->oarc权威之间的链路，没法测 用户<->递归 之间的链路

对于forwarder的情况，用一些不常见的RR填充数据包可能会更好一点

## 域名已经删除了但仍可以在递归持续解析
见：http://netsec.ccert.edu.cn/duanhx/archives/1656?lang=zh-hans

清华的paper

假设域名为 somedomain.com

关键点在于，递归从com获取 somedomain.com 的 ns1.somedomain.com之后，相信ns1.somedomain.com发过来的所有消息，包括ns记录！

当com已经删除了somedomain.com时，ns1.somedomain.com已经先跟递归说了还有个ns2.somedomain.com。

ns1.somedomain.com可以定期发包强调当前权威可用，同时update用ttl。保证让递归一直相信下去，不去com问问。。。

解决的时候，一个注意NS要从上级问，还有得按层次检查域名。

## 权威错误数据传到递归后，递归如何清除缓存
见：[hijacking-dns-error-ddos-what-happened-and-what-you-can-do](https://www.isc.org/blogs/hijacking-dns-error-ddos-what-happened-and-what-you-can-do/)

与缓存中毒不同，LinkedIn的问题出在注册商，所以从TLD权威开始就错了。

需要递归主动刷新CACHE，用rndc flush之类的命令，具体见：

[How do I flush or delete incorrect records from my recursive server cache](https://kb.isc.org/article/AA-01002)
