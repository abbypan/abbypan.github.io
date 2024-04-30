---
layout: post
category: crypto
title:  "BLS Signatures"
tagline: ""
tags: [ "ietf", "bls", "crypto", "blockchain" ] 
---
{% include JB/setup %}

* TOC
{:toc}

# doc

[BLS Signatures: draft-irtf-cfrg-bls-signature](https://datatracker.ietf.org/doc/draft-irtf-cfrg-bls-signature/)

[BLS Multi-Signatures With Public-Key Aggregation](https://crypto.stanford.edu/~dabo/pubs/papers/BLSmultisig.html)

[BLS Signatures](https://2π.com/22/bls-signatures/)

# KeyValidate

    result = KeyValidate(PK)

valid point, not identity element, prime order subgroup point check

# CoreSign

利用pairing特性，把msg的hash2curve获得的point，与SK点乘，作为signature。

    Q = hash_to_point(message)
    R = SK * Q

# CoreVerify

    result = CoreVerify(PK, message, signature)

    检查signature对应的R point的valid、以及subgroup
    检查PK的KeyValidate

    Q = hash_to_point(message)
    C1 = pairing(Q, PK)
    C2 = pairing(R, P)
    If C1 == C2, return VALID, else return INVALID

    C2 = pairing(SK * Q, P) = pairing(Q, SK * P) = pairing(Q, PK) = C1

# Aggregate

检查`signature_i`的validation

利用signature point addition，实现signature aggregation。

signature aggregation时，优选选用较小p的E用做public key的curve。

    R = signature_1 + ... + signature_n

# CoreAggregateVerify

检查R、`PK_i`的validation

    C_i = pairing(hash_to_point(message_i), PK_i)
    C1 = C_1 * ... * C_n
    C2 = pairing(R, P)
    If C1 == C2, return VALID, else return INVALID

显然，N+1次pairing

# BLS Signatures

point addition难以控制归零风险

## Basic scheme

要求`message_i`各不相同，禁止重复

## Message augmentation

原始message前面带上PK，再去做`hash_to_point`

    message = PK || message

## Proof of possession

把PK作为msg，计算signature，作为proof

相当于原始message的siganture +  PK的proof 都要校验

size/cost都要增加

在此模式下，如果message完全相同，可以优化为2次paring的FastAggregateVerify:

    R = signature_1 + ... + signature_n
    PK = PK_1 + ... + PK_n
    CoreVerify(PK, message, signature)

## BLS Multi-Signatures With Public-Key Aggregation

[BLS Multi-Signatures With Public-Key Aggregation](https://crypto.stanford.edu/~dabo/pubs/papers/BLSmultisig.html)

[Compact Multi-signatures for Smaller Blockchains](https://link.springer.com/chapter/10.1007/978-3-030-03329-3_15)

增加一个H映射： `(t_1, ..., t_n) = H1(PK_1, ..., PK_n)`

    PK_i~ = PK_i ^ t_i
    signature_i~ = signature_i ^ t_i

当message完全相同时，同样能优化为2次pairing

i关联信息变一点，重算一遍

# security

rogue key attack: 不是valid key，但构造的signature、pk能够通过aggregation verification。其根源在于没有proof校验、以及point addtion的归零

DST区分

KeyValidate

point validation

side channel attack (constant time)

CSPRNG

# use case

blockchain的transaction block size优化，节省signature空间

涉及cash的rogue key attack风险性更高
