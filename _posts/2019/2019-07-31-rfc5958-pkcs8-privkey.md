---
layout: post
category: tech
title:  "RFC5958 Asymmetric Key Packages"
tagline: ""
tags: [ "rfc", "pkcs", "p8" ] 
---
{% include JB/setup %}

* TOC
{:toc}

# Introduction

follow RFC5652 定义的CMS格式

# Asymmetric Key Package CMS Content Type

版本，私钥算法，私钥，属性信息，……

     AsymmetricKeyPackage ::= SEQUENCE SIZE (1..MAX) OF OneAsymmetricKey

     OneAsymmetricKey ::= SEQUENCE {
       version                   Version,
       privateKeyAlgorithm       PrivateKeyAlgorithmIdentifier,
       privateKey                PrivateKey,
       attributes            [0] Attributes OPTIONAL,
       ...,
       [[2: publicKey        [1] PublicKey OPTIONAL ]],
       ...
     }

     PrivateKeyInfo ::= OneAsymmetricKey

     Version ::= INTEGER { v1(0), v2(1) } (v1, ..., v2)

     PrivateKeyAlgorithmIdentifier ::= AlgorithmIdentifier
                                        { PUBLIC-KEY,
                                          { PrivateKeyAlgorithms } }

     PrivateKey ::= OCTET STRING
                        -- Content varies based on type of key.  The
                        -- algorithm identifier dictates the format of
                        -- the key.

     PublicKey ::= BIT STRING
                        -- Content varies based on type of key.  The
                        -- algorithm identifier dictates the format of
                        -- the key.

     Attributes ::= SET OF Attribute { { OneAsymmetricKeyAttributes } }


# Encrypted Private Key Info

     EncryptedPrivateKeyInfo ::= SEQUENCE {
       encryptionAlgorithm  EncryptionAlgorithmIdentifier,
       encryptedData        EncryptedData }

     EncryptionAlgorithmIdentifier ::= AlgorithmIdentifier
                                        { CONTENT-ENCRYPTION,
                                          { KeyEncryptionAlgorithms } }

     EncryptedData ::= OCTET STRING

# P8 file 

The private key information, OneAsymmetricKey and PrivateKeyInfo, saved as a .p8 file.

.p8 files are sometimes PEM-encoded.

中间是DER格式的EncryptedPrivateKeyInfo/PrivateKeyInfo的base64编码内容，上下加两行文本标识。

    -----BEGIN ENCRYPTED PRIVATE KEY-----
    -----END ENCRYPTED PRIVATE KEY-----

    或

    -----BEGIN PRIVATE KEY-----
    -----END PRIVATE KEY-----



# P12/PFX file

The private key information, OneAsymmetricKey and PrivateKeyInfo, are carried in the P12 keyBag BAG-TYPE.  

EncryptedPrivateKeyInfo is carried in the P12 pkcs8ShroudedKeyBag BAG-TYPE.
