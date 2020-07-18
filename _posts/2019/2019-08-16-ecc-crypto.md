---
layout: post
category: tech
title:  "SEC 1: Elliptic Curve Cryptography"
tagline: ""
tags: [ "ecc", "crypto" ] 
---
{% include JB/setup %}

* TOC
{:toc}

# Introduction 

[SEC 1: Elliptic Curve Cryptography](http://www.secg.org/sec1-v2.pdf)


# Data Types and Conversions

## Elliptic-Curve-Point-to-Octet-String Conversion

非零场景下：
- 压缩模式，octet string将以 0x02 或 0x03 开头，后面带X
- 非压缩模式，octet string将以 0x04 开头，后面带 X || Y

# Cryptographic Components

## Elliptic Curve Domain Parameters over F_p

n为基点G的阶

Cofactor h为该椭圆曲线在F_p上的点的个数除以n后的值

    T= (p, a, b, G, n, h)

    E: y^2 ≡ x^3+ax+b (mod p)

    h= #E(F_p)/n

## Elliptic Curve Domain Parameters over F_2^m

f(x)是一个m次多项式，irreducible binary polynomial

    T= (m, f(x), a, b, G, n, h)

    E: y^2+xy=x^3+ax^2+b in F_2^m

    h= #E(F_2^m)/n

## Elliptic Curve Diffie-Hellman Primitive

U与V协商，使用U的私钥*V的公钥，取x轴的值为share secret

    P= (x_P, y_P) =d_U*Q_V

    If P=O, output “invalid” and stop.

    Output z=x_P as the shared secret field element

## Elliptic Curve Cofactor Diffie-Hellman Primitive

h参与计算

    P= (x_P, y_P) = h*d_U*Q_V

    If P=O, output “invalid” and stop.

    Output z=x_P as the shared secret field element

## Elliptic Curve MQV Primitive

细节见section 3.4

U、V各含2个key pair

U将自身第2个key pair的公钥Q_2,U中的x轴的值进行模计算转换(记为~Q_2,U)

    s = d_2,U + ~Q_2,U * d_1,U mod n

再使用相同算法计算 ~Q_2,V

    P = (x_P, y_P) = h * s * ( Q_2,V + ~Q_2,V * Q_1,V )

    If P=O, output “invalid” and stop

    Output z=x_P as the shared secret field element

## Key Derivation Functions

### ANS X9.63 Key Derivation Function

Z 为上述share secret value的octet string

keydatalen 为生成目标key的预期长度

SharedInfo 为预设的共享信息，可选

Counter为4字节计数器，从 Counter=1 开始计算 K_i=Hash(Z‖Counter‖[SharedInfo])

拼接K_i，得到目标key

## MAC schemes

需要选定 MAC 函数、mackeylen、maclen

可以用 KDF 生成 mackeylen 长度的目标 mackey

mackey与消息M都转换为bit string，调用MAC函数计算得到bit string形式的 ~D

将~D转换为octet string，截取到目标maclen

## Symmetric Encryption Schemes

需要选定 对称加密 ENC 函数、enckeylen

可以用 KDF 生成 enckeylen 长度的目标 enckey

使用enckey加密消息M，得到密文C

## Key Wrap Schemes

使用 key wrap scheme 加密 enckey (K)，获得~K

使用K加密消息M，得到密文C

接收方收到的是 (~K, C) 

## Random Number Generation

业界不推荐 Dual_EC_DRBG

# Signature Schemes

## Elliptic Curve Digital Signature Algorithm (ECDSA) 

### sign

发送方U临时选定一个key pair (k, R), 其中 R = (x_R, y_R) 

    r =  x_R mod n

    H = Hash(M)

将H转换成log_2 (n) 长度内的整数值e

    s = k^−1 * ( e + r * d_U ) mod n

    Output S = (r, s)


注意r, s不能为0，只要有0，就要重新随机选一个k进行计算

### verify

接收方V获得(r, s)

以相同算法计算出e

    u_1= e * s^−1 mod n
    u_2= r * s^−1 mod n
    R = (x_R, y_R) = u_1 * G + u_2 *Q_U
    v = x_R mod n
    if v=r, output “valid”

# Encryption and Key Transport Schemes

## Elliptic Curve Integrated Encryption Scheme(ECIES)

[Integrated Encryption Scheme](https://en.wikipedia.org/wiki/Integrated_Encryption_Scheme)

### encrypt

发送方U临时选定一个key pair (k, R), 其中 R = (x_R, y_R) 

U使用R，与接收方V通过DH协商出一个Z

发送方U提供SharedInfo1 (可选), 接收方V提供SharedInfo2 (可选)

U使用KDF，基于Z和SharedInfo1生成enckey + mackey

U使用ENC函数，基于enckey加密消息M，获得EM

U使用MAC函数，基于mackey计算EM ‖ [SharedInfo2]的消息认证码，获得D

C= (~R, EM, D)

其中~R 为 Elliptic-Curve-Point-to-Octet-String Conversion 转换过的octet string

### decrypt

接收方V将~R恢复为R = (X_R, Y_R)的EC Point模式

接收方V使用R恢复出Z

...

## Wrapped Key Transport Scheme

Wrapped key Transport Scheme 是 a key wrap scheme and a key agreement scheme的结合

key agreement 可以是Diffie-Hellman, 或 MQV。

发送方U预先知道了接收方V的公钥，因此，U只需向V提供自身随机生成的临时公钥，就能获得DH agreement的密钥K。

U使用K加密随机内容密钥C，获得wrapped key W。

注意，如果U同时对多个V_1, V_2, V_3, 。。。发送相同的消息M，可能会使用同一个内容密钥C。
此时，如果只使用K，C计算出W，则存在V_i恶意泄漏C，篡改V_j收到的加密消息的风险，解决方案一般是：
- 使用C计算M的MAC值T；
- 以T做为SharedInfo参与agreement密钥K_x的计算，或者让T加入W_x的计算参数，或者基于T为每个接收方x再单独计算出一个T_x = MAC(K_x, T)。

# Key Agreement Schemes

使用Diffie-Hellman/MQV计算出一个agreement key，记为Z。再使用KDF，基于Z和SharedInfo计算出目标keydatalen的密钥K。

# Other 

B.2.1  Commentary on Elliptic Curve Domain Parameters

各crypto密钥长度的安全等级

Table 4: Alignment with other ECC standards

ECDSA, ECIES, ECDH, ECMQV, ECWKTS

ECRNG => Dual_EC_DRBG  不推荐

最后是相关信息的ASN1格式定义
