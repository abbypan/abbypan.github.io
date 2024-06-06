---
layout: post
category: dns
title:  "DNS: NXNSAttack"
tagline: ""
tags: [ "ddos", "glue" ] 
---
{% include JB/setup %}

* TOC
{:toc}

[NXNSAttack technique can be abused for large-scale DDoS attacks](https://www.zdnet.com/article/nxnsattack-technique-can-be-abused-for-large-scale-ddos-attacks/)

[NXNSAttack: Recursive DNS Inefficiencies and Vulnerabilities](http://www.nxnsattack.com/shafir2020-nxnsattack-paper.pdf)


这个攻击还是传统的组合： 海量open resolver + 单向NS设置 + 恶意random subdomain query。

触发条件其实跟nxdomain攻击类似，攻击放大比的区别在于设置的NS个数。

防御的压力还是在target authority，或者攻击路径的近端路由器主动清洗。理论上，如果hw的路由器分布式联动清洗，应该能在上游抢先处理。
