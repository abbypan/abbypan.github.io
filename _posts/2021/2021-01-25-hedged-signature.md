---
layout: post
category: tech
title:  "Hedged Fiat-Shamir Signature"
tagline: ""
tags: [ "crypto", "signature" ] 
---
{% include JB/setup %}

* TOC
{:toc}

# overview

[Security of Hedged Fiat-Shamir Signatures under Fault Attacks](https://eprint.iacr.org/2019/956)

[slide: Security of Hedged Fiat–Shamir Signatures under Fault Attacks](https://akiratk0355.github.io/file/slides_EC20_short.pdf)


Fiat-Shamir Signature Scheme的问题是randomness failure, nonce靠不住。

EdDSA有de-randomized Scheme, 但容易被fault attack，太确定了也不好。

hedged signature把 secret key, message, nonce 凑一起，改进randomness failure & fault attack的问题。例如XEdDSA，Picnic2。

RSA-PSS抗non-random fault

RFC 6979 ECDSA也是de-randomized

# hedged Fiat-Shamir signature scheme

已知公私钥对 (pk, sk)

HE (hedged extractor): 基于 sk, nonce, message 输出一个随机数 p

Com (commitment): 基于 p 输出公私钥对(a, St)

H (hash function): 基于 pk, a, message 计算一个hash值e

Resp (response): 基于sk, St, e 计算签名值z

CSF (canonical serialization function): 输出最终的签名结构体sig

## XEdDSA

    p <- H'(sk, message, nonce) //HE
    (a, St) <- ([p]G, p)  //Com
    e <- H(a, message, pk)  //H
    z <- p + e * sk mod q  //Resp
    sig <- (a, z) //CSF

# canonical identification protocol

ID = (IGen, Com, Resp, V)
- IGen生成公私钥对(pk, sk)，其中pk为statement, sk为witness
- Prover 生成随机数 p, 结合sk，派生公私钥对(a, St)，其中a为commitment, St为state
- Verifier随机生成challenge e
- Prover基于 sk, e, St 计算 Resp 签名 z
- Verifier 基于 a, e, z, pk 进行签名校验

# EC-Schnorr signing

    p <- random
    (a, St) <- ([p]G, p)  //Com
    e <- H(a, message)  //H
    z <- p + e * sk mod q  //Resp
    sig <- (e, z) //CSF

# EdDSA signing

    (sk, K) <- H''(k)
    pk <- [sk]G
    p <- H'(K, m)
    (a, St) <- ([p]G, p)  //Com
    e <- H(a, message, pk)  //H
    z <- p + e * sk mod q  //Resp
    sig <- (a, z) //CSF
