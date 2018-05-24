---
layout: post
category: tech
title:  "dns multiple question drafts 对比分析"
tagline: ""
tags: [ "dns" ] 
---
{% include JB/setup %}

* TOC
{:toc}

# 说明

最近有小伙伴问起这几个draft的区别，就随手记一下。

个人认为在浏览器具备prefetch的功能、且client到递归的时延较短、递归侧hot domain常驻缓存的场景下，多响应优化效果不会太大。

对于冷域名的某些关联场景，accompanying-questions / additional-answers 可以纳入考虑。

# draft-bellis-dnsext-multi-qtypes

同时查多种RR记录，比如可以同时查MX跟A

# draft-yao-dnsop-accompanying-questions

客户端主动指定除了当前查的，还想查其他一些别的内容，请服务器一起发过来

相当于pull模式，节省时延

重点在于客户端/浏览器优化支持

# draft-vavrusa-dnsop-aaaa-for-free-00

方便ipv6推广，查A的时候顺便返回AAAA

# draft-wkumari-dnsop-multiple-responses

服务器主动多返回关联域名（比如www域名顺便说这个域名还关联image/data/css之类的域名）

N个web站点都要多配一个extra记录，此外每个web站点嵌的M个域名很可能是动态变化的

运维性价比较低

# draft-fujiwara-dnsop-additional-answers

从一些常见的关联场景出发，让服务器主动返回同一域名下关联的多种RR（比如查MX同时返回MX对应的A）

场景相对靠谱(push模式)，只是灵活度不如accompanying-questions
