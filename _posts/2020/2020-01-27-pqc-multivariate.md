---
layout: post
category: crypto
title:  "PQC: Multivariate Cryptography"
tagline: ""
tags: [ "pqc", "crypto", "polynomials" ] 
---
{% include JB/setup %}

* TOC
{:toc}

# overview 

[public key cryptography Multivariate crypto](https://www.slideserve.com/birch/summary)

[Current State of Multivariate Cryptography](https://www.researchgate.net/publication/319170467_Current_State_of_Multivariate_Cryptography)

S : m -> m 的映射

F : n -> m 的映射，一元二次方程组

T : n -> n 的映射

公钥 P = S . F . T : n -> m 的映射

# UOV : Unbalanced Oil and Vinegar signature scheme

n = o + v

V =  { 1, ..., v }

O = { v+1, ..., n }

如果 o = v ，称为 Balanced Oil and Vinegar

如果 v > o，称为 Unbalanced Oil and Vinegar

center map , F : n -> o

注意多项式中的x_i*x_j项，要么是 i, j均属于V，要么是i属于V且j属于O。

仅有T，没有S。

公钥 P = F . T

F^-1求解时，例如已知y ( y_1, ..., y_o)，随机选择 x_1, ..., x_v，可代入求解得到 x_v+1 , ..., x_n

签名计算：hash(message) = w, 通过w求F^-1的逆x，再求解T^-1的逆z，z即为签名。

签名校验：w' = P(z)，比较w = w'

# Rainbow Signature

分多个Vinegar + Oil层

0 < v_1 < v_2 < ... < v_u+1 = n

V_1 : { 1, ..., v_1 },  O_1: { v_1 + 1, ..., v_2 }

V_2 : { 1, ..., v_2 }, O_2: { v_2 + 1, ..., v_3 }

可见V_2迭代覆盖 V_1 + O_1

m = n - v_1

l = 1, ..., u

每个l对应的V_l + O_l都对应一个方程

迭代求解时，例如已知 y (y_1, ..., y_m)， 随机选择x_1, ..., x_v1

根据 y1, ..., y_v2-v1 求得 x_v1+1, ..., x_v2

根据 y_v2-v1+1, ..., y_v3-v1 求得 x_v2+1, ..., x_v3

其他与UOV一致


# HFE: Hidden Fields Equations

[Solving Systems of Quadratic Equation](https://www.slideserve.com/niveditha/solving-systems-of-quadratic-equations)

[Hidden Field Equations(HFE) and Isomorphisms of Polynomials(IP): two new Families of Asymmetric Algorithms](http://www.minrank.org/hfe.pdf)

[Winter school-pq2016v2](https://www.slideshare.net/LudovicPerret/winter-schoolpq2016v2)

F 为有限域多项式


# SimpleMatrix (ABC) Encryption

[Simple Matrix Scheme for Encryption](https://www.researchgate.net/publication/268028336_Simple_Matrix_Scheme_for_Encryption)

[Simple Matrix – A Multivariate Public Key Cryptosystem (MPKC) for Encryption](https://www.researchgate.net/publication/279636226_Simple_Matrix_-_A_Multivariate_Public_Key_Cryptosystem_MPKC_for_Encryption)

n = s^2

m = 2*n

A, B, C 为3个 s x s 的矩阵

E1 = A . C, E2 = B . C

central map F : 由E1, E2拼成，m个方程

公钥 P = S . F . T  ， n -> m

加密：w = P(z) 

解密：

x = S^-1 (w)

F(y) = x

将 x = (x_1, ..., x_m) 拆入 E1, E2，其中，x_1, ..., x_n 为E1的对角线，x_n+1, ..., x_m 为E2的对角线

根据E1, E2, A的可逆状况，分类型求解。

例如，如果A可逆，

    求解 A^-1 . E1 - B = 0, A^-1 . E2 - C = 0

    得到 A^-1 的 r_1, ..., r_n

    r1, ..., r_n, y_1, ..., y_n 结合得到m元，运用高斯消元，恢复 y_1, ..., y_n


## 问题

E1, E2, A 如果都不可逆，解密就会失败







