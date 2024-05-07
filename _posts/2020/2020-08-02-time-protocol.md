---
layout: post
category: protocol
title:  "Time Protocol"
tagline: ""
tags: [ "time", "ntp", "rfc", "nts"  ] 
---
{% include JB/setup %}

* TOC
{:toc}

# Roughtime

[Roughtime: Securing Time with Digital Signatures](https://blog.cloudflare.com/roughtime/)

其实主要是ntp没有啥安全校验，sntp的authenticated key又挺弱的

Roughtime是client先发一个nonce。

server端回复timestamp+radius，并且打签名的时候把nonce带上。

server端的public key合法性可以由上一级的delegator签名来校验。

# NTS 

[RFC8915: Network Time Security for the Network Time Protocol](https://tools.ietf.org/html/rfc8915)

这篇的设计比较好。

Server拆分成2个角色：NTS-KE Server，NTP Server

## NTS-KE Server

client通过TLS连接到NTS-KE Server进行首次密钥协商，port 4460

双方使用RFC7301的 tls alpn 机制指定 nts-ke 协议，节省rtt

双方使用RFC5705的 tls exported key material机制派生K，节省rtt

NTS-KE使用K加密cookie相关内容。

NTS-KE向NTP Server同步(I, K)。

## cookie

NTP Server的内容密钥信息(P)由Server随机生成，包含3部分：
- The AEAD algorithm negotiated during NTS-KE.
- The S2C key.
- The C2S key.

随机生成唯一标识I，用于标识K

随机生成N: nonce

使用K，结合nonce，加密P，获得C

Cookie形式为：(I, N, C)。

## NTP Server

Client 使用 cookie 向 NTP Server 发送时间同步请求。

NTP Server基于cookie中的I定位到对应的K，再使用K，结合N，解密C，获得P。

NTP Server使用P中的C2S/S2C key处理相关NTP数据，响应包中带I。

NTP Server可以随机生成新的(I, K)，使用K包装新的P，在响应包中带上新的Cookie信息。

## 安全

NTS-KE Server负责非对称，NTP Server负责对称，减少资源消耗型ddos风险

通过cookie机制减少放大攻击的风险

通过AEAD减少劫持的风险

通过NTP Server的(I, K)轮转减少非对称的资源消耗
