---
layout: post
category: device
title:  "Android: FBE"
tagline: ""
tags: [ "android", "qualcomm", "fbe", "xts", "aes", "essiv" ] 
---
{% include JB/setup %}

* TOC
{:toc}

# doc

[qualcomm: File based encryption](https://www.qualcomm.com/media/documents/files/file-based-encryption.pdf)

# android background

FBE: file based encryption

CE: Credential Encrypted, bound to user credentials

DE: Device Encrypted

Escrow tokens:  use as backup in case a user forgets credentials (PIN, password, pattern, etc).  因此，user credentials不能直接用于protect FBE keys，否则，无法兼容Escrow token的场景。

synthetic password: 使用synthetic password保护FBE keys，再使用user credentials、Escrow tokens分别保护synthetic password。多加一层。

## synthetic password protection

如何保护我synthetic passwork: Gatekeeper (GK) and Keymaster(KM), Weaver

KM: Device Unique Key 结合 Unique Context (例如User Credential, Escrow tokens) 派生一个key，该key用于加密synthetic password。

GK: 在User Credential保护synthetic password的场景下，Gatekeeper 结合 Device Unique Key + User Credential派生一个Key，基于该Key与password handle计算一个Hmac值，做为Auth Token。KM校验该Auth Token，允许解密synthetic password。

## FBE Credential Encrypted (CE) Key Protection

synthetic password 派生的key，用于加密FBE CE key。

当用户解锁设备，FBE class key会被解密、缓存在android系统进程vold中，设置在linux kernel keyring。

加解密文件时，系统从kernel keyring中将key读入 Inline crypto engine，进行加解密。

## Keyguard bound keys

仅在解锁的时候，才能decrypt file

设备锁定时，后台application仅能encrypt file

## metadata encryption

生成一个专用的keymaster key，加密除文件名、文件内容之外的所有file metadata (例如file size, file time modified, ...)。

# qualcomm 

## cryptographic binding

attack: 通过给KM发fake signal，没有提供user credentials也能成功欺骗KM解密synthetic password

需要再加一层protection

### user root key

Gatekeeper生成一个user root key。

使用Device Unique key，结合user credentials派生一个key，该key用于加密user root key。

### synthetic password protection

使用Device Unique key，结合user root key派生一个key，该key用于加密synthetic password

由于user root key 依赖于 user credentials才能解密，可以解决上面fake signal的问题。也就是说，设备启动，但是user没提供credentials，无法解密。

### Gatekeeper in Qualcomm Secure Process Unit

Qualcomm Secure Process Unit has a dedicated CPU, separate from the application processor

TRNG

secure timer

secure storage, with replay protection

## Wrapped key support for FBE

Wrapped key:
- 确保FBE keys从不明文出现在high-level OS
- short lifespan: 设备重启、或work profile shutdown后失效

## Keymaster

FBE CE class keys 由 keymaster生成，而非vold生成。

Device Unique Key结合Unique Context派生一个key，该key用于加密FBE CE key，密文记为FBE CE keyblob。

synthetic password派生的secret，用于加密FBE CE keyblob，密文记为FBE CE keyblob2（双层加密）。

此时，由于FBE CE key由keymaster保护，Android无法读取FBE CE key的明文。

## Wrapping of FBE keys

Keymaster 生成一个 per-boot / per-class / per-user 的 ephemeral key (EK) 用于 wrap FBE class keys.

## unlocking FBE CE key

设备重启，用户解锁设备后，系统获取synthetic password。

通过synthetic password解密 FBE CE keyblob2，keymaster再解密FBE CE keyblob，获得FBE CE key。

keymaster使用EK wrap FBE CE key，并将wrap key（密文）放入vold、Linux kernel keyring缓存。

当Linux kernel需要加解密文件时，调用TEE接口unwrap该key，获得FBE CE Key，并进一步派生 64 bytes 的 AES256-XTS key，载入 Inline Crypto Engine (ICE)。

## Secure key eviction

多用户场景，切换用户凭据，之前的EK wrap key等信息从vold/key ring/keymaster/ICE全清掉。。。


# AES-XTS

[XEX-based tweaked-codebook mode with ciphertext stealing (XTS)](https://en.wikipedia.org/wiki/Disk_encryption_theory#XEX-based_tweaked-codebook_mode_with_ciphertext_stealing_(XTS))

[Demystifying Full-Disk Encryption](https://www.ise.io/wp-content/uploads/2017/07/fde_whitepaper_draft_20170627.pdf)

注意XTS是有2个key的，K1用于blockencryption，K2用于输入输出的前后异或。因此，AES256-XTS的KEY是64 bytes，K1/K2各32bytes。

显然XTS会比ESSIV要好。
