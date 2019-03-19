---
layout: post
category: tech
title:  "ocsp must staple"
tagline: ""
tags: [ "ocsp" ] 
---
{% include JB/setup %}

* TOC
{:toc}

# 资料

[RFC7633 X.509v3 Transport Layer Security (TLS) Feature Extension](https://tools.ietf.org/html/rfc7633)

[RFC6066 Transport Layer Security (TLS) Extensions: Extension Definitions](https://tools.ietf.org/html/rfc6066)

[RFC6961 The Transport Layer Security (TLS) Multiple Certificate Status Request Extension](https://tools.ietf.org/html/rfc6961)

[OCSP Must-Staple](https://scotthelme.co.uk/ocsp-must-staple/)

[Online Certificate Status Protocol](https://wiki.wuji.cz/services:tls:ocsp)

# certificate

定义一个x509v3的tls feature extension，ocsp must-staple，在server certficate的csr配置中指定tlsfeature = status_request

    [ v3_req ]

    basicConstraints = CA:FALSE
    keyUsage         = digitalSignature, keyEncipherment
    # OCSP Must-Staple rfc7633
    tlsfeature       = status_request


其中 tlsfeature       = status_request 相当于 1.3.6.1.5.5.7.1.24 = DER:30:03:02:01:05

# tls

tls连接时，如果client收到的server certificate包含该ocsp must-staple extension，则client需要发status_request请求，要求server发ocsp stapling信息。

certificate status request/response格式见RFC6066。status_request_v2见RFC6961。

如果server没有发送对应的ocsp stapling信息给client，则根据must-staple extension的策略，client将终止连接。

client端的tls协议栈是否支持status_request extension也是一个问题。

# 安全

must-staple可以解决ocsp soft fail的缺陷。

引入了一个风险，ocsp服务器的拒绝服务，将连锁引发service无法服务，因为client会拒绝无stapling信息的tls连接。

从server方的角度，该风险是难以忍受或承受的。

如果在ocsp服务器出问题时，server切换到无must-staple的certificate，同样存在certificate缓存及tls连接效果震荡的问题。
