---
layout: post
category : tech
title:  "draft: confidential dns"
tagline: ""
tags : [ "dns", "rr" ] 
---
{% include JB/setup %}

https://tools.ietf.org/html/draft-wijngaards-dnsop-confidentialdns-03

主要思路是新增一个　ENCRYPT RR。

client 发起查询时，开始与server协商密钥（可缓存）。

协商过程与ssl类似（共享密钥，或公钥）。

权威公钥可在DS RR添加，递归公钥则是反向ip的DS RR添加。

。。。

这个现阶段主要还是理论意义强一点，对没加dnssec的中间链路劫持有较好的防御效果。

递归->权威：权威没有太大兴趣帮递归保密，还多耗资源，增加被攻击的风险。

stub->递归：递归侧支持可以当做卖点，大家都懂的。
