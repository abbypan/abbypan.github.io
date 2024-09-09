---
layout: post
category: security
title:  "SAML & CA SSO (SiteMinder) & OAuth2 & OpenID & FIDO & Kerberos & JWT & OIDC(OpenID Connect)"
tagline: "身份认证协议"
tags: [ "saml", "ca", "oauth2", "openid", "fido", "kerberos", "jwt", "oidc" ] 
---
{% include JB/setup %}

* TOC
{:toc}

FIDO, OAuth2, CA SSO 对web服务实际效用会更好一些

# SAML

[Dev Overview of SAML](https://developers.onelogin.com/saml)

用户登录 identity provider

用户请求访问 service provider 提供的内容

service provider 重定向请求，向 identity provider 要求验证用户登录信息

identity provider 用 X.509 证书 签名认证用户已登录，以XML形式传给 service provider

service provider 据此对用户授权访问

# CA SSO (SiteMinder)

[Designing a CA Single Sign-On Architecture for Enhanced Security](https://acclaimconsulting.com/wp-content/uploads/2015/02/designing-a-ca-sso-architecture-for-enhanced-security.pdf)

传统统一登录cookie的问题之一是一次登录，全站有效。一站泄漏cookie，全站影响。

改进方案是，一次登录到一个cookie provider，如login.ca.com

由cookie provider对该域下的不同服务站点，分发不同的cookie。例如app1.ca.com的cookie与app2.ca.com的cookie不同。

此时可以把窃取cookie漏洞的影响问题限定在该漏洞子站内。

# OAuth2 

[OAuth2 笔记](https://abbypan.github.io/2016/06/03/oauth2)

# OpenID & OIDC (OpenID Connect)

[OpenID Specifications](http://openid.net/developers/specs/)

[Authentication and Authorization: OpenID vs OAuth2 vs SAML](https://spin.atomicobject.com/2016/05/30/openid-oauth-saml/)

OpenID 基于xml，部署比较麻烦。

OIDC 改成在 OAuth2 的基础上，使用RESTful HTTP & JSON实现OpenID的功能，提供identity统一认证信息

[A Framework To Implement OpenID Connect Protocol For Federated Identity Management In Enterprises](http://www.diva-portal.org/smash/get/diva2:1121361/FULLTEXT01.pdf)

RP (Client) 向 OP 请求验证，

End-User 登录 OP

OP向RP返回认证应答

RP从OP获取用户信息

# FIDO

[FIDO (Fast Identify Online) 笔记](https://abbypan.github.io/2015/11/15/fido-pay)

# Kerberos

Kerberos的关键在于KDC的安全性。

client 事先与 KDC 有共享密钥，server 事先与 KDC 也有共享密钥。

client 向 KDC 请求票据，再根据该票据向server请求资源。

票据是时间敏感的。

# JWT

RFC7515 ~ RFC7519

[5 Easy Steps to Understanding JSON Web Tokens (JWT)](https://medium.com/vandium-software/5-easy-steps-to-understanding-json-web-tokens-jwt-1164c0adfcec)

[JWT Introduction](https://jwt.io/introduction/)

[jwt-token-encrypt](https://www.npmjs.com/package/jwt-token-encrypt)

[JWT: The Complete Guide to JSON Web Tokens](https://blog.angular-university.io/angular-jwt/)

本质上是以json形式传输的bear token，可以在``Authorization: Bearer <token>``头部传输，此时由于不在cookie中，可以天然避开cors问题。

由 header.payload.signature 三部分组成。其中，header, payload默认是json格式，base64url编码。

signature 由 header.payload 加secret 组合计算hmac256得到。

此时，server可以快速校验payload里的用户信息的合法性，授权资源。缓解传统的session/cookie查找资源问题。

signature也可以使用rsa/ecdsa等签名算法生成。

如果payload中有部分敏感内容被加密，则server需要有对应的解密配置。

优点在于server端非常容易对token做轮转，json内容简单，且避开了cookie的cors等问题。缺点在于提高了对secret的安全性依赖。

