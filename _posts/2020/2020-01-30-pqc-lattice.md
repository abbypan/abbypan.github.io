---
layout: post
category: crypto
title:  "PQC: Lattice-based"
tagline: ""
tags: [ "crypto", "lattice", "pqc" ] 
---
{% include JB/setup %}

* TOC
{:toc}

# 参考

[Lattice-based Cryptography](https://pqcrypto2016.jp/data/Nguyen-pdf-PQC-LatticeCrypto.pdf)

[The Quantum Menace](https://reidbix.github.io/QuantumMenace/TheQuantumMenacePresentation.pdf)

[Practical Aspects of Modern Cryptography](https://slideplayer.com/slide/14252306/)

[A Decade of Lattice Cryptography](https://web.eecs.umich.edu/~cpeikert/pubs/lattice-survey.pdf)

[Summer School on real-world crypto and privacy](https://summerschool-croatia.cs.ru.nl/2018/program.shtml)

[NIST Cryptographic Standards and Guidelines](https://csrc.nist.gov/Projects/Cryptographic-Standards-and-Guidelines)

[Lattice-based Cryptography](https://pqcrypto2016.jp/data/Nguyen-pdf-PQC-LatticeCrypto.pdf)

[ETSI Quantum Safe Cryptography and Security](https://www.etsi.org/images/files/ETSIWhitePapers/QuantumSafeWhitepaper.pdf)

[ETSI Implementation Security of Quantum Cryptography](https://www.etsi.org/images/files/ETSIWhitePapers/etsi_wp27_qkd_imp_sec_FINAL.pdf)

[Lattice Based Cryptography for Beginners](https://eprint.iacr.org/2015/938.pdf)

[2019 Status Report on the First Round of the NIST Post-Quantum Cryptography Standardization Process](https://nvlpubs.nist.gov/nistpubs/ir/2019/NIST.IR.8240.pdf)

# RLWE (Ring Learning With Errors) Problem

[Introduction to post-quantum cryptographyand learning with errors](https://summerschool-croatia.cs.ru.nl/2018/slides/Introduction%20to%20post-quantum%20cryptography%20and%20learning%20with%20errors.pdf)

[Equivalence of Search and Decisional (Ring-) LWE](https://slideplayer.com/slide/14640091/)

[Learning With Errors (LWE) and Ring LWE](https://medium.com/asecuritysite-when-bob-met-alice/learning-with-errors-lwe-and-ring-lwe-accf72f98c22)

[Python and Crypto: Learning With Errors (LWE) and Ring LWE](https://asecuritysite.com/public/lwe_ring.pdf)

[The Learning with Errors Problem](https://cims.nyu.edu/~regev/papers/lwesurvey.pdf)

在F\_q有限域上的多项式 p(x) 环

    b_i(x) = a_i(x) * s(x) + e_i(x)

search LWE problem: 已知(b\_i(x), a\_i(x))求解s(x)是困难的

Decision LWE problem: 已知(b\_i(x), a\_i(x))，检查是否可以求解s(x)，还是随机pair

## RLWE-KEX

[Ring Learning With Errors for Key Exchange (RLWE-KEX)](https://medium.com/asecuritysite-when-bob-met-alice/ring-learning-with-errors-for-key-exchange-rlwe-kex-5dc0ce37e207)

b_A(x) = A * s_A(x) + e_A(x)

b_B(x) = A * s_B(x) + e_B(x)

两边交换b_A(x), b_B(x)

share_A = s_A(x) * b_B(x)  / p(x) = s_A(x) * (A * s_B(x) + e_B(x)) / p(x)

share_B = b_A(x) * s_B(x) / p(x)  = s_B(x) * (A * s_A(x) + e_A(x)) / p(x)

## LWE encryption

[Directions in Practical Lattice Cryptography Vadim Lyubashevsky IBM Research – Zurich.](https://slideplayer.com/slide/10426928/)

[On Ideal Lattices andLearning With Errors Over Rings](https://web.eecs.umich.edu/~cpeikert/pubs/slides-ideal-lwe.pdf)

[Lattice-Based Cryptography](https://slideplayer.com/slide/16130291/)

公钥为 (a, t)

a*s + e = t

随机生成(r, e1)

r*a + e1 = u

r*t + e2 + m = v

明文为m, 密文为 (u, v)

解密
    v - u*s = r*t + e2 + m - (r*a + e1)*s  
            = r*(a*s + e) + e2 + m - (r*a + e1)*s
            = m + r*e + e2 - e1*s


## LWE signature

    t = a*s + e 

    c = H( a*u + v, m )

    z = s*c + u

    a*z - t*c = a*(s*c + u) - (a*s + e)*c = a*u - e*c


# BLISS (Bimodal Lattice Signature Scheme)

[Lattice Signatures and Bimodal Gaussians](https://link.springer.com/content/pdf/10.1007/978-3-642-40041-4_3.pdf)

[Post-quantum Signature Bliss](https://medium.com/@billatnapier/post-quantum-signature-bliss-632b3904c9e9)

## 基础

私钥S, 公钥(T, A)

    T = A*S mod q

message digest μ

    c = H( A*y mod q, μ ) 

    z = S*c + y

签名 (z, c)

校验  c = H( A*z − T*c mod q, μ) = H( A*S*c + A*y − T*c mod q, μ)

## BLISS

    A*S = q*I_n mod 2q

签名
    y 为随机数
    c = H( A*y mod 2q, μ )
    b 为随机选取的0/1
    z = y + (−1)^b*S*c

校验 c = H( A*z + q*c mod 2q, μ) = H( A*y + (-1)^b*A*S*c + q*c mod 2q, μ)  

## NTRU 

[ntru prime](https://ntruprime.cr.yp.to/nist/ntruprime-20190330.pdf)

[Quantum technology and its impact on security in mobile networks](https://www.ericsson.com/en/reports-and-papers/ericsson-technology-review/articles/ensuring-security-in-mobile-networks-post-quantum)

## falcon

[falcon](https://csrc.nist.gov/CSRC/media/Presentations/Falcon/images-media/Falcon-April2018.pdf)
