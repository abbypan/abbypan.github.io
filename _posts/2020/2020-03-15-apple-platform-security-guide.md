---
layout: post
category: tech
title:  "Apple Platform Security Guide 2019"
tagline: ""
tags: [ "apple", "mobile" ] 
---
{% include JB/setup %}

* TOC
{:toc}

# doc

[Apple Platform Security](https://support.apple.com/guide/security/welcome/web)

[Security](https://developer.apple.com/documentation/security)

[Privacy](https://www.apple.com/privacy/features/)

[data security](https://support.apple.com/en-us/HT202303)

# Hardware Security and Biometrics

uid 保护 Media Key

password + uid 保护 class key

class key 保护 volume key

volume key 保护 volume metadata & content

内部**防重放**

aes-256:  uid fused; gid compiled  => 无法读取

工厂预置Face/Touch ID与芯片的shared key，通过aes key wrapping协商session key，session 用 aes ccm

trigger Face/Touch ID的前提是校验过passcode/password。

安全敏感型的操作必须校验passcode/password：软件升级、设备重置、修改配置、解锁、重启、账号登出、多次解锁失败等。

# System Security

The Boot ROM code contains the Apple Root CA public key

Device Firmware Upgrade (DFU)

## System security in watchOS

watch 与 iphone 在 out of band (oob) process交换公钥

Apple Identity Service(IDS)

15分钟更新一次bluetooth地址

# Encryption and Data Protection

ios 256bit per-file key = 128 bit tweak + 128 bit cipher key

默认用AES-XTS

A7/S2/S3 Soc: AES-CBC, iv值用sha1(per-file key)加了个密

RFC3394 NIST AES Key Wrapping

wrapped per-file key 置于 file metadata

打开文件时，用file system key解密file metadata，然后取出wrapped per-file key，再使用对应的class key解出 per-file key

class key由uid、passcode之类的保护。

所有文件的metadata由file system volume key加密，该key仅当ios初始化时生成，且由一个long-term的key wrapping key保护。

key wrapping key仅当用户擦除device才会重置。

A9 Soc的Secure Enclave需要防重放。

每次启动生成一个临时的effaceable key加密data volume的metadata key

## Data Protection classes

### Complete Protection 

class key由 uid & passcode保护

### Protected Unless Open

一般由后台ecdh over curve25519达成后台自动同步，有一个Protected Unless Open class private key。

per-file key由a key derived using One-Pass Diffie-Hellman KeyAgreement as described in NIST SP800-56A保护。

临时的public key与wrapped per-file key放一起。

每次要用的时候，用class private key和临时的public key联合解密per-file key。

### Protected Until First User Authentication

与Complete Protection相同，但是decrypted class key在设备locked时不删。

### No Protection

class key用uid保护，放在effaceable storage里

## Keychain

两个aes-256-gcm key： table key 加密 metadata，per-row key (secret-key) 加密具体内容

keychain item可以由相同开发者的apps共享

keychain data也是分class有不同的保护力度：解锁/首次解锁/一直可用/需要Passcode。

后端需要自动同步的场景可以用：首次解锁的模式。

注意需要Passcode的那种，无法同步、无法备份、不在escrow keybags里面。

其他keychain class也支持this device only的选项，以UID保护。因此，仅能在同一台设备上备份或恢复，而不能跨设备恢复。

P46 是不同类型数据的选择。

## Encryption in macOS

FileVault => AES-XTS

# Authentication and digital signing

## smart cards

personal identity verification  (PIV) cards

PIN码解锁使用smart card对应的私钥。smart card里的证书指定了使用范围、场景、属性。

## disk image

aes 128/256 

## keybags

keybags用于管理file key, class key

包含：user, device, backup, escrow, icloud backup几种类型

user keybag: 与passcode关联

device keybag: 如果某设备只有一个账号使用，那么device keybag等同于user keybag。

backup keybag: 与backup password关联，PBKDF2。itunes可以选不加密。keychain必须加密，仅在设置了backup password的条件下备份。

escrow keybag: 用passcode保护backup中负责保护backup data class key的generated key（首次备份时临时生成）。用passcode授权生成ota场景的one time unlock token。

icloud backup keybag：class key是curve25519


# App Security

code signature => develop certificate

动态加载的library同样需要签名校验。与develop certificate里的team id关联。

只能通过系统提供的api执行background process

mobile device management(MDM)

当MFI accessory要与ios设备通信时，ios设备要求其提供certificate，并发一个challenge。accessory返回一个签名的response。

AirPlay/CarPlay 用 MFi-SAP(Secure Association Protocol)  通信，aes-128-ctr。会话协商用sts协议，其中ecdhe用curve25519，签名密钥用rsa-1024。


# Secure Notes

aes-gcm。

笔记可以有单独的passphrase。基于passphrase，使用pbkdf2, sha256生成16 byte的key。

# Service Security

## apple id

账号安全

双因子验证

密码重置

## icloud

icloud file :  aes-128

根据key与content结合sha256

存储于apple自己的云空间、aws

file content key 受 record key 保护，record key存在icloud drive metadata中，由icloud device service key保护

## keychain sync

初始化时，会生成一个sync identity的curve25519密钥对，其公钥会被签名2次：一次以其自身对应的私钥签名，另一次以icloud account password派生的p-256私钥签名。

icloud account password派生p-256私钥时所用的salt、iteration参数，也一并存储。

部分内容不同步，例如vpn连接配置信息；部分内容会同步，例如wifi密码等。由 kSecAttrSynchronizableattribute 区分。

## keychain recovery

注意sync跟recovery不同。

如果设置了双因子认证，那么recovery要求输入passcode。

如果没设置双因子认证，那么recovery要求输入之前设置的icloud security code。

托管的record，用asymmetric keybag加密。keybag用icloud security code保护，再用云端存储的hsm的公钥加密。

云端要校验icloud account password、sms确保用户处于安全登录态，然后使用SRP协议校验用户已知icloud security code，注意icloud security code本身并不会传输。

设备端使用icloud security code解出之前的keybag。

# applepay

full card number不会存在ios设备、apple pay server，而只会存unique device account number（每设备每张银行卡各不相同）

secure enclave与secure element之间的通信，用一个生产过程中共享的sharing pair key，基于secure enclave的uid与secure element的id共同生成，aes。

生产的时候，从secure enclave传给产线的hsm，hsm再注入secure element。

applepay客户端传输payment相关信息到applepay server，server重新以目标的公钥加密并以自身的私钥签名，再传给商户或机构。

# imessage

rsa1024 加密，p-256 签名，与用户手机号/邮箱、设备APN关联。

Apple Identity Service(IDS) 保存对应的公钥。

发送消息时：发送方随机生成88 bit value，再以88 bit为hmac-sha256的key，结合双方公钥+plain text，生成一个40 bit的值。

将两个值拼接为 128 bit 的 aes-ctr key。

40 bit的值可以用来校验plaintext。

以rsa-oaep数字信封封装aes-ctr key。数字信封用 ecdsa-with-sha1 签名。

ios 13之后，改用ecies加密数据，不用rsa。

消息推送还是要经过icloud，公钥交换经过ids

## imessage name and photo sharing

首先随机生成128 bit key。再用hmac-sha256基于该key派生出key1, key2, key3。

key1 用于 aes-ctr 数据加密。

key2 用于计算field name + field iv + file ciphertext 的 mac

用key2计算的多个mac拼接，使用key3计算出一个hmac-sha256的总mac，头128 bit用作record id标记。


# facetime

设备连接：Session Traversal Utilities for NAT(STUN) messages

双方通信：校验双方的identity certificate，实时协商share secret。 share secret用于派生session key，SRTP协议，aes-256-ctr，hmac-sha1。

群组通信：IDS分发群组密钥。session key以aes-siv wrapped，使用ecies，结合临时的ecdh p-256 keys。如果有一个新参与者加入，则新起一个session key。


# find my

连网的设备可以上报位置信息给icloud。

无法连网的设备可以通过蓝牙连接，使用其他设备作为中转，上报位置信息给icloud。

    P-224 密钥对: d, P。公钥P的长度正好能塞到一个蓝牙广播里。
    256bit SK_0，一个counter_i。每隔x秒更新counter_i。
    SK_i = KDF(SK_i-1, "update")

上述密钥信息不会传给apple，但是会通过keychain机制传给该用户账号下的其他设备。

    (u_i, v_i) = KDF(SK_i, "diversify")
    d_i = u_i * d + v_i  
    P_i = u_i * P + v_i * G
    使用ECIES加密传输location。使用P_i的hash值做为关联id。由于counter_i定期轮转，P_i也定期变换，避免追踪。

# Continuity

device paired之后，会生成一个256 bit的key，放在keychain同步。用于aes-gcm通信。

device 之间 wifi tls通信，双向校验iCloud identity certificates，确认user's identity。

## Instant Hotspot

family sharing: 通过ids同步ed25519 public key，并使用该public key认证 ecdh 的临时 curve25519 公钥。

# network security

    ECDHE_ECDSA_AES and ECDHE_RSA_AES in GCM or CBC mode

证书：RFC5280, RFC6962

## bluetooth

pairing： p-256，aes-cmac

bonding：安全存储

Authentication： hmac-sha256 and aes-ctr，或者fips规定的算法

encryption：aes-ccm

message integrity：aes-ccm

secure simple pairing: ecdhe

secure simple pairing, 抵御mitm：passkey entry，或者其他用户参与的方式，避免自动初始化

address randomize

# single sign-on

sso , kerberos

spnego token, heimdal project

    AES-128-CTS-HMAC-SHA1-96
    AES-256-CTS-HMAC-SHA1-96
    DES3-CBC-SHA1
    ARCFOUR-HMAC-MD5

# airdrop

用户登录icloud，rsa2048 identity certificate

airdrop，基于与用户appleid关联的phone number/email address的hash

选择共享时，需要校验identity certificate之后才安全传输

# Developer Kits

## HomeKit

生成 ed25519 keypair。

绑定：使用SRP 3072-bit 协议，在ios系统设备上输入 8 digit code，用hdkf-sha-512派生密钥，CHACHA20-POLY1305 加密，完成ed25519的key exchange。

会话：使用station to station protocol，使用curve25519协商的密钥hkdf-sha-512派生的key

从密钥派生机制可见，HomeKit同步的数据仅在终端才能解密，传输过程中、icloud云端均无法解密。

## apple tv & homekit

首先必须是安全登录态(双因子认证)从icloud云端获取对方的临时ed25519 public key。

通过sts协议协商会话密钥。

homekit device把与该用户关联的ed25519密钥对传输给apple tv。

## homekit secure video

本地home hub与ip camera之间协商出hkdf-sha-512的session keypair，在home hub解密数据。aes-256-gcm。

上传到icloud时，包含了encryption key的metadata，而icloud本身无法解密。

## homekit router

支持ppsk authentication，即，为设备指定专用密码。

## remote access

homekit accessory 初始化时，Apple Authentication Coprocessor 需要响应一个来自ios设备的challenge

然后，将临时生成的公钥、sign过的challenge、Apple Authentication Coprocessor的工厂初始化的x509证书 做为响应返回

通过icloud的服务器，签发一张设备证书。

accessory 与 icloud remote access server联系时，会提供证书、一个pass。pass是从其他icloud服务器获取，仅提供 manufacturer,model,andfirmware信息，多个accessory可能用相同的pass。

http/2，tls1.2，aes-128-gcm，sha-256


## health

health data的完整性：rfc5652 cms digital signature

medical id 仅backup，不sync

## cloudkit

app developer存储 k-v data，structured data，assets

cloudkit service key（与user icloud acccount 关联） -> cloudkit zone key -> cloudkit record key -> file metadata -> file chunklist  -> file chunk

# Secure Device Management

## pairing model

host (computer) <-> device 交换 rsa2048 公钥。随后device向host提供一个256bit的key，用于解密device上的escrow keybag。

注意有效期。

## profile signing & encryption

cms rfc3892

# certification

ISO/IEC 27001  isms Information Security Management System

ISO/IEC 27018  PII personally identifiable information

FIPS 140-X, ISO/IEC 19790, ISO/IEC 24759  cryptographic module validation

Common Criteria Certifications (ISO/IEC 15408)

