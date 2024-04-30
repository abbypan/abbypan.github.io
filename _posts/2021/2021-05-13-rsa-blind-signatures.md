---
layout: post
category: crypto
title:  "RSA Blind Signature"
tagline: ""
tags: [ "rsa", "privacy" ] 
---
{% include JB/setup %}

* TOC
{:toc}

# doc 

[rsa blind signature](https://datatracker.ietf.org/doc/draft-irtf-cfrg-rsa-blind-signatures/)

[Crypt::RSA::Blind](https://metacpan.org/pod/Crypt::RSA::Blind)

[RFC8017](https://tools.ietf.org/html/rfc8017)

RSABSSA 核心是:
- 基于rsassa-pss的扩展, privte key 仅做token issuance
- 不像privacy pass，server 不用调private key校验token

untracable payment

# RSABSSA

    client -> server :  blinded_msg, inv = blind(pkS, msg)
    server -> client :  blind_sig = blind_sign(skS, blinded_msg)
    client : sig = Finalize(pkS, msg, blind_sig, inv)

## blind

假设message为原始消息，加随机prefix变成`input_msg`，根据`EMSA-PSS-ENCODE(input_msg, kBits - 1) -> OS2IP`转换为m。

注意m、n应互质。

随机生成mod n的r，求解`r_inv = inverse_mod(r, n)`

    x = RSAVP1(pkS, r) = r^e mod n 
    z = m * x mod n
    blinded_msg = I2OSP(z, kLen)
    inv = I2OSP(r_inv, kLen)

## blindSign

    z = OS2IP(blinded_msg)
    blind_s = RSASP1(skS, z) = z^d mod n = (m^d) * (r^e)^d mod n = (m^d) * r mod n
    z' = RSAVP1(pkS, blind_s)
    z' == z
    blind_sig = I2OSP(blind_s, kLen)

## Finalize

    blind_s = OS2IP(blinded_sig) 
    r_inv = OS2IP(inv)
    s = blind_s * r_inv mod n = (m^d) mod n
    sig = I2OSP(s, kLen)
    result = RSASSA-PSS-VERIFY(pkS, msg, sig)

# security

timing side channel

message robustness: 专private key专用，不要混用

salt: secure random

key substitution attack: 已知(message, signature, skS, pkS)，构造(skA, pkA)同样可以校验(message, signature)。注意识别the expected public key。

alternative rsa encoding function: rsa-fdh (full domain hash)，fdh is deterministic, pss is probabilistic

alternative blind signature scheme: blind bls，需要支持pairing group
