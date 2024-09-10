---
layout: post
category: crypto
title:  "kyber kex"
tagline: ""
tags: [ "pqc", "kyber", "crypto", "lattice" ] 
---
{% include JB/setup %}

* TOC
{:toc}

# doc

[kyber](https://leancrypto.org/papers/index.html)

kyber 是 ml-kem，见nist fips 203。

hybrid扩展为KyberIES，结构比较简单。

kex扩展可以是2-way kex (3 kem), 或 unliteral kex (2 kem), implicit authentication。这个会慢一点。

    c: (ct_s, ss_2) = encap(pk_s)
    c: (sk_e, pk_e)
    c -> s:  ct_s, pk_e

    s: ss_2 = decap(ct_s, sk_s)
    s: (ct_r0, ss_0) = encap(pk_e)
    s: (ct_r1, ss_1) = encap(pk_c)
    s:  ss = ss_0 || ss_1 || ss_2
    s -> c:  ct_r0, ct_r1

    c: ss_0 = decap(ct_r0, sk_e) 
    c: ss_1 = decap(ct_r1, sk_c) 
    c:  ss = ss_0 || ss_1 || ss_2 
