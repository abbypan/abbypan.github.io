---
layout: post
category: tech
title:  "Android: Keystore"
tagline: ""
tags: [ "android" ] 
---
{% include JB/setup %}

* TOC
{:toc}

# doc

[Keystore](https://source.android.com/security/keystore)

[Samsung Attestation](https://docs.samsungknox.com/dev/knox-attestation/about-attestation.htm)

[Trusty Keystore](https://projectacrn.github.io/2.0/tutorials/trustyACRN.html)


# Features

public key & private key: PKCS#8 format, DER。without password-based encryption。

symmetric key: raw bytes

## Root of trust binding

keystore keys 与 root of trust public key 绑定

root of trust  public key 是安全启动的签名校验的信任锚点

如果root of trust public key 出现变更，则与之绑定的keystore keys无法使用

## Velocity

支持设置`TAG::MIN_SECONDS_BETWEEN_OPS`、`TAG::MAX_USES_PER_BOOT`

# Key and ID Attestation

[Android Key Attestation Sample](https://github.com/google/android-key-attestation)

[Data Storage on Android](https://mobile-security.gitbook.io/mobile-security-testing-guide/android-testing-guide/0x05d-testing-data-storage)

[Examining the value of SafetyNet Attestation as an Application Integrity Security Control](https://census-labs.com/news/2017/11/17/examining-the-value-of-safetynet-attestation-as-an-application-integrity-security-control/)

[Implementing Trusted Endpoints in the Mobile World](https://www.slideshare.net/linecorp/implementing-trusted-endpoints-in-the-mobile-world)

##  key attestation, android 7

attestation key及对应的certificate chain，由产线写入。

根据application的需求生成key pair(public key & private key)，由attestation key对public key签发leaf certificate。

application server可以根据leaf certificate的chain，对public key的合法性进行认证。

application server 与 attestation server 之间可以有后台互联。

attestation相关信息在certificate的extension域。

### unique ID

HBK is a unique hardware-bound secret known to the Trusted Execution Environment and never revealed by it.

基于HBK，结合counter/application ID/...等信息计算HMAC，作为unique ID。

##  ID attestation, android 8

extension域里加一些attestation ID的关联信息。

注意server要给challenge/nonce。

# Version Binding

`Tag::OS_VERSION`、`Tag::OS_PATCHLEVEL`

Devices with Android Verified Boot (AVB) can put all of the patch levels and the system version in vbmeta, so the bootloader can provide them to Keymaster.

Keymaster TA 从bootloader 安全获取版本信息，在非安全系统启动之前处理。

