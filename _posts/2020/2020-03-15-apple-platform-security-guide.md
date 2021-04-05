---
layout: post
category: tech
title:  "Apple Platform Security"
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

# intro

custom silicon

privacy is a fundamental human right

# Hardware Security and Biometrics

## soc security

Page Protection Layer (PPL): execute only signed and trusted code

## secure enclave

独立的 boot rom & aes engine & protected memory

保护biometric data for touch ID and face ID

NAND flash storage/DRAM 划出专门的区域

### memory protection engine

device启动时，secure enclave boot rom随机生成一个临时的memory protection key，给到memory protection engine。

当secure enclave写内容到memory，engine就执行AES-XEX（xor-encrypt-xor）加密，并计算CMAC。

当secure enclave从memory读内容，engine就进行authtag校验，如果不匹配，就通知secure enclave停止。

防重放：nonce参与CMAC计算

A14之后有两个临时的memory protection key，一个用于secure enclave，另一个用于secure neural engine。

对于secure enclave而言，memory protection engine提供的保护是透明的。

### secure enclave boot rom

secure enclave boot rom 是 secure enclave 的信任起点，初始化memory protection engine

Application Processor(AP) 把 sepOS image 传给secure enclave boot rom，把sepOS image的内容拷到secure enclave protected memory

进行签名校验，确保image的合法性

A10之后，把sepOS的hash锁到专门的register里，Public Key Accelerator(PKA)用这个hash搞os-bound keys。

活主要是给secure monitor干

### TRNG

    CTR_DBRG

### Root Cryptographic Keys

UID: unique to each individual device, fused into SoC, 256

sepOS 使用 UID 保护 device-specific secrets，例如：
- 在UID的保护下，internal SSD storage拆到别的机器上，数据仍然无法读取。
- Touch ID data / Face ID data

GID: device group ID, compiled
- 与SoC绑定

UID/GID无法通过Joint Test Action Group(JTAG) 或者其他调试口读取

### secure enclave aes engine

secure enclave aes engine支持hardware key & software key

hardware key通过secure enclave UID/GID派生，外部无法直接读取，但是可以请求加解密。

注意，在Device Firmware Update(DFU)模式下，secure enclave AES engine禁止外部访问UID/GID保护的key——进而保护用户数据。

### aes engine

direct memory access(DMA) 路径下，在application  processor system memory 与 NAND flash storage之间

device启动时，sepOS 生成临时的wrapping key，把这个key传给aes engine。

sepOS用这个wrapping key，加密file-system需要用的file keys，把密文传给aes engine。

aes engine使用wrapping key解密出file keys，可以支持file-system的解密。

核心在于file keys 不会明文传输。

### Public key Accelerator (pka)

RSA/ECC

PKA支持hardware key & software key

hardware key通过secure enclave UID/GID派生，sepOS software也读不到

A10之后，PKA支持OS-bound keys，又称为Sealed Key Protection(SKP):  基于 UID + hash(sepOS) 派生。版本绑定、防止无用户授权的变更，等等。

### secure nonvolatile storage

专门的secure nonvolatile storage只能由secure enclave访问。

有counter，支持anti-replay

每个 counter lockbox: 
- 128-bit salt
- 128-bit passcode verifier
- 8-bit counter
- 8-bit maximum attempt value

secure enclave访问counter lockbox也是要用encrypted and authenticated protocol

passcode entropy: 基于passcode & UID派生

### secure neural engine

使用direct memory access (DMA)访问，使用input-output memory management unit(IOMMU)管控

## touch ID & face ID

### touch ID

touch ID sensor在工厂已经写入一个与secure enclave绑定的shared key。

touch ID sensor 与 secure enclave 的session key基于shared key协商(aes key wrapping)，application processor只转发不解密。

其实就是两边各随机生成一个random key，用shared key wrapping一下。

session 用 aes-ccm

### face ID

face ID 的通信安全与 touch ID类似

另一个关键是识别digital spoofing & physical spoofing

### passcode & password

注意，touch ID & face ID 无法取代 passcode & password

trigger Face/Touch ID的前提是校验过passcode/password。

安全敏感型的操作必须校验passcode/password：软件升级、设备重置、修改配置、解锁、重启、账号登出、多次解锁失败等。

### unlocking a device or user account

如果禁用touch ID/face ID：device/account lock状态， keys for the highest class of Data Protection —— 要discard；等下回使用passcode/password解锁，才能把对应的files/keychain items的key弄回来。

如果启用touch ID/face ID：device/account lock状态， keys for the highest class of Data Protection —— 不discard；使用touch ID/face ID解锁成功，则提供keys for the highest class of Data Protection的unwraping key。

设备重启之后，touch ID/face ID用于解锁device/account的key已丢失，要输入password/passcode才能获取。


### developer

指定touch ID/face ID作为secure-sensitive app的second factor

生成touch ID/face ID保护的公私钥对

## Hardware microphone disconnect

硬件开关

## express card

系统低电量模式，仍可用

# System Security

## secure boot

The Boot ROM code contains the Apple Root CA public key

boot过程以boot rom为起点，链式校验签名，安全启动，最终执行ios kernel。

如果启动失败：
- 无法load LLB的设备： 进入DFU mode
- LLB/iboot的设备：进入recovery mode

此外，
- 基带自己也有secure boot
- secure enclave自己也有secure boot

### boot process for mac with apple silicon

注意，LLB validate LocalPolicy signature，签名是secure enclave计算的。计算签名用到的LocalPolicy nonce是secure enclave boot rom 从secure storage component读的。

nonce的作用是anti-replay

LocalPolicy file设定operating system的三种模式：
- Full Security: personalized signature，与ios类似，只能运行install time时找apple sining server签回来的内容——签名请求中包含exclusive chip identification(ECID)，相当于apple后台对cpu、software的状态进行审核，anti-rollback
- Reduced Security: global signature——只与software内容关联，无法保证latest，无法anti-rollback
- Permissive Security: global signature——也可以不严格要求只执行含合法signature的image。。。

### LocalPolicy signing-key creation and management (macOS)

restore场景下，系统会随机生成Owner Identity Key（OIK, private key) —— 由secure enclave管控，保护等级与Volume encryption key相同。

activation lock初始化场景下，除了OIK，还要User Identity Key (UIK, private key)。

activation lock初始化时，首先登录用户账号，基于UIK生成 User Identity Certificate (ucrt) 的CSR，由apple签发ucrt。

基于UIK生成Owner Identity Certificate (OIC) 的CSR——注意这里公钥是OIK对应的公钥，由Basic Attestation Authority (BAA) server签发OIC。BAA server使用ucrt里的公钥校验CSR。

Image4 可以有 LocalPolicy ， LocalPolicy 内容由 OIK 签名，使用OIC校验。—— 在BAA的trust chain下。

Image4 可以有 RemotePolicy，对于personalized signature，证书内容要包含ECID；对于global signature，证书内容不含ECID。—— 在ucrt的证书里设定例如ECID/ChipID/BoardID等。

Image4 文件是 asn.1 DER format。

多个操作系统复用OIK时，可以通过user password + hardware key派生的KEK，来加解密OIK——用户要输password。

## secure software updates

install only apple-signed code

### personalized update process

    device -> apple authorization server: Cryptographic measurements (例如各Firmware的hash)、nonce (anti-replay)、device's unique exclusive chip identification (ECID)
    apple authorization server: 基于measurements确认升级状态，基于ECID确保personalized
    
    user data volume 在software update过程中不会被mount，避免读取

## operating system integrity

### kernel integrity protection (KIP)

Application Processor's Memory Management Unit (MMU)，内核专用的memory region

### Fast Permission Restrictions

限制某个memory的execute permission

### System Coprocessor Integrity Protection (SCIP)

与KIP类似，在启动时，iboot把Coprocessor的Firmware读到protected memory region

### Pointer Authentication Code

5个128-bitd的key用来算PAC

不同场景下的key，salt不同

抵御内存攻击，例如return-oriented programming (ROP) attack，等等。

### Page Protection Layer

PPL用于prevent user space code from being modified after code signature verification is complete.

就是校验通过之后，还要防止被篡改。

基于KIP & Fast Permission Restrictions，确保PPL的管控。

PPL is only applicable on systems where all excuted code must be signed.

## additional macos system security capabilities

### signed system volume (SSV)

system volume 是单独的一个volume。

SSV: 运行时校验system content的完整性，拒掉所有未经apple签名的data（不论是否code）。

SSV使用APFS (Apple File System) snapshots，升级失败的场景下，可以直接用旧版本恢复，不用重装。

SSV SHA256的hash是针对整个volume的内容的，层次类似merkle tree，称为seal。

每当macOS 安装/升级，seal要重算。

measurements要经过apple签名。

bootloader把measurements和signature发给kernel，kernel要校验seal，才能mount root file system。

### SSV and code signing

SSV 确保读取的内容的完整性

code signing确保内存执行内容过程中的完整性

### SSV and FileVault

system volume 加密没啥意义。

开启SSV，system volume有完整性保护，不用加密。

如果开启了FileVault保护user data，那么SSV必须同时开启。

### system integrity Protection (SIP)

#### mandatory access controls

sandboxing, parental controls, managed preferences, extensions, ...

#### SIP

restrict components to read-only in specific critical file system locations to prevent malicious code from modifying them

### Trust caches

SSV保护下的system binary被执行前，它对应的code directory要算hash。

如果该hash能在SSV trust cache里找到，grant platform privileges，不用再搞更多的签名校验。

Nonplatform binaries执行之前，要校验签名，来自apple的信任链。

### Direct memory access protections for MAC computers

支持DMA。

使用IOMMU管控DMA agent——每个agent只能访问限定的memory region。

### kernel extentions

kexts

## System security for watchOS

### secure pairing with iphone

watch 一次仅能与一个iphone 配对：
- 用out of band (oob) process生成BLE link shared secret。 OOB: encoded secret，扫码。。。
- 如果不能用OOB，就用传统的BLE passkey配对。

配对成功后，使用link shared secret建立蓝牙信道，安全交换公钥(256-bit Ed25519 key pair)。
- 类似Apple Identity Service (IDS)的方式
- 类似IKEv2/IPsec的方式

成功交换公钥后：
- 基于已交换的公钥，做数据层加密
- 如果前面是用IKEv2/IPsec，已协商的密钥存入system keychain，用于后续会话 CHACHA20-POLY1305 (256-bit key)。

15分钟更新一次bluetooth地址

Facetime场景使用Apple Identity Service (IDS) 与iphone 互联、或者直接进行internet连接。

使用hardware-encrypted storage and class-based protection of files and keychain items。

### secure use of Wi-Fi, cellular, icloud, gmail

Wi-Fi凭据安全同步。

iphone帮某个配对的watch找gmail要一个该watch专用的oauth token。iphone通过Apple Identity Service服务把oauth token安全传给watch。watch使用该oauth token访问gmail。

### locking and unlocking apple watch

配对的时候，iphone可以获得某个key。该key可以用于unlock watch的Data Protection key。

iphone不知道watch的passcode。

### apple watch unlock mac

近场BLE环境，可以使用apple watch解锁mac，前置条件：icloud account with two-factor authentication configured

mac生成一个one-time-use unlock secret，传给watch。

基于之前协商的shared key，派生secure key。如果确认watch与mac距离很近，就用secure key加密 unlock secret，解锁mac。

成功解锁后，mac再生成下一个one-time-use unlock secret给到watch。

### approve with apple watch

watch可以协助认证、授权的场景还包括：
- macOS/apple apps authorization
- 第三方app的authentication
- saved safari passwords
- secure notes

## RNG

CPRNGs: Cryptographic pseudorandom number generators

### Entropy sources

- secure enclave hardware TRNG
- Time-based jitter collected during boot
- Entropy collected from hardware interrupts
- seed file used to persist entropy across boots
- intel random instructions, such as RDSEED, RDRAND

### kernel CPRNG

256-bit security level:
- getentropy system call
- /dev/random

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

uid 保护 Media Key

password + uid 保护 class key

class key 保护 volume key

volume key 保护 volume metadata & content

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

