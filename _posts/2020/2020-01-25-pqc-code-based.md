---
layout: post
category: crypto
title:  "PQC: code based"
tagline: ""
tags: [ "crypto", "pqc", "goppa", "mceliece" ] 
---
{% include JB/setup %}

* TOC
{:toc}

# Goppa编码

[Toward Practical Code-Based Cryptography](https://slideplayer.com/slide/14588965/)

[Goppa Codes](http://orion.math.iastate.edu/linglong/Math690F04/Goppa%20codes.pdf)

[Goppa code](https://www.yumpu.com/en/document/read/43452907/goppa-codes-and-the-mceliece-pkcs-weblearnhs-bremende-)

加密兼纠错

C = u*G， G 为 k x n 生成矩阵，将k长的u转换为n长的C

奇偶校验矩阵 H，满足 G*H' = 0 ，其中H'为H的转置

c = mG + e，e为random t-error vector

s = cH' = mGH' + eH' = eH'

逆推可求得e

再 c - e，解得m 


# McEliece

[2017 Code-based Cryptography](https://2017.pqcrypto.org/exec/slides/cbctuto-ecrypt.pdf)

[2016 Code-Based Cryptography](https://pqcrypto2016.jp/data/Lange-20160223.pdf)

[A Course in Cryptography](https://books.google.co.jp/books?id=y9uyDwAAQBAJ&printsec=frontcover&hl=zh-CN#v=onepage&q=Goppa&f=false)

[应用编码与计算机密码学](https://books.google.co.jp/books?id=RL8Kvu8l5qUC&pg=PA132&lpg=PA132&dq=goppa+%E7%BC%96%E7%A0%81&source=bl&ots=mNoIJfgzM2&sig=ACfU3U1CDdv8b9vFgQ57MXMfFMsX5RwQYg&hl=zh-CN&sa=X&ved=2ahUKEwiXopr0757nAhVpJaYKHX6fBmIQ6AEwCHoECAkQAQ#v=onepage&q=goppa%20%E7%BC%96%E7%A0%81&f=false)


公钥为Goppa码的生成矩阵G1

私钥为t-bounnded decoder，记为p(x)

加密： y = xG1 + e，e为汉明weight <= t的随机项

解密： p(y)G'，其中G1*G' = 1

细节： 

k -> n ，原文编码到目标空间

G1 = SGP , S 为k x k 可逆, G 为 k x n 不可约生成矩阵，P 为 n x n 置换

公钥为G1

y = xSGP + e

解密： y1 = y(P^-1) = xSG + e(P^-1)

由于 e(P^-1) 的汉明weight = t，因此，可消解求得 xS

再乘以S^-1，恢复x

# Niederreiter

公钥为奇偶校验矩阵H

私钥为t-bounnded H-syndrome decode，记为p(x)

加密： eH'，其中H'为H的转置

解密：p(y) = p(eH') = e
