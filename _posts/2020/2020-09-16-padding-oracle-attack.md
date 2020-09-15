---
layout: post
category: tech
title:  "CBC: Padding Oracle Attack"
tagline: ""
tags: [ "cbc", "attack" ] 
---
{% include JB/setup %}

* TOC
{:toc}

# doc

[Proj 14: Padding Oracle Attack](https://samsclass.info/141/proj/p14pad.htm)

[Advanced Web Hack: Padding Oracle Attack](https://slideplayer.com/slide/4625352/)

    plaintext_n是pkcs5 padding的

    cipher_n = enc(k, cipher_n-1 xor plaintext_n)
    plaintext_n = dec(k, cipher_n) xor cipher_n-1

    intermediate(n) = dec(k, cipher_n)

## 反推最后1 byte

修改`cipher_n-1`的最后1 byte，解密时，会影响`plaintext_n-1`整个block，以及`plaintext_n`的最后1 byte。

解密时，`plaintext_n`应该是pkcs5 padding ok的，而不应当是padding error。

因此，可以把`cipher_n-1`的前15 byte置随机，然后尝试依次修改`cipher_n-1`的最后 1 byte(从 0x00 ~ 0xFF) 解密。

假设当`cipher_n-1`的最后1 byte取值为 0x93 = 147 时解密成功，根据 pkcs5 padding的设置，`plaintext_n`的最后 1 byte 应该是 0x01。

可以反推`intermediate(n) = dec(k, cipher_n)`的最后1 byte 应该是  0x01 xor 0x93 = 0x92 = 146


## 反推倒数第2个byte

因此，可以把`cipher_n-1`的前14 byte置随机，然后尝试依次修改`cipher_n-1`的倒数第2个byte(从 0x00 ~ 0xFF) 解密。

根据 pkcs5 padding的设置，解密成功时，`plaintext_n`的最后 2 byte 应该是 0x02 0x02。

所以应该把`cipher_n-1`的最后 1 byte置为 0x92 xor 0x02 = 0x90

假设当`cipher_n-1`的倒数第2 byte取值为 0x06 = 6 时，解密成功。

可以反推`intermediate(n) = dec(k, cipher_n)`的倒数第2 byte 应该是  0x02 xor 0x06 = 0x04

## 依此类推...

获取整个`intermediate(n) = dec(k, cipher_n)`，再恢复`plaintext_n`

# summary

把 2^128 的暴力破解尝试降到O(256*len)，大概是指数降到常数的差别

攻击成功的前提是，有“oracle”机制可以不断尝试

