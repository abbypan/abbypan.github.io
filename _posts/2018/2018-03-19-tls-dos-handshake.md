---
layout: post
category: tech
title:  "Extension for protecting (D)TLS handshakes against Denial of Service"
tagline: ""
tags: [ "tls", "security" ] 
---
{% include JB/setup %}

* TOC
{:toc}

# 概要

见 [Extension for protecting (D)TLS handshakes against Denial of Service](https://tools.ietf.org/html/draft-tiloca-tls-dos-handshake-02)

背景：由于tls连接的first packet，clienthello需要非对称密钥计算资源，伪造ip容易造成cpu cost型的dos攻击

大概方案：引入一个trust anchor(TA): 与tls server(S)共享对称密钥K_M，向client提供基于nounce及K_M计算的MAC。

1) client向TA请求与S进行handshake

2) TA向client返回``{ N = token_nonce, MAC = HMAC(K_M, H(token_nonce)) }``

3) client向S发送clienthello，带有2)中的"dos_protection" extension信息

4) S根据TA共享的K_M，以及一定时间窗内valid的nounce信息，验证该dos_protection，决定是否响应handshake请求

# 分析

此方案试图通过对称加密计算MAC，来节省无效cipher suite计算所消耗的防御资源

传统proxy型的连接保护： client <-> proxy <-> server

引入ta不需要处理连接转发等问题（节省防御模块的部署难度），但是需要client及server同时支持该扩展（终端部署成本转移）

这个的实效问题，跟dns cookie类似，专用终端＋专用服务可以试点，海量终端不好推
