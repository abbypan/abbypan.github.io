---
layout: post
category: tech
title:  "ASN.1, Certificate, PKCS, openssl"
tagline: ""
tags: [ "pki", "certificate", "x509v3", "openssl", "pkcs" ] 
---
{% include JB/setup %}

* TOC
{:toc}

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

# PKCS#7

[RFC2315 PKCS #7: Cryptographic Message Syntax](https://tools.ietf.org/html/rfc2315)

PEM: Internet Privacy-Enhanced Mail, as defined in RFCs 1421-1424

BER: Basic Encoding Rules for ASN.1, as defined in X.690

DER: Distinguished Encoding Rules for ASN.1, as defined in X.690.  DER is a subset of BER.

## ContentInfo

    ContentInfo ::= SEQUENCE {
         contentType ContentType,
         content
           [0] EXPLICIT ANY DEFINED BY contentType OPTIONAL }

ContentType: data, signedData, envelopedData, signedAndEnvelopedData, digestedData, and encryptedData

对于 signed-data, signed-and-enveloped-data, or digested-data 的数据，会先对DER编码的conten作hash计算

对于 enveloped-data or signed-and-enveloped-data 的数据，会根据content-encryption algorithm对内容做加密，写入定长的BER编码content域

## SignedData

    SignedData ::= SEQUENCE {
         version Version,
         digestAlgorithms DigestAlgorithmIdentifiers,
         contentInfo ContentInfo,
         certificates
            [0] IMPLICIT ExtendedCertificatesAndCertificates
              OPTIONAL,
         crls
           [1] IMPLICIT CertificateRevocationLists OPTIONAL,
         signerInfos SignerInfos }

## SignerInfo

    SignerInfo ::= SEQUENCE {
         version Version,
         issuerAndSerialNumber IssuerAndSerialNumber,
         digestAlgorithm DigestAlgorithmIdentifier,
         authenticatedAttributes
           [0] IMPLICIT Attributes OPTIONAL,
         digestEncryptionAlgorithm
           DigestEncryptionAlgorithmIdentifier,
         encryptedDigest EncryptedDigest,
         unauthenticatedAttributes
           [1] IMPLICIT Attributes OPTIONAL }

## DigestInfo

    DigestInfo ::= SEQUENCE {
         digestAlgorithm DigestAlgorithmIdentifier,
         digest Digest }

## EnvelopedData

    EnvelopedData ::= SEQUENCE {
         version Version,
         recipientInfos RecipientInfos,
         encryptedContentInfo EncryptedContentInfo }

       RecipientInfos ::= SET OF RecipientInfo

       EncryptedContentInfo ::= SEQUENCE {
         contentType ContentType,
         contentEncryptionAlgorithm
           ContentEncryptionAlgorithmIdentifier,
         encryptedContent
           [0] IMPLICIT EncryptedContent OPTIONAL }

       EncryptedContent ::= OCTET STRING

## RecipientInfo

encryptedKey 是用recipient's public key加密content-encryption key的结果，确保只有recipient能解密获取content-encryption key

    RecipientInfo ::= SEQUENCE {
         version Version,
         issuerAndSerialNumber IssuerAndSerialNumber,
         keyEncryptionAlgorithm

           KeyEncryptionAlgorithmIdentifier,
         encryptedKey EncryptedKey }

       EncryptedKey ::= OCTET STRING

## SignedAndEnvelopedData

    SignedAndEnvelopedData ::= SEQUENCE {
         version Version,
         recipientInfos RecipientInfos,
         digestAlgorithms DigestAlgorithmIdentifiers,
         encryptedContentInfo EncryptedContentInfo,
         certificates
            [0] IMPLICIT ExtendedCertificatesAndCertificates
              OPTIONAL,
         crls
           [1] IMPLICIT CertificateRevocationLists OPTIONAL,
         signerInfos SignerInfos }

## DigestedData

ContentInfo里的content是被计算摘要的content

    DigestedData ::= SEQUENCE {
         version Version,
         digestAlgorithm DigestAlgorithmIdentifier,
         contentInfo ContentInfo,
         digest Digest }

       Digest ::= OCTET STRING

## Signed-and-enveloped-data content type 过程

随机生成 content-encryption key 

用 recipient's public key 加密 content-encryption key 

加密后的content-encryption key和recipient关联信息，打包到RecipientInfo

根据signer指定的hash算法计算content对应的message-digest

message-digest及其关联信息用signer's private key加密得到res，再用content-encryption key对res做一次加密。注意第二次加密时，res可能要先padding到固定长度

上面二次加密的内容，以及siger的关联信息，打包到SignerInfo

content用content-encryption key加密

前面提到的message-digest算法、RecipientInfo、SignerInfo、encrypted content一起打包到SignedAndEnvelopedData


当recipient收到数据后，先用自身私钥解密获得content-encryption key；然后解密content；然后解密上面二次加密的message-digest；根据解密的content计算message-digest，与解密得到的message-digest比对。

# PKCS#10

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

# PKCS#12

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

# openssl

[The Most Common OpenSSL Commands](https://www.sslshopper.com/article-most-common-openssl-commands.html)

[openssl command](https://gist.github.com/webtobesocial/5313b0d7abc25e06c2d78f8b767d4bc3)

[How to Convert certificates between PEM, DER, P7B/PKCS#7, PFX/PKCS#12](https://myonlineusb.wordpress.com/2011/06/19/how-to-convert-certificates-between-pem-der-p7bpkcs7-pfxpkcs12/)

示例文件见 [openssl_cmd](https://github.com/abbypan/openssl_cmd)

{% highlight bash %}
#连接在线证书，列出trust chain
$ openssl s_client -connect www.taobao.com:443

#生成RSA4096的PKCS#10 格式CSR文件 test.csr，私钥为 test.key
$ openssl req -nodes -newkey rsa:4096 -keyout test.key -out test.csr -subj "/C=CN/ST=Anhui/L=Hefei/O=USTC/OU=Cybersecurity/CN=PB02210"
$ openssl req -noout -text -in test.csr

#生成自签名证书
$ openssl req -x509 -sha256 -nodes -days 365 -newkey rsa:4096 -keyout CA.key -out CA.crt  -subj "/C=CN/ST=Anhui/L=Hefei/O=USTC/OU=West/CN=Information Science and Technology"
$ openssl x509 -in CA.crt -text -noout

#用CA.key为test.csr签名
$ openssl req -verify -in test.csr -text -noout
$ openssl x509 -req -days 360 -in test.csr -CA CA.crt -CAkey CA.key -CAcreateserial -out test.crt -sha256
$ openssl x509 -text -noout -in test.crt

#PEM/DER证书转换
$ openssl x509 -outform der -in test.crt -out test.der
$ openssl x509 -inform der -in test.der -out test.pem

#PKCS #7文件转换
$ openssl crl2pkcs7 -nocrl -certfile test.crt -out test.p7b -certfile CA.crt
$ openssl pkcs7 -print_certs -in test.p7b -out test_with_trust_chain.cer

#PKCS #12文件转换
$ openssl pkcs12 -export -out test.pfx -inkey test.key -in test.crt -certfile CA.crt -password pass:sometestpw
$ openssl pkcs12 -in test.pfx -out test_all.cer -nodes -password pass:sometestpw
$ openssl pkcs12 -in test.pfx -out test_only_priv.cer -nodes -nocerts -password pass:sometestpw
$ openssl pkcs12 -in test.pfx -out test_only_cert.cer -nodes -nokeys -password pass:sometestpw
{% endhighlight %}
