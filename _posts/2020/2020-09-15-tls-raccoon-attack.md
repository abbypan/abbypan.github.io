---
layout: post
category: tech
title:  "TLS Raccoon Attack"
tagline: ""
tags: [ "tls", "attack" ] 
---
{% include JB/setup %}

* TOC
{:toc}

# doc

[Raccoon Attack](https://raccoon-attack.com/)

这个攻击条件比较高。。。

基于几个假设：
- server使用DH（固定key），或者重复使用相同的DHE的ephemeral key pair（接近固定key，误用的典型）。
- 中间人可以监听到之前 client 与 server 交换的g^a，g^b。——也就是说，攻击者要非常靠近server。
- DH计算出的`Pre_Master_Secret（PMS）= g^(ab)`如果头几位为0，由于DH会把头部的0去掉再提交KDF，KDF派生会话密钥所需的计算时间会不一样。

攻击：
- 随机选取`r_i`，构造 `g^(r_i) * g^a` 做为交换的公钥。
- 此时， `(g^(r_i) * g^a)^b = g^(r_i*b) * g^(ab)`
- 由于`r_i`已知，可以化为一个等式： `x^b = y^b * PMS`，其中，x、y已知，b、PMS未知

当x、y足够多时，可以用Hidden Number Problem(HNP)求解出PMS。

其实相当于格上的最近向量问题(closest vector problem)求解。

# summary 

DH场景下，static key pair比较危险。不论是主动选择，还是代码缺陷。

Pre_Master_Secret不要乱strip头部的0。比如ECDH不受影响就是因为没去掉头部的0。

最好不要用DH。

tls v1.2及以下版本受影响。

tls v1.3保留了头部的0，且不重复使用ephemeral key pair，所以不受影响。

但是[ETSI TS 103 523-3](https://www.etsi.org/deliver/etsi_ts/103500_103599/10352303/01.01.01_60/ts_10352303v010101p.pdf) 里的eTLS允许static key pair，相对来说仍有风险。
