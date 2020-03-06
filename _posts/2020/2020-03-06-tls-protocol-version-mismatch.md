---
layout: post
category: tech
title:  "TLS record layer 与 handshake layer 的 protocol version mismatch"
tagline: ""
tags: [ "tls" ] 
---
{% include JB/setup %}

* TOC
{:toc}

# 参考

[Different version TLS in record layer and handshake layer #1689](https://github.com/openssl/openssl/issues/1689)

[Appendix E.  Backward Compatibility](https://tools.ietf.org/html/rfc5246#appendix-E)

Record Layer, Content Type: Handshake, Version: TLS 1.0 (0x0301)

Handshake Protocol, Handshake Type: Client Hello, Version: TLS 1.2 (0x0303)

主要是为了后向兼容性。

旧版本server可能拒绝Record Layer > TLS 1.0 的请求 => 这种可以去死一死了。

主要以 Handshake Protocol 里的 Protocol Version 为准。
