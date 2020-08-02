---
layout: post
category: tech
title:  "Roughtime Protocol"
tagline: ""
tags: [ "time" ] 
---
{% include JB/setup %}

* TOC
{:toc}

[Roughtime: Securing Time with Digital Signatures](https://blog.cloudflare.com/roughtime/)

其实主要是ntp没有啥安全校验，sntp的authenticated key又挺弱的

Roughtime是client先发一个nonce。

server端回复timestamp+radius，并且打签名的时候把nonce带上。

server端的public key合法性可以由上一级的delegator签名来校验。
