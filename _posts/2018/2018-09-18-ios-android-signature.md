---
layout: post
category: android
title:  "ios/android 程序签名校验"
tagline: ""
tags: [ "ios", "android" ] 
---
{% include JB/setup %}

* TOC
{:toc}

# ios 

[iOS App 签名的原理](http://blog.cnbang.net/tech/3386/)

## 开发版

apple：私钥A-Priv、公钥A-Pub（ios设备上保留A-Pub）

开发者：私钥D-Priv、公钥D-Pub、apple网站使用A-Priv对D-Pub签名生成的证书D-Cert

程序包：程序内容App、使用D-Priv对App进行签名P-Sig、Provisioning Profile

其中，Provisioning Profile 包含{ D-Cert、设备ID列表、AppID、权限控制信息Entitlements }、以及apple网站使用A-Priv对上述信息集合进行签名C-Sig

## 发布版

将含有Provisioning Profile信息的开发版程序提交到apple网站，apple网站校验通过后，会直接使用A-Priv对App重新签名后发布，无需使用D-Priv。

# android

[签署您的应用](https://developer.android.com/studio/publish/app-signing?hl=zh-cn)

两种密钥：应用签名密钥(D-Priv)和上传密钥(U-Priv)

方案1，google保存D-Priv、包含U-Pub的证书；开发者上传U-Priv签名的App，google使用U-Pub校验，校验通过，则使用D-Priv进行签名后发布。

方案2，google不保存任何密钥信息；开发者直接上传D-Priv签名的App进行发布。


# 对比

Apple的双重签名确保了程序来自已注册的开发者账号，重新签名再发布的机制节省了不必要的公钥信息发放——在Apple的完全控制下。

Android的机制比较灵活，但是需要在程序包内置包含D-Pub的证书信息才能校验——google play不需要管理公钥/证书信息的发放。
