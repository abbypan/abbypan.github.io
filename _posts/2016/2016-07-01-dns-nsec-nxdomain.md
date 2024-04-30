---
layout: post
category: dns
title:  "dns : dnssec, nsec(3),  nxdomain"
tagline: "note"
tags : [ "dns", "nsec", "nxdomain", "dnssec" ] 
---
{% include JB/setup %}

* TOC
{:toc}

对于 nxdomain 场景，dnssec的处理方案是 nsec(3)，见 RFC4033/RFC4034/RFC4035/RFC7129

对于nxdomain/nsec(3)提供的信息有几种利用思路

## draft-ietf-dnsop-nsec-aggressiveuse 

递归侧利用nsec(3)缓解ddos威胁

递归根据nsec/nsec3提供的信息，自动返回该范围内的nxdomain，不需向权威查询

节省查询开销，缩短RTT，缓解随机域名攻击

ddos缓解效果，与该域下的域名个数相关，相当于一个圆上划多少段点

对于com/net等超大型的tld域，递归进行nsec aggressiveuse查找，开销也会增大

## draft-ietf-dnsop-nxdomain-cut 

扩展nxdomain的覆盖认定，收到某域名的nxdomain也代表着该域下不存在其他子域名

此时，对 QNAME minimisation [RFC7816] 的分层查询也有明显的好处

## 缩小nsec(3)提供的信息范围，提供的否定信息仅限于查询的域名

主要是防zone walking的思路

### RFC4470, minimal covering nsec and dnssec on-line signing

生造出跟 foo.example.com 比较靠近的两个域名，即时生成信息

这样可以满足nsec要求，还能限制泄漏其他域名信息

    foo\255\255\255\255\255\255\255\255\255\255\255\255\255\255
         \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255
         \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255
         \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255
         \255.example.com 3600 IN NSEC \000.foo.example.com ( NSEC RRSIG )

泛域名处理也类似 

         \)\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255
         \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255
         \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255
         \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255
         \255\255.example.com 3600 IN NSEC \000.*.example.com ( NSEC RRSIG )


### RFC7129，Authenticated Denial in DNS

NSEC处理思路与RFC4470类似，假设原来有``a.example.org.      NSEC c.example.org. RRSIG NSEC``

现在查一个不存在的 b.example.org，则生造一个NSEC如下

     a\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255
        \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255
        \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255
        \255\255\255\255\255\255\255\255\255\255\255.example.org. (
          NSEC \000.b.example.org. RRSIG NSEC )

NSEC3的构造比较简单，就是hash值 -1 ~ +1

例如 "b.example.org" 的hash是 "iuu8l5lmt76jeltp0bir3tmg4u3uu8e7"，直接加减hash值生成NSEC3记录

泛域名操作也相同

   iuu8l5lmt76jeltp0bir3tmg4u3uu8e6.example.org. (NSEC3 1 0 2 DEAD IUU815LMT76JELTP0BIR3TMG4U3UU8E8 )

### draft-valsorda-dnsop-black-lies 不返回NXDOMAIN，而是返回NODATA

对于不存在域名，不是返回NXDOMAIN, 而是返回 NODATA（QNAME存在而该QTYPE的RR不存在），这样只要给一个NSEC+RRSIG，没有传统的NSEC(3)的zone-walking威胁

  a.example.com. 3600 IN NSEC \000.a.example.com. ( RRSIG NSEC )

但是这样操作，对NXDOMAIN CUT的处理就有影响了

## 讨论

nsec aggressiveuse：缓解ddos

nxdomain cut：缓解ddos，减少缓存开销，支持qname minimisation [RFC7816]

nsec(3) one-line：节省nsec生成开销，减少zone walking风险，与nsec aggressiveuse的要求相反

draft-valsorda-dnsop-black-lies：减少nsec记录数目，减少zone walking风险，与nsec aggressiveuse/nxdomain cut的要求相反

个人觉得：

1) nxdomain cut比较可行，对递归、权威、qname minimisation都有好处

2) nsec(3) one-line 相对简单，开销较小，并且有助于信息隐藏

3) 递归侧nsec aggressiveuse的出发点在于节省递归到权威的无效查询，并抵御ddos攻击；与权威侧 nsec(3) one-line诉求正好相反。折中的场景，递归默认开启nsec aggressiveuse支持，权威平时返回nsec(3) one-line信息，ddos的时候权威切换成传统nsec按圆圈生成的模式。如果是ddos+权威nsec3 one-line+递归nsec aggressiveuse，相当于回落到传统dns ddos场景，可能还要差些

4) black-lies需要递归多一个主动识别nodata实际上是nxdomain的判定，否则副作用较大


##  针对“不存在”记录的认证 NSEC3等

见：[Authenticated Denial of Existence in the DNS](http://tools.ietf.org/html/draft-gieben-auth-denial-of-existence-dns-05)

此篇自带吐槽，比较搞。主要是5.5 / 5.6。

问题在于通过hash隐藏zone信息同时带来的混乱，以及 ``[ 分层授权设计 + 泛解析 + “不存在” 应答 ]`` 合在一起处理神烦。
