---
layout: post
category: tech
title:  "Key Blinding for Signature Schemes"
tagline: ""
tags: [ "ietf", "signature", "crypto" ] 
---
{% include JB/setup %}

* TOC
{:toc}

# doc 

[Key Blinding for Signature Schemes](https://datatracker.ietf.org/doc/draft-irtf-cfrg-signature-key-blinding/)

核心是：unforgeability and unlinkability

参考RFC8032 EdDSA的处理。

    s1 || prefix1 = hash(skS)

引入一个private bk 。ctx 类似 DST，用于区分标识。 

    s2 || prefix2 = hash(bk || 0x00 || ctx)

s2 与 pkS 点乘，即为pkR

计算signature时，s1*s2, prefix1 || prefix2 

实现了同一个skS，映射不同的 pkR，计算不同的signature。

# security

[On the Security of the Schnorr Signature Scheme and DSA against Related-Key Attacks](https://eprint.iacr.org/2015/1135)

Schnorr/ECDSA 可被Related-Key Attacks构造signature攻击。

针对Schnorr的攻击主要在于s值的h'倍增，这个比较无聊。

针对DSA的攻击能够构造新H(m)，结合弱hash，风险性较高。

缓解方案：改造 H( m || r || pk(x) )，注意公钥从x动态导出。
