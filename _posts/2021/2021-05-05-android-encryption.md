---
layout: post
category: tech
title:  "android: encryption"
tagline: ""
tags: [ "android" ] 
---
{% include JB/setup %}

* TOC
{:toc}

# doc 

[Encryption](https://source.android.com/security/encryption)

user data 的 对称加密 机制

# FBE(file-based encryption) , android 7

system/vold

`contents_encryption_mode`: aes-256-xts, or adiantum

`filenames_encryption_mode`: aes-256-cbc-cts, aes-256-heh, or adiantum

android 11 的 flags 选项：
- v2 的 kdf 好一些, HKDF-SHA512
- `inlinecrypt_optimized`是针对inline encryption hardware的优化，仅为每个CE/DE key派生一个file contents encryption key，而非为每个文件独立派生key
- `emmc_optimized`与`inlinecrypt_optimized`类似，限制IV为32-bit
- `wrappedkey_v0`: FBE由keymaster生成，以per-boot ephemeral key作为wrap key，加密FBE keys。kernel把wrapped keys传给inline encryption hardware。

## Direct Boot

FBE支持Direct Boot，重启后锁屏状态下，accessibility services / alarms /phone 等关键服务仍可用。

FBE-enable device，两种storage location:
- Credential Encrypted (CE) storage: 用户解锁后可用
- Device Encrypted (DE) storage: Direct Boot模式 & 用户解锁后均可用

## adoptable storage, android 9

SD card上的文件也支持FBE/metadata encryption

## Key derivation

FBE keys在TEE keymaster里，由另一个aes-256-gcm key加密存储

使用该key需要：
- auth token: gatekeeper提供，keymaster鉴权
- stretched credential: 基于user credential + salt，使用scrypt算法派生
- secdiscardable hash: 一个随机生成的16KB文件的512-bit hash，与派生密钥的seed共同加密存储。

# FDE(full-disk encryption) , android 5 ~ android 9

FDE使用单个key保护the whole of a device’s userdata partition，该key由user's device password保护。

基于block device layer encryption，dm-crypt

encryption algorithm: AES-128-CBC, ESSIV:SHA256; master key以aes-128 key加密

首次启动时，设备随机生成128-bit Master Key。使用scrypt对default_password + salt做hash，再使用TEE HBK对hash做签名，对签名+salt再做scrypt hash，派生出KEK/IV；KEK AES-CBC 加密Master Key。

用户设置PIN/pattern/password后，重新生成KEK，重新加密master key。

# Metadata encryption, android 9

“ 由于在元数据加密密钥可用之前，userdata 分区中的所有内容均无法读取，因此分区表必须留出一个名为“metadata 分区”的单独分区，用于存储保护该密钥的 Keymaster Blob。metadata 分区的大小应为 16MB。”

加密“未被FBE加密的”的内容，例如file-size, permissions，等等。

metadata key由keymaster保护。

AES-256-XTS, 4096-byte device block。

# Enabling Adiantum

如果CPU支持AES指令，例如ARMv8 Cryptography Extensions or an x86-based device with AES-NI，优先选取AES。

其次选取Adiantum。
