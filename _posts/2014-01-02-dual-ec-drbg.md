---
layout: post
category: crypto
title:  "Dual_EC_DRBG 随机数生成算法 NSA后门"
tagline: "crypt"
tags : ["crypt", "security", "ecc", "nist", "nsa", "backdoor" ] 
---
{% include JB/setup %}

# background

见：http://blog.0xbadc0de.be/archives/155

这个问题在于dQ=P，而 i2 .. in, o1 .. on 可以交错链式生成（没有其他伪随机参数加入计算）。

因此直接回溯至 i1Q = A，而A不超过32 bytes，可以直接进行暴力猜解。

指定x解椭圆方程求出可行的y，再计算比对o1。。。

从这点看，结尾说的没错，确实疯狂。  


# detail

[Dual EC: A Standardized Back Door](https://eprint.iacr.org/2015/767)

如果通过output可以推测PRNG的某些内部状态，进而可以推测后续的output，则PRNG是有问题的。

密码算法：设计，分析，标准化，选择，实现，部署

state-based PRNG, with f and g
    s1 = f(s0)
    r1 = g(s1)

    s2 = f(s2)
    r2 = g(s2) 

    显然，f and g应该是one way function, 且如果是

Basic Dual EC:  
    s1 = x(s0 * P)，r1 = x(s1 * Q)，显然，如果知道P=d*Q，则整个si, ri的交错序列就可以递推出来。
    假设`R = (r1, y_r1) = s1*Q`
    d*R = d*s1*Q = s1*d*Q = s1*P
    s2 = x(d*R) = x(s1*P) //可见，s2内部状态可通过r1，结合d推导出来

Dual EC 2006 with additional input： 
    t0 = s0 xor H(adin0)

    s1 = x(t0 * P)
    r1 = x(s1 * Q)
    t1 = s1 xor H(adin1)

    s2 = x(t1 * P)  // 可见，此时s2 与 r1 之间没有递推关系
    r2 = x(s2 * Q)

    s3 = x(s2 * P)  // s3 = x(d * R2) = x(d * s2 * Q) = x(s2 * P)，s3与s2/r2之间。。。
    r3 = x(s3 * Q)


Dual EC 2007 with additional input:
    t0 = s0 xor H(adin0)

    s1 = x(t0 * P)
    r1 = x(s1 * Q)

    s2 = x(s1 * P)
    t2 = s2 xor H(adin2)
    
    s3 = x(t2 * P)
    r3 = x(s3 * Q) 

    s4 = x(s3 * P) // 可见，s2与s1/r1、s4与s3/r3，s5与s4/r4之间。。。
    r4 = x(s4 * Q)

    s5 = x(s4 * P)


