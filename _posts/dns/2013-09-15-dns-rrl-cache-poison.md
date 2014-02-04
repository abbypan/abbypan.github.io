---
layout: post
category : tech
title:  "DNS : RRL <=> CACHE POISON"
tagline: "dns"
tags : ["dns", "rrl", "cache", "security"] 
---
{% include JB/setup %}

见：
- https://www.isc.org/blogs/cache-poisoning-gets-a-second-wind-from-rrl-probably-not/
- http://www.circleid.com/posts/20130913_on_the_time_value_of_security_features_in_dns/

分析挺有意思的，大致是扯这些个观点：

一切痛苦源于没有SAV，即源地址认证 （俺同意）

全部换成TCP会导致查询性能下降，人家不愿意（俺觉得未来还是会上）

禁掉ANY也没有用，DNSSEC应答包也很大（俺同意）

RRL的slip value设成2,不会对CACHE POISON造成明显不利的影响（唔。。。）
- slip value = 2 收到同一CLIENT的一堆相同查询时，只对其中一半时间内的查询返回TC置位应答，其余一半时间的查询请求全部不管
- slip value = 1 每个查询都返回TC置位应答

不做RRL的话，dns server因遭受攻击而使响应变慢，同样会增大CACHE POISON的概率（这话说的有点损，哈哈）

本质上，查询应答加上一些状态检查（RRL，一定时间内的查询个数/TCP握手，确定真的是活的/DNS COOKIE，保证随机数来自指定窗口），都是性能与安全的折衷（确实如此）
 
没有做SAV，主要的威胁：（问题就在于做SAV，ISP看不到自身直接的好处吧，所以累己利他人的东东总是很少）
- 放大攻击（查询不知道是不是真的查询） =》 TC
- 缓存中毒（应答不知道是不是真的应答） =》 UDP源端口随机化（SPR），DNSSEC，
- DNS碎片攻击（缓存中毒的一种）：例如，应答包拆成两个碎片，后一个碎片包是不检查应答ID的，也就是说，伪造的碎片数据包命中缓存的可能性增大  => 没通过DNSSEC/TSIG认证的碎片数据包直接不收

