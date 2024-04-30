---
layout: post
category: android
title:  "Android: Verified Boot"
tagline: ""
tags: [ "android" ] 
---
{% include JB/setup %}

* TOC
{:toc}

# doc

[Verified Boot](https://source.android.com/security/verifiedboot)

安全启动，保护partition，防回滚。

# device state

locked / unlocked : 如果已解锁，则允许载入非Verified Boot的Root of Trust密钥签发的os。

例如pixel 2设置了一个特殊的分区`avb_custom_key`，仅当unlocked时可更新 root of trust 公钥。

# Verifying Boot

boot / dtbo 等小分区，直接计算hash。

system 之类的大分区，通过dm-verity机制计算hash。

分区hash值必须由Root of Trust计算签名。

启动时，需进行签名比对，hash值比对。如果boot之类的分区hash不符，则boot失败；如果system之类的分区不符，则是run-time失败，系统重启，boot loader进入eio mode提示错误。

Rollback Protection: 存储version，拒绝启动低版本。

# Boot Flow

检查device lock状态

检查os是否可用

检查os是否有合法签名

检查是否用户自定义root of trust

检查是否要进入eio mode

#  Implementing dm-verity 

基于ext4构建4k block size的sha256 hash tree，注意每层算hash时要加random salt。

基于hash tree构建dm-verity mapping table

使用root of trust对dm-verity table签名。

verity metadata : hash table , signature, ...

{ system image, verity metadata, hash tree }

#  Verifying system_other Partition 

Android 9 及以前的设备可能使用`system_other partition`存储preoptimized VDEX/ODEX文件。

`system_other partition`可以有`/product/etc/security/avb/system_other.avbpubkey`。

不推荐此类分区启用avb。

# Android Verified Boot

[Android Verified Boot](https://android.googlesource.com/platform/external/avb/+/master/README.md) 图比较多。

