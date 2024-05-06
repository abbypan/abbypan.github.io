---
layout: post
category: protocol
title:  "dbsc"
tagline: ""
tags: [ "cookie", "security", "token" ] 
---
{% include JB/setup %}

* TOC
{:toc}

# doc

[Device Bound Session Credentials](https://github.com/WICG/dbsc)

背景与 [tls token binding](/2016/07/26/tls-security) 类似。

基于TPM生成私钥，在login之后基于JWT登记公钥，周期性refresh cookie。

架构简化，删除了token binding中原有的tls session的binding设计，转而强调/专注于short-live cookie，业务服务器部署成本下降。

与fido2/webauthn互补。
