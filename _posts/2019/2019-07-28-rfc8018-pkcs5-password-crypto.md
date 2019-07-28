---
layout: post
category: tech
title:  "RFC8018 PKCS#5 Password-Based Cryptography Specification"
tagline: ""
tags: [ "rfc", "pkcs", "password" ] 
---
{% include JB/setup %}

* TOC
{:toc}

# KDF: key derivation functions

基于password, salt, iterationCount生成key

推荐用 derived_key = PBKDF2(password, salt, iterationCount, derived_key_len)

    T_l = F (P, S, c, l)

    F (P, S, c, i) = U_1 \xor U_2 \xor ... \xor U_c

    U_1 = PRF (P, S || INT (i)) ,
    U_2 = PRF (P, U_1) ,
    ...
    U_c = PRF (P, U_{c-1}) 

    DK = T_1 || T_2 ||  ...  || T_l<0..r-1>
    l = CEIL (dkLen / hLen) #总共要算多少个block
    r = dkLen - (l - 1) * hLen #最后一个block取多长


其中，PRF是PseudoRandom Functions，例如HMAC-SHA-1，HMAC-SHA-2

# ES: Encryption Scheme

推荐PBES2 Encryption Operation：

已有password，选择PBKDF2, salt, iterationCount, 生成一个derived_key

使用derived_key使用指定加密算法（例如AES-CBC-Pad, RC5-CBC-Pad）加密消息message，获得cipher

# MAS: Message Authentication Schemes

推荐使用PBMAC1：

已有password，使用 PBKDF2 生成一个derived_key

使用derived_key 与消息message 作为输入，使用underlying message authentication scheme计算出一个消息验证码T。 

MAS函数例如HMAC-SHA-1, HMAC-SHA-2

# ASN.1 Syntax

    PBKDF2-params ::= SEQUENCE {
           salt CHOICE {
               specified OCTET STRING,
               otherSource AlgorithmIdentifier {{PBKDF2-SaltSources}}
           },
           iterationCount INTEGER (1..MAX),
           keyLength INTEGER (1..MAX) OPTIONAL,
           prf AlgorithmIdentifier {{PBKDF2-PRFs}} DEFAULT algid-hmacWithSHA1 
           }

    PBES2-params ::= SEQUENCE {
          keyDerivationFunc AlgorithmIdentifier {{PBES2-KDFs}},
          encryptionScheme AlgorithmIdentifier {{PBES2-Encs}} }

    PBES2-KDFs ALGORITHM-IDENTIFIER ::=
          { {PBKDF2-params IDENTIFIED BY id-PBKDF2}, ... }

    PBMAC1-params ::=  SEQUENCE {
          keyDerivationFunc AlgorithmIdentifier {{PBMAC1-KDFs}},
          messageAuthScheme AlgorithmIdentifier {{PBMAC1-MACs}} }

