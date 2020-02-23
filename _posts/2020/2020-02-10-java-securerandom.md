---
layout: post
category: tech
title:  "JAVA: securerandom"
tagline: ""
tags: [ "crypto" ] 
---
{% include JB/setup %}

* TOC
{:toc}

# 参考

[The Right Way to Use SecureRandom](https://tersesystems.com/blog/2015/12/17/the-right-way-to-use-securerandom/)

[SecureRandom](https://developer.android.com/reference/java/security/SecureRandom.html)

[Insufficient cryptographic randomness](https://www.computest.nl/advisories/CT-2019-0704_spring-security.txt)

[Class SecureRandom](https://docs.oracle.com/javase/7/docs/api/java/security/SecureRandom.html)

[SecureRandom漏洞解析](http://www.droidsec.cn/securerandom%E6%BC%8F%E6%B4%9E%E8%A7%A3%E6%9E%90/)


# 概要 

new SecureRandom() 之后，如果直接调用nextBytes，默认使用SecureRandom对象(例如/dev/urandom)自身做为seed。

setSeed是往当前seed数组增补内容，而非替换。

因此，不要在SecureRandom之后直接调用setSeed设置可预测/固定seed。

可以考虑先SecureRandom，再nextBytes，再setSeed。

