---
layout: post
category : tech
title:  "递归DNS笔记"
tagline: "recursive dns"
tags : ["dns","security", "recursive", "edns0", "dnssec"] 
---
{% include JB/setup %}

## 递归server迭代查询时，收到多个权威ns时的选择算法
见：
- http://www.nanog.org/meetings/nanog54/presentations/Tuesday/TrackYu.pdf
- http://irl.cs.ucla.edu/data/files/papers/res_ns_selection.pdf

这个比较了bind / powerdns / unbound / dnscache / windowsdns，比较全了

要点：
- 往RTT最短的ns查，速度较快
- 但同时要考虑负载均衡的问题，不能老往一个ns上压

问题：
- 短RTT的怎么个优先法
- 长RTT的又怎么办
- 多长时间能发现一个ns的RTT从长变短（也就是服务性能变好了，大家可以用了）

＝＝＝

RTT初始化：
- 先测一下初始RTT（全查）
- 或者给所有ns赋一个初始低RTT

选择NS：
- 选RTT最低的
- 或者RTT低于某个阈值的NS里随机选一个

平滑RTT，即计算SRTT：
- 乘一个平滑参数，该参数与上一次RTT值相关
- 更新此次查询的RTT
作用：让长RTT的ns也有机会被选中；发现RTT从长变短的NS

没返回的ns怎么办：
- 定时查
- 直接当成长RTT处理（得等好久才能再一次被选中） 

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

## isp ldns
运营商一般是有少量（比如3～4个）只接收解析请求的前端LDNS、由前端LDNS向后端一堆（比如20多个）负责进行解析的LDNS转发解析请求，后端LDNS再返回该域名NS服务器解析结果给前端LDNS，前端LDNS再返回给用户。

因此，靠近用户的运营商前端LDNS可能远小于靠近域名NS服务器的运营商后端LDNS。

LDNS收到域名解析的一些IP（比如10个）后，在缓存失效前，不会再向域名服务器发请求。如果后端LDNS返回不对IP做轮询处理，而总是以固定的顺序返回，则可能导致该地区用户在每个缓存期总是访问该域名下的某个特定的IP，负载失衡。

因此，单独通过域名解析的IP轮询做负载均衡还不够，还应该在接收服务请求时也做一些负载分担。 

## draft 笔记

### [Domain Name System (DNS) Cookies](http://tools.ietf.org/html/draft-eastlake-dnsext-cookies-03)
参考：[DNS Cookies](http://www.ietf.org/proceedings/67/slides/dnsext-0/dnsext-0.ppt)

差不多就是resolver 和  ns 之间互相发挑战码当cookie进行握手，双方都要支持

这样只要cookie定期更换、且不同server发不同cookie就很被难被骗，cache poison有所缓解

ns更容易被ddos调戏，伪造源IP查就可以触发它算一堆cookie；不过如果resolver过不了认证，它后面发的攻击包就可以直接过滤掉

伪造源IP向open resolver查，来做反射放大攻击的威胁还是跟之前一样，除非open resolver也对源来一下cookie检查

伪造源IP直接向一堆NS查，来做反射放大攻击，威胁变小，因为过不了握手，不过还是得大家都支持

（个人觉得这个认证越搞越麻烦，不如直接全上TCP，唉！）

### [Improvements to DNS Resolvers for Resiliency, Robustness, and Responsiveness](http://tools.ietf.org/html/draft-vixie-dnsext-resimprove-00)

主要集中于递归对NS记录的处理，很多细节值得再读，类似于最佳实践总结

1）父域NS的TTL到期时，重新对其授权进行验证

2）碰到NXDOMAIN，不再往下查，原有的cache也清掉

3）授权时获得的NS记录信任度增强
NS

2.1  由于父域NS的TTL与子域NS的TTL不同步，且子域NS是权威记录，授权生效之后父域NS的TTL基本无意义了（其实就是授权的太彻底）

2.2  父域NS的TTL过期后，触发子域NS重新验证；返回cache记录时，要确保该cache来源的NS还没过期（其实就是A与NS也要挂钩）

2.3  某个域的重新验证，可能触发其他域也开始重新验证（相同父域上有授权NS更新），离根越近的越先试起

2.4  重新验证完成后，还是迅速启动子域提供的NS，而非父域的glue

2.5  如果NS有变化，从旧NS覆盖的cache都清掉

2.6  重新验证的TTL略小于NS记录的TTL，主要是给验证腾出时间

NXDOMAIN

3.1 注意，empty nonterminal domain names 和 nonexistent names 是有区别的，不过现实的NXDOMAIN默认该对象无子域

3.2 碰到一个cached NXDOMAIN，停止查询

3.3 碰到NXDOMAIN，原来往下的cache都删掉，也都返回NXDOMAIN

3.4  查FOO.TLD、BAR.FOO.TLD，如果FOO.TLD不存在，会到TLD查两次；不过下回碰到 xxx.FOO.TLD就直接NXDOMAIN不再查

NS授权的信任

4.1 child的NS如果覆盖parent的NS，可能导致cache只记得child的结果。如果parent NS挂掉child的NS又太短，悲剧不可避免的发生。

4.2 如果触发重新验证，原始的trigger query等到validation query搞完才返回。（RFC不说人话就是这种，举个例不行嘛）

4.3 授权NS更新，则一二三四重走一遍

4.4 如果父域的NS与子域的NS不同，以子域为准（承认村骗乡，乡骗县的节奏）

安全

5.1 NXDOMAIN cache poison的受害范围增大

5.2 下层域被NS cache poison长TTL影响缓解，因为上层glue有重新验证的时间（如果是在TLD注册的那些域，估计还是够呛）

### [A Mechanism for Remote-Triggered DNS Cache Flushes (DNS FLUSH)](http://tools.ietf.org/html/draft-jabley-dnsop-dns-flush-00)

让权威主动通知某些递归，有某个域数据变了，不要等ttl过期，赶快flush

用于：

1) DNSSEC域签名认证失败的快速恢复

2) 注册局/注册商服务异常的快速恢复，场景有点类似baidu的ns被改案例

刷新的通信复用DNS NOTIFY的设计，通信认证复用TSIG

这个用于应急不错，好处明显

不过cache估计得限制能给它notify的域，不然搞一堆免费域发notify也容易被调戏 
