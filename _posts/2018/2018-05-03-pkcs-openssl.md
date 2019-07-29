---
layout: post
category: tech
title:  "ASN.1, Certificate, PKCS, openssl"
tagline: ""
tags: [ "pki", "certificate", "x509v3", "openssl", "pkcs", "rsa" ] 
---
{% include JB/setup %}

* TOC
{:toc}

[An Overview of Cryptography](https://www.garykessler.net/library/crypto.html)

[Block Ciphers Modes of Operation](http://www.crypto-it.net/eng/theory/modes-of-block-ciphers.html)

[PKCS #12 v1.1: Personal Information Exchange Syntax](http://www.emclink.net/collateral/white-papers/h11301-pkcs-12v1-1-personal-information-exchange-syntax-wp.pdf)

# ASN.1

[ASN.1 introduction](https://www.itu.int/en/ITU-T/asn1/Pages/introduction.aspx)

# filetype: pem, cer, crt, der, p7b, p7c, p12, pfx

[Certificate filename extensions](https://en.wikipedia.org/wiki/X.509)

[What are the differences between PEM, DER, P7B/PKCS#7, PFX/PKCS#12 certificates](https://myonlineusb.wordpress.com/2011/06/19/what-are-the-differences-between-pem-der-p7bpkcs7-pfxpkcs12-certificates/)

## 证书

.pem – 证书 (Privacy-enhanced Electronic Mail) Base64 encoded DER certificate, enclosed between "-----BEGIN CERTIFICATE-----" and "-----END CERTIFICATE-----"

.cer, .crt, .der – binary DER编码的证书，或者Base64 DER编码(pem兼容)

.p7b, .p7c – PKCS#7 SignedData structure without data, just certificate(s) or CRL(s)

## 信息交换

.p12 – PKCS#12, may contain certificate(s) (public) and private keys (password protected)

.pfx – PFX personal information exchange, predecessor of PKCS#12 (usually contains data in PKCS#12 format, e.g., with PFX files generated in IIS)

# openssl

[The Most Common OpenSSL Commands](https://www.sslshopper.com/article-most-common-openssl-commands.html)

[openssl command](https://gist.github.com/webtobesocial/5313b0d7abc25e06c2d78f8b767d4bc3)

[How to Convert certificates between PEM, DER, P7B/PKCS#7, PFX/PKCS#12](https://myonlineusb.wordpress.com/2011/06/19/how-to-convert-certificates-between-pem-der-p7bpkcs7-pfxpkcs12/)

示例文件见 [openssl_cmd](https://github.com/abbypan/openssl_cmd)

# PKCS #8: Private-Key Information Syntax Specification

## Private-Key Information Syntax

版本，私钥算法，私钥，属性信息

    PrivateKeyInfo ::= SEQUENCE {
            version                   Version,
            privateKeyAlgorithm       PrivateKeyAlgorithmIdentifier,
            privateKey                PrivateKey,
            attributes           [0]  IMPLICIT Attributes OPTIONAL }

## Encrypted Private-Key Information Syntax

    EncryptedPrivateKeyInfo ::= SEQUENCE {
            encryptionAlgorithm  EncryptionAlgorithmIdentifier,
            encryptedData        EncryptedData }

encryptionAlgorithm例如pbeWithMD5AndDES-CBC

# RFC2986 PKCS #10: Certification Request Syntax

[RFC2986: PKCS #10: Certification Request Syntax Specification](https://tools.ietf.org/html/rfc2986)

CertificationRequestInfo 包含 subject distinguished name，subject public key，其他相关信息。

CertificationRequestInfo的内容用DER编码成octet string，然后使用subject's private key对其进行签名，得到a bit string

## CertificationRequestInfo

    CertificationRequestInfo ::= SEQUENCE {
            version       INTEGER { v1(0) } (v1,...),
            subject       Name,
            subjectPKInfo SubjectPublicKeyInfo{{ PKInfoAlgorithms }},
            attributes    [0] Attributes{{ CRIAttributes }}
       }

       SubjectPublicKeyInfo { ALGORITHM : IOSet} ::= SEQUENCE {
            algorithm        AlgorithmIdentifier {{IOSet}},
            subjectPublicKey BIT STRING
       }

       PKInfoAlgorithms ALGORITHM ::= {
            ...  -- add any locally defined algorithms here -- }

       Attributes { ATTRIBUTE:IOSet } ::= SET OF Attribute{{ IOSet }}

       CRIAttributes  ATTRIBUTE  ::= {
            ... -- add any locally defined attributes here -- }

       Attribute { ATTRIBUTE:IOSet } ::= SEQUENCE {
            type   ATTRIBUTE.&id({IOSet}),
            values SET SIZE(1..MAX) OF ATTRIBUTE.&Type({IOSet}{@type})
       }

# RFC7292 PKCS #12: Personal Information Exchange Syntax

[RFC7292 PKCS #12: Personal Information Exchange Syntax](https://tools.ietf.org/html/rfc7292)

PKCS #12 describes a transfer syntax for personal identity information, including private keys, certificates, miscellaneous secrets, and extensions.

Shrouding:  Encryption as applied to private keys

隐私模式：
- Public-key privacy mode: 信息以公钥加密(源, TPDestEncK)，以私钥解密(目标, VDestEncK)
- Password privacy mode: 信息以对称密钥加解密

完整性模式：
- Public-key integrity mode: 信息以私钥签名(源, VSrcSigK)，以公钥验证(目标, TPSrcSigK)
- Password integrity mode: 通过密码参与计算得到Message Authentication Code (MAC)进行验证

两类模式之间可以自由组合，注意 Password privacy mode 跟 Password integrity mode 的password可以不同

PFX PDU格式参考第4节。
- AuthenticatedSafe，AuthenticatedSafe后面可以带签名。AuthenticatedSafe自身带一系列ContentInfo信息，包含可能被加密的内容(content)。每个ContentInfo可以带一种类型的内容集合，例如private keys, certificates等等。
- MacData参数用于password integrity，可选项，包含MacValue(PKCS#7 Digest Info), MacSalt, iterationCount。MacKey由上述三个参数生成。

## PFX

     PFX ::= SEQUENCE {
           version     INTEGER {v3(3)}(v3,...),
           authSafe    ContentInfo,
           macData     MacData OPTIONAL
       }

       MacData ::= SEQUENCE {
           mac         DigestInfo,
           macSalt     OCTET STRING,
           iterations  INTEGER DEFAULT 1
           -- Note: The default is for historical reasons and its
           --       use is deprecated.
       }

## AuthenticatedSafe

     AuthenticatedSafe ::= SEQUENCE OF ContentInfo
           -- Data if unencrypted
           -- EncryptedData if password-encrypted
           -- EnvelopedData if public key-encrypted

# X.509v3

[RFC5280 Internet X.509 Public Key Infrastructure Certificate and Certificate Revocation List (CRL) Profile](https://tools.ietf.org/html/rfc5280)

[wiki X.509](https://en.wikipedia.org/wiki/X.509)

Root Certificate, Intermediate certificate, End-entity certificate

## Certificate

    Certificate  ::=  SEQUENCE  {
            tbsCertificate       TBSCertificate,
            signatureAlgorithm   AlgorithmIdentifier,
            signatureValue       BIT STRING  }

       TBSCertificate  ::=  SEQUENCE  {
            version         [0]  EXPLICIT Version DEFAULT v1,
            serialNumber         CertificateSerialNumber,
            signature            AlgorithmIdentifier,
            issuer               Name,
            validity             Validity,
            subject              Name,
            subjectPublicKeyInfo SubjectPublicKeyInfo,
            issuerUniqueID  [1]  IMPLICIT UniqueIdentifier OPTIONAL,
                                 -- If present, version MUST be v2 or v3
                                  subjectUniqueID [2]  IMPLICIT UniqueIdentifier OPTIONAL,
                                 -- If present, version MUST be v2 or v3
            extensions      [3]  EXPLICIT Extensions OPTIONAL
                                 -- If present, version MUST be v3
            }

       Version  ::=  INTEGER  {  v1(0), v2(1), v3(2)  }

       CertificateSerialNumber  ::=  INTEGER

       Validity ::= SEQUENCE {
        notBefore      Time,
        notAfter       Time }

       Time ::= CHOICE {
            utcTime        UTCTime,
            generalTime    GeneralizedTime }

       UniqueIdentifier  ::=  BIT STRING

       SubjectPublicKeyInfo  ::=  SEQUENCE  {
            algorithm            AlgorithmIdentifier,
            subjectPublicKey     BIT STRING  }

       Extensions  ::=  SEQUENCE SIZE (1..MAX) OF Extension

       Extension  ::=  SEQUENCE  {
            extnID      OBJECT IDENTIFIER,
            critical    BOOLEAN DEFAULT FALSE,
            extnValue   OCTET STRING
                        -- contains the DER encoding of an ASN.1 value
                        -- corresponding to the extension type identified
                        -- by extnID
            }

## CRL

    CertificateList  ::=  SEQUENCE  {
            tbsCertList          TBSCertList,
            signatureAlgorithm   AlgorithmIdentifier,
            signatureValue       BIT STRING  }

       TBSCertList  ::=  SEQUENCE  {
            version                 Version OPTIONAL,
                                         -- if present, MUST be v2
            signature               AlgorithmIdentifier,
            issuer                  Name,
            thisUpdate              Time,
            nextUpdate              Time OPTIONAL,
            revokedCertificates     SEQUENCE OF SEQUENCE  {
                 userCertificate         CertificateSerialNumber,
                 revocationDate          Time,
                 crlEntryExtensions      Extensions OPTIONAL
                                          -- if present, version MUST be v2
                                      }  OPTIONAL,
            crlExtensions           [0]  EXPLICIT Extensions OPTIONAL
                                          -- if present, version MUST be v2
                                      }



# PKCS #6: Extended-Certificate Syntax

# RFC2985 PKCS #9: Selected Object Classes and Attribute Types

# PKCS #11: Cryptographic Token Interface

# PKCS #13: Elliptic curve cryptography Standard

# PKCS #14: Pseudo-random Number Generation

# PKCS #15: Cryptographic Token Information Format Standard

# RFC5652 Cryptographic Message Syntax (CMS)

# RFC5083 Cryptographic Message Syntax (CMS) Authenticated-Enveloped-Data Content Type

# RFC5958 Asymmetric Key Packages
