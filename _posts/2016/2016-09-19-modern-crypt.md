---
layout: post
category: tech
title:  "笔记：现代密码学 Jonathan katz & Yehuda Lindell"
tagline: ""
tags: [ "crypt" ] 
---
{% include JB/setup %}

## Merkle-Damgard 变换

将定长的hash转换成可以处理任意长度输入的hash

假设函数h 输入长度为l

则将X的长度填充成l的倍数，按l比特分块X1, ... , Xb

初始化 Z0 = IV 为固定常量

Zi := h(Zi-1 || Xi)

最终输出 Zb+1

## Pollad的Rho方法找任意整数N的非平凡因子

随机选扫X1, 使用合适的F函数计算 Xm = F(Xm-1) mod N 序列

如果 Xi = Xj mod p (i<j) ，那么必然存在 k < j，使得 Xk = X2k mod p

因此，算法如下

Xi = F(Xi-1) mod N

X2i = F(X2i-2) mod N

p = gcd(X2i - Xi, N)

如果 p 不为 1或N，则为所求

## Pohlig-Hellman算法

离散对数给定 g，y，求一个x满足 g^x = y

当群g的阶q的任何非平凡因子已知的情况下，该算法可加速离散对数计算。

令 ord(g) = q，且 p|q，则 ord(g^p) = q/p

那么，对于q的每一个素因子qi，有 (g^(q/qi))^x = (g^x)^(q/qi) = y^(q/qi)

此时，求g^x=y的单个方程式，可以变换为上述N个素因子的联立方程组

中国剩余定理

## Goldwasser-Micali 加密

利用二次剩余。

## Paillier 加密

加法群同态

<g^y1, h^y1 * m1>  * <g^y2, h^y2 * m2> = <g^(y1+y2), h^(y1+y2) * m1 * m2>

ci = [ ( 1 + N )^vi * r^N mod N^2 ]
