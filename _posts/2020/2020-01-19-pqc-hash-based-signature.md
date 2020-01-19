---
layout: post
category: tech
title:  "PQC: hash based signature"
tagline: ""
tags: [ "crypto", "hash", "signature" ] 
---
{% include JB/setup %}

* TOC
{:toc}

# 参考

[Hash-based Signatures](http://www.pqsignatures.org/index/hbs.html)

[Hash-Based Signatures Part I: One-Time Signatures (OTS)](https://cryptoservices.github.io/quantum/2015/12/04/one-time-signatures.html)

# Lamport

# Winternitz OTS (WOTS)

# Winternitz OTS+ (WOTS+)

[W-OTS+– Shorter Signatures for Hash-BasedSignature Schemes](https://huelsing.net/wordpress/wp-content/uploads/2013/05/wotsspr.pdf)

指定了r\_i做xor，f_k做迭代计算。

# xmss

[Hash-Based Signatures Part IV: XMSS and SPHINCS](https://cryptoservices.github.io/quantum/2015/12/08/XMSS-and-SPHINCS.html)

xmss的每个节点与邻居一起hash之前，自己会先xor一个bitmask。

xmss tree的叶子节点存的不是公钥的hash，而是一个L-tree的根节点。

每个L-tree的叶子节点存的是WOTS+的public key。

L-tree节点与领居一起hash之前，也会先xor一个bitmask。注意L-tree的mask与xmss tree的mask不同；所有L-tree共用相同的mask配置。

