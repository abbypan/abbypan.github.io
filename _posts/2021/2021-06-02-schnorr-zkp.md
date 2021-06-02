---
layout: post
category: tech
title:  "RFC8235: Schnorr Non-interactive Zero-Knowledge Proof"
tagline: ""
tags: [ "rfc", "zkp" ] 
---
{% include JB/setup %}

* TOC
{:toc}

# doc 

[RFC8235: Schnorr Non-interactive Zero-Knowledge Proof](https://datatracker.ietf.org/doc/html/rfc8235)

Finite Field & EC 通用。

IZK Proof  -> NIZK Proof

# Finite Field

假设 Fp 有限域，取 q | p - 1

Gq 为`Zp*`的一个阶为q的子群，g 为 Gq 的生成元

假设 Alice 公私钥对为 { a, A = g^a mod p }

## interactive ZKP

Alice: 随机生成v， 0 <= v <= q-1，计算 V = g^v mod p

Alice -> Bob : V

Bob: 随机生成一个challenge c，例如c长度为160 bits

Bob -> Alice: c

Alice: 计算 r = v - a*c mod q

Alice -> Bob: r

Bob: 已知Alice的公钥 A，检查 1 <= A <= p-1， A^q = 1 mod p

Bob: 校验 V = g^r * A^c mod p

##  non-interactive ZKP

challenge c 基于 Alice 提供的相关信息生成，而非从Bob处获取

c = H( g || V || A || UserID || OtherInfo )

NIZK Proof:  { UserID, OtherInfo, V, r }

Hash的bit length不低于q

Bob可以校验c

### variants

也可以不传(V, r)，只传(c, r)。

Bob计算 V = g^r * A^c mod p

再根据 c = H( g || V || A || UserID || OtherInfo ) 校验c。

传c不传V的主要优势在于：传输的字节变少

显然，此variatnts的字节压缩，对Finite Field的公钥有效、对EC的compressed point效果有限

# EC

E(Fp), G 为 E(Fp) 上的一个阶为 n 的子群的生成元

注意，n为质数，该子群的cofactor 为 h。

假设 Alice 公私钥对为 { a, A = G x [a] }

## interactive ZKP

Alice: 随机生成v，1 <= v <= n-1，计算 V = G x [v]

Alice -> Bob : V

Bob: 随机生成一个challenge c，例如c长度为80 bits

Bob -> Alice: c

Alice: 计算 r = v - a*c mod n

Alice -> Bob: r

Bob: 已知Alice的公钥 A，检查 A 是该curve上的valid point:  A x [h] 不是无穷远点

Bob: 校验 V = G x [r] + A x [c]


## non-interactive ZKP

challenge c 基于 Alice 提供的相关信息生成，而非从Bob处获取

c = H( G || V || A || UserID || OtherInfo )

NIZK Proof:  { UserID, OtherInfo, V, r }

Bob可以校验c

# application

Bob 如何获取 Alice 的公钥信息

Bob 如何对 Alice的公钥 进行公钥安全检查

OtherInfo 里可以放一些与Alice有关的信息，其效果与self-signed CSR类似

# security

确保 v 的随机性；如果v可预测，或者固定，其风险与ECDSA Sony PS4案例相同。

注意避免重放攻击。


