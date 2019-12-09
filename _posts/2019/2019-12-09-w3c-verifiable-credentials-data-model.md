---
layout: post
category: tech
title:  "w3c: Verifiable Credentials Data Model"
tagline: ""
tags: [ "credentials" ] 
---
{% include JB/setup %}

* TOC
{:toc}

# 概要

[Verifiable Credentials Data Model](https://www.w3.org/TR/vc-data-model/)

整体的思路是区分issuer, holder, verifier, verifiable data registry。

与传统PKI体系的不同在于，这个verifiable data registry支持非Credential内容本身、基于Credential内容而派生的Presentation的校验。

也就意味着：
- Holder可以在一定privacy policy下选择性的模糊化部分内容组装成Presentation，并将这部分的消息登记到verifiable data registry；
- verifiable data registry找issuer确认为真；
- verifer再去问verifiable data registry时，就可以校验Presentation，而非Credential的所有内容。

# 格式

verifiable credential 的结构与传统PKI证书类似，包含metadata（属性信息）、claims（关联信息）、proof（签名）。

verifiable presentation 包含metadata（属性信息），verifiable credentials(支持多份)、proofs(支持多份，与verifiable credentials一一对应)；针对这三项内容组成的presentation本体，还可以再打一个presentation proof签名。

数据以json形式组织，签名链式校验参考[Linked Data Proofs](https://w3c-dvcg.github.io/ld-proofs/)，签名内容采用RFC7797的JSON Web Signature (JWS) Unencoded Payload Option。

参考阅读JSON Web系列的RFC7515，RFC7516，RFC7519，RFC8259。

# Zero-Knowledge Proofs

参考示例，必须定义credentialSchema，指定所选用的Zero-Knowledge系统；必须定义Proof，让verifier可以校验签名，确信内容为真。

# privacy & security

后面是一些privacy讨论。

还有之前分析过的tls token binding，RFC8471。
