---
layout: post
category: device
title:  "android: avb"
tagline: ""
tags: [ "android", "avb" ] 
---
{% include JB/setup %}

* TOC
{:toc}

# doc

[android verified boot 2.0](https://android.googlesource.com/platform/external/avb/+/master/README.md)

链式签名信任，上一级img硬编码下一级img的签名公钥

pbl -> secure boot pub key

sbl -> avb pub key0

vbmeta -> boot/system/vendor,  xxx partition's pub key & rollback protection flag

