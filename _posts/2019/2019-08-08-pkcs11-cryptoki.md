---
layout: post
category: crypto
title:  "PKCS#11 Cryptographic Token Interface"
tagline: ""
tags: [ "pkcs", "cryptoki" ] 
---
{% include JB/setup %}

* TOC
{:toc}

[PKCS #11 Cryptographic Token Interface Base Specification Version 2.40](https://docs.oasis-open.org/pkcs11/pkcs11-base/v2.40/pkcs11-base-v2.40.pdf)

第4章的object attribute hierarchy。

Objects may be created with the Cryptoki functions C_CreateObject(see Section 5.7), C_GenerateKey, C_GenerateKeyPair, C_UnwrapKey, and C_DeriveKey (see Section 5.13).

主要是一些公私钥、证书、数据类型等等信息的数据结构，以及function的通用接口。

用于sso，公钥加密，磁盘加密等等。

