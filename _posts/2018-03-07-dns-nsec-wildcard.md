---
layout: post
category: dns
title:  "NSEC + wildcard 的实现缺陷"
tagline: ""
tags: [ "dns", "nsec", "wildcard" ] 
---
{% include JB/setup %}

* TOC
{:toc}

详情见 [The peculiar case of NSEC processing using expanded wildcard records](https://medium.com/nlnetlabs/the-peculiar-case-of-nsec-processing-using-expanded-wildcard-records-ae8285f236be)

场景：由于NSEC记录标识owner与target之间没有子域名存在，如果同时存在 * wildcard 泛域名配置，且启用了nsec aggressive，则“将expanded wildcard records 做为NSEC的owner“的做法是有缺陷的。

例如

    nlnetlabs.nl NSEC *.nlnetlabs.nl
    *.nlnetlabs.nl NSEC buffalo.nlnetlabs.nl
    buffalo.nlnetlabs.nl NSEC nlnetlabs.nl

当使用 !.nlnetlabs.nl 查询，如果权威根据泛域名的配置进行expand，将返回 !.nlnetlabs.nl NSEC buffalo.nlnetlabs.nl 。

进一步的，如果validator启用了nsec aggressive，再次查询 albatross.nlnetlabs.nl 将返回NXDOMAIN，而根据zonefile其实应该是返回泛域名的配置，问题很大。

解决方案是，权威返回nsec记录时，不要对owner做wildcard expand。

其实吧，还不如这样更简单省事：要么整个子域全wildcard，要么不用wildcard。
