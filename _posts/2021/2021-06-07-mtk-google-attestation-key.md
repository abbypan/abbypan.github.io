---
layout: post
category: device
title:  "MTK: Google Attestation Key Tool User Guide"
tagline: ""
tags: [ "android", "google", "mtk" ] 
---
{% include JB/setup %}

* TOC
{:toc}

# doc 

[MTK for Google AttestationKey介绍](https://blog.csdn.net/weixin_42135087/article/details/106761192)

各soc自行设计google Attestation key的写入方案，qualcomm与mtk不同。。。

mtk方案概要：
- 将Attestation Key信息拆分为多个`kb_xxx.bin`，每个bin对应一组key
- 随机生成aes密钥kkb，加密`kb_xxx.bin`，获得密文`kb_xxx.bin.cipher`。
- 使用rsa私钥`kkb_priv`加密kkb，获得ekkb。
- 使用rsa私钥`kkb_priv`对`kb_xxx.bin.cipher`签名。
- 随机生成aes密钥pkkb，加密rsa公钥`kkb_pub`，获得`ekkb_pub`。

# security

pkkb可以省，密钥跟密文在一起。。。

ekkb也可以省，私钥加密数据。。。

搞个数字信封完事。。。 
