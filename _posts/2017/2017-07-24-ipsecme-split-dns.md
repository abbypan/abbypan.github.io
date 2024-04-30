---
layout: post
category: dns
title:  "draft: Split DNS Configuration for IKEv2"
tagline: ""
tags: [ "dns", "ietf" ] 
---
{% include JB/setup %}

IKEv2 协商参数时，可以指定内网DNS地址(split DNS)，及对应解析的私有域名。 

其他域名仍沿用client端的global DNS配置。

    CP(CFG_REQUEST) =
         INTERNAL_IP4_ADDRESS()
         INTERNAL_IP4_DNS()
         INTERNAL_DNS_DOMAIN()

    CP(CFG_REPLY) =
         INTERNAL_IP4_ADDRESS(198.51.100.234)
         INTERNAL_IP4_DNS(198.51.100.2)
         INTERNAL_IP4_DNS(198.51.100.4)
         INTERNAL_DNS_DOMAIN(example.com)
         INTERNAL_DNS_DOMAIN(city.other.com)


在ipsec tunnel场景下，能够保证对应私有服务域名的安全解析。

例如vpn场景下的访问安全等等。

其余域名解析仍使用client端设置的global DNS。
