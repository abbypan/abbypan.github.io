---
layout: post
category : security
title:  "Dual_EC_DRBG 随机数生成算法 NSA后门"
tagline: "crypt"
tags : ["crypt", "ecc", "nist", "nsa", "backdoor" ] 
---
{% include JB/setup %}

见：http://blog.0xbadc0de.be/archives/155

这个问题在于dQ=P，而 i2 .. in, o1 .. on 可以交错链式生成（没有其他伪随机参数加入计算）。

因此直接回溯至 i1Q = A，而A不超过32 bytes，可以直接进行暴力猜解。

指定x解椭圆方程求出可行的y，再计算比对o1。。。

从这点看，结尾说的没错，确实疯狂。  
