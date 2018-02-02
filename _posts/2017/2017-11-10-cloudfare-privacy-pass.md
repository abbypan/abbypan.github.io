---
layout: post
category: tech
title:  "Privacy Pass"
tagline: ""
tags: [ "CAPTCHA" ] 
---
{% include JB/setup %}

* TOC
{:toc}

# 场景

[Privacy Pass: A browser extension for anonymous authentication](https://medium.com/@alxdavids/privacy-pass-6f0acf075288)

[Privacy Pass - “The Math”](https://blog.cloudflare.com/privacy-pass-the-math/)

[Challenge Bypass Extension](https://github.com/privacypass/challenge-bypass-extension)

主要针对匿名访问时用户重复输入验证码的问题

利用椭圆曲线交互认证，用户一次获得多个token（默认一次认证成功自动生成30个）

那么下回用户向edge服务器再次请求在cloudflare托管的其他站点内容时，就不用再次输入验证码，cloudflare直接验token即可（该token之前没用过）

可以算做server端防ddos策略影响用户浏览体验的一种折中方案，privacy另议。

# Signing phase

    C samples a random ‘blind’ r ← ZZ_q  #模为q的整数环
    C computes T = H_1(t) and then blinds it by computing rT  
    C sends M = rT to S
    S computes Z = xM and returns Z to C
    C computes (1/r)*Z = xT = N and stores the pair (t,N) for some point in the future #C无法知道S的私钥x

# Redemption phase

    C calculates request binding data req and chooses an unspent token (t,N)
    C calculates a shared key sk = H_2(t,N) and sends (t, MAC_sk(req)) to S  #sk即共同密钥
    S recalculates req' based on the request data that it witnesses
    S checks that t has not been spent already and calculates T = H_1(t), N = xT, and sk = H_2(t,N)  #确定t还没用过，用私钥x计算出sk
    Finally S checks that MAC_sk(req') =?= MAC_sk(req), and stores t to check against future redemptions

