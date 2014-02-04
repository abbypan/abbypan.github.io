---
layout: post
category : tech
title:  "DNS 安全"
tagline: "security"
tags : ["dns", "security"] 
---
{% include JB/setup %}

## abor 2011年关于dns攻击的PPT

见 [enhancing-cloud-resiliency-with-dns](http://www.arbornetworks.com/docman-component/doc_download/543-enhancing-cloud-resiliency-with-dns)，几个图挺不错的 

##  针对“不存在”记录的认证 NSEC3等

见：[Authenticated Denial of Existence in the DNS](http://tools.ietf.org/html/draft-gieben-auth-denial-of-existence-dns-05)

此篇自带吐槽，比较搞。主要是5.5 / 5.6。

问题在于通过hash隐藏zone信息同时带来的混乱，以及 ``[ 分层授权设计 + 泛解析 + “不存在” 应答 ]`` 合在一起处理神烦。
