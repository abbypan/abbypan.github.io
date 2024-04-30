---
layout: post
category: crypto
title:  "PQC: hash based signature"
tagline: ""
tags: [ "crypto", "hash", "signature", "rfc" ] 
---
{% include JB/setup %}

* TOC
{:toc}

# 参考

[Hash-based Signatures](http://www.pqsignatures.org/index/hbs.html)

[Hash-Based Signatures Part I: One-Time Signatures (OTS)](https://cryptoservices.github.io/quantum/2015/12/04/one-time-signatures.html)

[Merkle Signature Schemes, Merkle Trees and Their Cryptanalysis](https://www.emsec.ruhr-uni-bochum.de/media/crypto/attachments/files/2011/04/becker_1.pdf)

[RFC8391: XMSS: eXtended Merkle Signature Scheme](https://datatracker.ietf.org/doc/rfc8391/)

[RFC8554: Leighton-Micali Hash-Based Signatures](https://datatracker.ietf.org/doc/rfc8554/)

# Lamport

准备：私钥->HASH->公钥； 

签名：Message->按bit的0,1映射到对应的私钥； 

校验：Message->按bit的0,1映射到对应的签名bit，计算hash，检查是否与公钥匹配； 


# Winternitz OTS (WOTS)

准备： 

把HASH函数目标长度s，随机选择w，计算t=⌈s/w⌉+⌈(⌊log2⌈s/w⌉⌋+ 1 +w)/w⌉ 

随机选私钥 X = (X1, …, Xt)，均为s bits.  

计算Yi = H^(2^w-1)(Xi)，公钥为Y=H(Y1 || … || Yt) 

 
签名： 

将长度为s的消息M按w长分块，并计算checksum,并将checksum值也按w长分块，获得b1, …, bt。 

    sig_i = H^(bi)(Xi) 

    sig = (sig_1 || … || sig_t) 


校验： 

    sig_i’ = H^(2^w-1-bi)(sig_i) = H^(2^w-1-bi)(H^(bi)(Xi))= Yi 

    H(sig_1’ || … || sig_t’) = Y 


# Winternitz OTS+ (WOTS+)

[W-OTS+– Shorter Signatures for Hash-BasedSignature Schemes](https://huelsing.net/wordpress/wp-content/uploads/2013/05/wotsspr.pdf)

指定了r\_i与x做xor，f_k做迭代。

r_1 .. r_i 迭代计算，随机生成的 r

f_k 是此次选择的函数

对应 (sk_1 , ... , sk_l) 是 sk = secret key

其他内容与WOTS基本一致

# Merkle-Signature Scheme(MSS) 

希望复用public key 

选择一个n, 建一棵层为n+1的二叉树，最底层(n=0)叶子为H(Yi) , i = 0, … , 2^(n-1). 

(Xi, Yi) 为一个keypair, Yi为公钥。 

An  = a_(n, 0) 为第n+1层的最左边的节点，即公钥。 

sig’ 是此次选用(Xi, Yi)执行单次签名的结果。 

    sig = (sig’ || auth0 || … || auth_n-1) 

其中，auth0 到 auth_n-1表示从底层H(Yi)叶子到顶层public key的路径上的其他节点的值。 

 
校验： 

首先校验sig’。 

再根据H(Yi)结合auth0 … auth_n-1计算An是否与公钥完全一致。 

# xmss

[Hash-Based Signatures Part IV: XMSS and SPHINCS](https://cryptoservices.github.io/quantum/2015/12/08/XMSS-and-SPHINCS.html)

[XMSS – A Practical Forward Secure Signature Scheme based on Minimal Security Assumptions](https://eprint.iacr.org/2011/484.pdf)

[XMSS - A Practical Forward Secure Signature Scheme](https://slideplayer.com/slide/6080497/)

xmss的每个节点与邻居一起hash之前，自己会先xor一个bitmask。

xmss tree的叶子节点存的不是公钥的hash，而是一个L-tree的根节点。

每个L-tree的叶子节点存的是WOTS+的public key。

L-tree节点与领居一起hash之前，也会先xor一个bitmask。注意L-tree的mask与xmss tree的mask不同；所有L-tree共用相同的mask配置。

