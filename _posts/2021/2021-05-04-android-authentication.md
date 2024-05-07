---
layout: post
category: device
title:  "Android: Authentication"
tagline: ""
tags: [ "android" ] 
---
{% include JB/setup %}

* TOC
{:toc}

# doc 

[Authentication](https://source.android.com/security/authentication)
- 密钥安全存储：keystore & keymaster => TEE/SE
- 凭据校验：Gatekeeper (PIN/Pattern/password)、Fingerprint；BiometricPrompt整合fingerprint & additional biometrics。这些组件通过authenticated channel与keystore service交互authenticated state。
- 凭据校验 + keystore 实现 hardware-backed authentication tokens (AuthTokens)

## enrollment

设备重置之后的首次重启，用户初始化Gatekeeper的PIN/pattern/password，随之绑定一个PRNG 64-bit的user secure identifier(SID)。

SID与credential一起参与相关key/AuthTokens的派生。

用户更新credential，如果成功提供旧credential，SID不变；如果无法提供旧credential，则随机生成新SID，旧key无法恢复。

## Authentication

android：gatekeeperd, keystore service, fingerprintd；android daemon可以调用底层对应的TEE接口。

TEE: gatekeeper, keymaster, fingerprint；TEE组件之间共享secret key，用于校验message。

认证过程：
- 用户输入credential，调用对应的android daemon（例如gatekeeperd/fingerprintd等）
- android daemon发送相关内容到TEE：
    fingerprintd 发送 PIN/pattern/password 的hash 到 TEE gatekeeper。如果gatekeeper校验成功，则gatekeeper返回一个AuthToken，该AuthToken含SID，并且signed with AuthToken HMAC key
    fingerprintd 发送 相关指纹数据到 TEE fingerprint。如果fingerprint校验成功，则fingerprint返回一个AuthToken, 该AuthToken signed with AuthToken HMAC key
    诸如此类
- android daemon将收到的AuthToken通过binder传给keystore
- keystore将AuthToken传给TEE keymaster
- keymaster使用与TEE gatekeeper/其他biometric component共享的AuthToken HMAC key校验AuthToken；keymaster检查AuthToken的timestamp，防重放
- keymaster最终决策是否允许对应app使用对应的key

## AuthToken Format

AuthToken:
- Version
- challenge , 64-bit: 随机ID，防重放。一般直接使用该crypto operation的ID，例如 transactional fingerprint authorizations 的应用场景。限定AuthToken仅可用于该crypto operation。
- user SID, 64-bit
- authenticator ID, 64-bit: 标识不同的authenticator policy
- authenticator type, 32-bit: 0x00 gatekeeper, 0x01 fingerprint
- timestamp, 64-bit: Time (in milliseconds) since the most recent system boot.
- AuthToken hmac, 256-bit: 对上述field的hmac

## device boot flow

每次重启后，TEE随机新鲜生成AuthToken HMAC key，该key由TEE component共享。

key共享方式由TEE OS决定。
- 如果TEE OS没有内部IPC机制，需要通过untrusted OS中转，则传输信道必须有安全协商。
- Trusty TEE的处理方式：AuthToken HMAC key仅由keymaster存储；Gatekeeper/Fingerprint需要时，向keymaster请求。

# Gatekeeper

三个部分：
- Gatekeeperd (Gatekeeper daemon)
- Gatekeeper Hardware Abstraction Layer (HAL).
- Gatekeeper (TEE)

重试限制：GateKeeper must write a failure counter before verifying a user password. 

默认推荐将failure counter写入secure storage。其次才选择Replay Protected Memory Block (RPMB)。

# Biometrics

## HAL implementation guidelines

- raw biometric data or derivatives (such as templates) : 安全存储，外部无法访问
- 安全信道(SPI, I2C等)，需要explicit SELinux policy才能访问
- biometric相关数据，加密安全存储
- To protect against replay attacks, sign biometric templates with a private, device-specific key, with the absolute file-system path, group, and biometric ID. 确保biometric data与当前device当前user绑定，无法跨设备/跨用户复制/导出。
- user remove时，清除关联的biometric data

## Biometrics强度

metrics:
- Spoof Accept Rate (SAR)
- Imposter Accept Rate (IAR)
- False Accept Rate (FAR)

classified:
- strong
- weak
- convenience

## Fingerprint HAL 

与fingerprint hardware相关的Serial Peripheral Interface (SPI) ，仅能由TEE访问，explict SELinux policy

## Face Authentication HIDL

For devices to comply with the strong biometric requirements for Android 10, they must have secure hardware to ensure the integrity of face data and the ultimate authentication comparison.

Additionally, secure camera hardware is required to prevent injection attacks on face authentication. For example, the associated memory pages for image data could be privileged and marked read-only so only the camera hardware can update them.

# Protected Confirmation

关键操作的硬件确认，例如双击侧边按钮，确认付款。

注意，kernel无法tamper Protected Confirmation显示的内容。kernel可以控制的部分，例如system on chip (SoC) or power management integrated circuit (PMIC)，不能连到 physical confirmation button。

需要Trusted UI。
