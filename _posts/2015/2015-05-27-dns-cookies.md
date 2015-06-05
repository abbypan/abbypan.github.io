---
layout: post
category : tech
title:  "dns cookies"
tagline: ""
tags : [ "dns", "cookie", "rfc" ] 
---
{% include JB/setup %}

https://tools.ietf.org/html/draft-ietf-dnsop-cookies-01

DNS COOKIES主要思路是通过在查询/应答包中增加 OPT RR，可以在DNS查询第一次交互时，支持client/sever的双向认证cookie。

DNS COOKIES在理论上有很大的优势，能够有效解决DNS协议的传统缺陷：
1. client cookie能够有效抵御伪造源IP查询的DDOS攻击、第三方放大DDOS攻击。
2. server cookie能够有效降低缓存中毒的风险。

实际执行时，可以有3种方案：
1. client cookie  +  server cookie
2. client cookie
3. server cookie

DNS COOKIES需要client/server双向认证，实际生效需要权威、递归同时支持。

当重点递归配合实施dns cookies之后，ddos时针对来源的分区处理即可生效。但由于需要较多的递归支持，在现阶段进行dns cookies实际操作的可能性较小。

现行的部分源识别防御算法，基本是通过部分的认证型交互实现短时验证（并不能识别伪装重点源IP的攻击）。

如果DNS COOKIES未来成为权威、递归软件的默认开启选项，则DNS DDOS攻击趋势将转成利用海量真实IP进行查询、或者利用少量真实IP向海量递归发起查询。

趋势：在递归侧加强防御策略，总体上更为经济快速（存在误杀风险）。
