---
layout: post
category: tech
title:  "SAML & CA SSO (SiteMinder) & OAuth2 & OpenID & FIDO & Kerberos"
tagline: "身份认证协议"
tags: [ "saml", "ca", "oauth2", "openid", "fido" ] 
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

# OpenID

[OpenID Specifications](http://openid.net/developers/specs/)

[Authentication and Authorization: OpenID vs OAuth2 vs SAML](https://spin.atomicobject.com/2016/05/30/openid-oauth-saml/)

RP (Client) 向 OP 请求验证，

End-User 登录 OP

OP向RP返回认证应答

RP从OP获取用户信息

OpenID 在 OAuth2 的基础上，提供identity统一认证信息

# FIDO

[FIDO (Fast Identify Online) 笔记](https://abbypan.github.io/2015/11/15/fido-pay)

# Kerberos

Kerberos的关键在于KDC的安全性。

client 事先与 KDC 有共享密钥，server 事先与 KDC 也有共享密钥。

client 向 KDC 请求票据，再根据该票据向server请求资源。

票据是时间敏感的。
