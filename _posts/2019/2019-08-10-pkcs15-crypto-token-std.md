---
layout: post
category: tech
title:  "PKCS #15 v1.1: Cryptographic Token Information Syntax"
tagline: ""
tags: [ "pkcs" ] 
---
{% include JB/setup %}

* TOC
{:toc}

# intro

[PKCS #15 v1.1: Cryptographic Token Information Syntax](ftp://ftp.cert.dfn.de/pub/pca/docs/PKCS/ftp.rsa.com/pkcs-15/pkcs-15v1_1.pdf)

[Teletrust PKCS series](ftp://ftp.arnes.si/security/crypto-tools/rsa.com/rsalabs/teletrust/)

# Introduction

PKCS#11 是定义标准API，PKCS#15 是定义标准存储数据结构

例如private key, cert, pin, password/secret key, account info, permission，等等

# Symbols, abbreviated terms and document conventions

AID: application provider identifier

APDU: application protocol data unit

# Overview

PKCS#15 包含4大类的objects：Keys, Certificates, AuthenticationObjects  and  Data  Objects.

Keys包含公钥、私钥、对称密钥

Certificates包含x509证书、或其他证书

AuthenticationObjects包含PIN码、或其他生物识别信息（例如指纹）

Data Objects则是其他外部数据

## Access methods

IC card场景，访问private object必须经过Authentication  Objects的处理，例如，输入PIN码之类

公开信息则允许直接读取，例如公钥

# IC card file format

PKCS#15 包含 EF(ODF, Object  Directory  File)，相当于一个索引文件，其中包含指向其他PuKDF，PrKDF，CDF(certificate directory file)，AODF(authentication object directory file)，DODF(data object directory file)等内容的指针。

EF(TokenInfo) 包含卡片制造商、卡片标签、卡片容量等相关信息

# CommonKeyAttributes

有两个关键的KeyAttributes

    KeyUsageFlags ::= BIT STRING {
          encrypt                       (0),
          decrypt                       (1),
          sign                          (2),
          signRecover                   (3),
          wrap                          (4),
          unwrap                        (5),
          verify                        (6),
          verifyRecover                 (7),
          derive                        (8),
          nonRepudiation                (9)
    }

    KeyAccessFlags ::= BIT STRING {
           sensitive            (0),
           extractable          (1),
           alwaysSensitive      (2),
           neverExtractable     (3),
           local                (4)
    }


Table 2 – Mapping between PKCS #15 key usage flags and X.509 keyUsage extension flags

| X.509 KeyUsage  | PKCS#15 public key usage | PKCS#15 private key usage |
| ----- | ------ | ----- |
| DataEncipherment | Encrypt | Decrypt
| DigitalSignature, keyCertSign, cRLSign | Verify | Sign
| DigitalSignature, keyCertSign, cRLSign | VerifyRecover | SignRecover
| KeyAgreement | Derive | Derive
| KeyEncipherment | Wrap | Unwrap
| NonRepudiation | NonRepudiation | NonRepudiation


# Software token (virtual card) format

敏感信息 follow PKCS#7 的格式

# B.3 Read-Only and Read-Write cards

Table 4 – Possible access conditions

NEV(总是禁止)，ALW(总是允许)，CHV(成功校验后允许)，SYS(card issuer提供system key后允许)

Table 5 -Recommended file access conditions

对各种file的access推荐设置
