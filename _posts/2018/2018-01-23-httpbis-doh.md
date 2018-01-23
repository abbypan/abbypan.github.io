---
layout: post
category: tech
title:  "笔记：httpbis ORIGIN & Secondary Certificate Authentication ; DNS DOH"
tagline: ""
tags: [ "dns", "http" ] 
---
{% include JB/setup %}

* TOC
{:toc}

# DOH: DNS Queries over HTTPS

https://tools.ietf.org/html/draft-ietf-doh-dns-over-https-02

端到端安全。防DNS阻断、污染。

新增 application/dns-udpwireformat，POST请求的body提交的是原始查询包；GET请求提交的是base64url(RFC4648)

这个比较适合android之类客户端到递归的场景。

押1个桔子，针对递归服务器的IP blocking要上升。

# DNS wire-format over HTTP 

https://tools.ietf.org/html/draft-ietf-dnsop-dns-wireformat-http-01

与DOH相比，主要是tunnel/proxy模式的区别

此处省略100字。。。

# The ORIGIN HTTP/2 Frame

https://tools.ietf.org/html/draft-ietf-httpbis-origin-frame-06

一个新头部origin，用于server主动提示client某些域名可以复用当前http2连接（不用发起多个连接）

这个主要帮CDN厂商省钱

http流量重组变得更麻烦了，那啥监控分析的成本也会提高

# Secondary Certificate Authentication in HTTP/2 

https://tools.ietf.org/html/draft-ietf-httpbis-http2-secondary-certs-00

这个感觉是为了配合上面的ORIGIN省钱搞出来的配套……

提供在HTTP层获取CA的机制，注意这跟之前的TLS握手不在一个层了。死道友不死贫道，跟你死我也一起死的区别。

5.1节说的很清楚了。

    Rather than needing to subvert DNS or IP routing in order to use a compromised certificate, a malicious server now only needs a client to connect to _some_ HTTPS site under its control in order to present the compromised certificate.
