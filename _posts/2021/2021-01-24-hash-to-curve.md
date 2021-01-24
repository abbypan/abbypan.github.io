---
layout: post
category: tech
title:  "hash to curve"
tagline: ""
tags: [ "crypto" ] 
---
{% include JB/setup %}

* TOC
{:toc}

# overview

[Hashing to Elliptic Curves](https://github.com/cfrg/draft-irtf-cfrg-hash-to-curve)

[draft-irtf-cfrg-hash-to-curve](https://tools.ietf.org/html/draft-irtf-cfrg-hash-to-curve)

pake，ibe, bls signature, verifiable random functions, verifiable random functions, oblivious pseudorandom functions等场景都需要把变长的输入映射为指定ec上的point。

`Hf (hash_to_field)`: 将变长的输入映射为F上的一个element

`mapping (map_to_curve)`: 把F上的一个element 映射为 指定的F上的一条曲线E的一个point

`clear_cofactor`: 将E上的一个point 映射为 `<G>`上的一个point，注意这里`<G>`是E的子群，`<G>`的阶r为质数

encoding: 把变长的输入 映射为 指定的F上的一条曲线E的一个point
- `nonuniform encodings (encode_to_curve)`: point的分布不完全随机
- `random oracle encodings (hash_to_curve)`: point的分布随机性是proved的

encoding的关键是constant time，避免侧信道

serialization/deserialization: point 与 bit string的相互转换，这个比较简单

# `hash_to_field: expand_message`

`expand_message(message, DST, len_in_bytes)

message是变长的输入，DST是根据业务上下文指定的标识，len_in_bytes是期望输出的字节长度

expand_message_xmd：底层采用hash function，例如sha-2, sha-3, blake2

expand_message_xof: 底层采用extensible-output function，例如SHAKE, BLAKE2X

如果message是password的场景，还可以先kdf(password)处理一下

## DST

domain separation: 注意调用Hf时加上DST(doman seprartion tags)，避免不同来源因为相同的参数输入，获得相同的输出

suffix-only domain separation: Hso(msg) = H(msg || DST_ext)

prefix-suffix domain separation: Hps(DST_ext || msg || I2OSP(0, 1))

prefix-only domain separation: Hpo(msg) = H(DST_ext || msg)

XMD-HMAC domain separation:  
    DST_key_preimage = "DERIVE-HMAC-KEY-" || DST_ext || I2OSP(0, 1)
    DST_key = H(DST_key_preimage)
    Hro(msg) = HMAC-H(DST_Key, msg)

# `mapping: map_to_curve`

Montgomery curve: Elligator 2

twisted Edwards curve: twisted Edwards Elligator 2

Weierstrass curve (AB == 0): Simplified SWU

Weierstrass curve (any curve): Shallue-van de Woestijne

# `clear_cofactor`

cofactor = h = 1 的curve不用处理，例如 nist curve p-256, p-384, p-251，这些曲线拥有质数个point

默认`clear_cofactor(P) = h_eff * P`

fast cofactor clearing method的输出应当与`h_eff*P`的输出相同

如果不支持fast cofactor clearing method，可以`h_eff = h`

# suite id

curve (例如 P256), hash to field(例如 xmd:sha-256), mapping(例如SVDW, SSWU, ELL2), encoding type(RO: random oracle, NU: nonuniform)

# relate work

直接 Hn(msg) * P 的潜在风险是暴力查表

将input string做为PRNG的seed，使用随机数作为point的候选x，潜在风险是无法确定x是否能求解到一个point，无法满足constant time


