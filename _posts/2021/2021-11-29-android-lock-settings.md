---
layout: post
category: android
title:  "Android: LockSettings"
tagline: ""
tags: [ "android" ] 
---
{% include JB/setup %}

* TOC
{:toc}

# doc

[LockSettings](https://cs.android.com/android/platform/superproject/+/master:frameworks/base/services/core/java/com/android/server/locksettings/)

[VerifyCredentialResponse.java](https://cs.android.com/android/platform/superproject/+/master:frameworks/base/core/java/com/android/internal/widget/VerifyCredentialResponse.java)

# User Credential

Pattern/PIN/Password 映射为 Credential，由 Gatekeeper 负责校验。

每个user还关联一个随机的64-bit user secure identifier (SID)。

user的SID参与AuthToken的运算。

# Synthetic Password

Synthetic Password 可以由 Gatekeeper + Keymaster 保护，也可以由 Weaver 保护。

User Credential / Escrow Token 派生KEK，用于保护 Synthetic Password。

Keymaster 也生成一个KM Key保护Synthetic Password。

改User Credential，不改 Synthetic Password。

# Gatekeeper

Gatekeeper 主要用于校验 User Credential，并限制失败重试。

enroll 设置 password，计算得到password handle。

verify 基于 输入的password，重新计算 password handle，并与之前的值做比较。

# 初始化概要

随机生成 P0, P1。

Synthetic Password = hash(P0 || P1)

E0 = Encrypt(Synthetic Password, P0)

存储 .p1, .e0 文件。

基于Synthetic Password，hmac-sha256分别派生三个子KEY:  DiskEncryptionKey (用于FBE), KeystorePassword, GkPassword (用于Gatekeeper)。

user id + GkPassword 派生 spHandle，存储 .handle 文件。

Credential + scrypt 相关参数 + salt 用于派生 PasswordToken。

PasswordToken 结合 user id + 100000 = fakeUid，派生 PasswordHandle。注意PasswordHandle中还包含Gatekeeper随机生成的SID。

scrypt相关参数 + salt + PasswordHandle 记为 PasswordData，存储`<handle>.pwd`文件。注意，`<handle>`随机值是以"sp-handle"存在数据库中。

随机生成16KB的`<handle>.secdis`文件。

将PasswordToken 与 secdis 的hash值拼接，得到applicationId。

使用applicationId的hash值，作为KEK，加密Synthetic Password，获得intermediate。再使用keystore中随机生成的km key，加密intermediate，获得blob，存储为`<handle>.spblob`文件。

# 校验概要

先基于Credential，结合PasswordData信息，派生PasswordToken。再结合UserId，校验PasswordHandle。

基于PasswordToken，恢复applicationId。结合keystore，解密获得Synthetic Password。

基于Synthetic Password，校验spHandle。

使用Synthetic Password，解密CE Key => vold retrieveKey。

将CE Key install 到 keyring => vold installKey。可以只install hmac token，或者install TP加密CE KEY的密文。

# 代码

## SyntheticPasswordManager

[SyntheticPasswordManager.java](https://cs.android.com/android/platform/superproject/+/master:frameworks/base/services/core/java/com/android/server/locksettings/SyntheticPasswordManager.java)

class AuthenticationToken 
- private byte[] derivePassword(byte[] personalization) 新版用hmac-sha256，旧版用hash。
- static AuthenticationToken create() 生成 p0, p1、派生Synthetic Password、输出e0。
- public AuthenticationToken newSyntheticPasswordAndSid(IGateKeeperService gatekeeper, byte[] hash, LockscreenCredential credential, int userId)

class PasswordData 
- public static PasswordData create(int passwordType) 初始化生成scrypt相关参数

weaver
- private VerifyCredentialResponse weaverVerify(int slot, byte[] key) 值比较

function
- public long createPasswordBasedSyntheticPassword(IGateKeeperService gatekeeper, LockscreenCredential credential, AuthenticationToken authToken, int userId)  如果weaver可用，把pwdToken存入weaver；否则，基于pwdToken派生pwdHandle，派生applicationId。此函数内的sid与pwdHandle有关。
