---
layout: post
category: tech
title:  "Note: Apple Platform Security"
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

## overview

    ios file encryption => Data Protection (class A/B/C/D)

    mac with intel silicon => volume encryption = FileVault

    mac with apple silicon => class D not support,  class C default = FileVault


secure enclave <-> dedicated AES Engine, support line-speed encryption

sandbox => restrict what data an app can access

DataVault => restrict the calls an app can make

## passcodes and passwords

passcode / password => provide entropy for certain encryption keys

passcode / password  + UID  => kdf

## Data Protection

### implementation

Apple File System (APFS) 

per-file / per-extent (分chunk，每个chunk的key不同)  => 256-bit key
- A14, M1 devices: AES-256-XTS,  NIST SP 800-108, (256-bit tweak, 256-bit cipher key) = kdf(per-file key)
- A13, S5, S6: AES-128-XTS, 256bit per-file key = 128 bit tweak + 128 bit cipher key

A7/S2/S3 Soc: AES-CBC, iv值用sha1(per-file key)加了个密

### Data Protection in Apple device

RFC3394 NIST AES Key Wrapping

class key wrap per-file key, 密文存储于 file metadata

file cloning: 解密，再加密。

file open:
- secure enclave: 用file system volume key 解密 file metadata
- secure enclave: 从file metadata 提取 per-file key 的密文
- secure enclave: 用class key 解密 per-file key
- secure enclave: 用开机时与aes engine协商的临时wrapping key 加密 per-file key，将密文传给aes engine
- aes engine: 用开机时与secure enclave协商的临时Wrapping key 解密 per-file key
- aes engine: 用per-file key解密文件内容

file system volume key: 
- 用于加密该volume下的所有文件的metadata
- os首次安装、或者用户wipe device时，随机生成file system volume key
- secure enclave里的一个long-term KEK 加密 file system volume key
- 用户erase device时，随机生成long-term KEK 
- file system volume 的密文: 用effaceable key再wrap一层，存储于effaceable storage；或者，用secure enclave的 media key-wrapping key 再wrap一层
- 用户wipe device时，可以通过重置file system volume key快速处理

class key:
- 与UID关联
- 部分class还与passcode关联
- 更新file class只需要用新的class key加密per-file key
- 更新passcode只需要用新的passcode + UID 加密 class key 

### Data Protection classes

Class A: Complete Protection
- class key 由 passcode / password  + UID 派生
- 用户lock device 10s 之后，aes engine 自动discard 缓存的decrypted class key
- 用户下一次unlock device之后，再重新解密

Class B: Protected Unless Open
- 适用于设备锁定、或者用户logged out的条件下，仍需要在后台执行文件写入的业务场景。例如邮件附件下载。
- 使用Curve25519
- per-file key 用NIST SP 800-56A 中的One-Pass Diffie-Hellman Agreement 派生的key 保护；临时生成的x25519 public key，与per-file key的密文一起存储。
- 派生算法为NIST SP 800-56A的 Concatenation Key Derivation Function
- 文件close之后，aes engine 自动discard缓存的per-file key
- 文件再次打开，使用class private key 与 临时的public key派生出wrap key，解密per-file key

Class C: Protected Until First Authentication
- 与Class A基本相同
- 用户lock device、或者用户logged out的条件下，aes 仍然缓存 decrypted class key
- 适用于磁盘加密的场景

Class D: No Protection
- class key 只由UID保护，在effaceable storage里存储。
- 解密文件所需的所有内容都在device上。

## Keybags for Data Protection

按照用途，把file Data Protection classes key & keychain Data Protection key 打包到一个文件中。

主要用途场景： user, device, backup, escrow, icloud backup

### user keybag

device normal operation

例如，用户输入passcode，从user keybag载入class A的内容，unwrapped。

keybag的.plist文件，以class D存储。

A9之后的soc，.plist file中包含一个key，标识该keybag由一个secure enclave的locker保护，anti-replay nonce。

secure enclave管理user keybag，接收查询，仅当user keybag里的所有class key都可访问，且被成功unwrapped，认为device unlocked。

keychain  使用 user keybag 里的class keys 保护 user keychain 里的内容。

### device keybag

应对一些用户未logged in的时候，需要的凭据。因此，device keybag 可以不由passcode保护。

system 使用 device keybag 里的class keys 保护 per-file key。

ios 场景，如果是single user，则 device keybag = user keybag，仅一个plist文件不作区分，以passcode保护。

### backup keybag

执行 encrypted backup 时，会新建一些key，放到一个新的keybag里。这些新key，用于reencrypted backed-up data。

注意，nonmigratory keychain items 仍被 UID-derived key 保护，即，仅能在原设备恢复。

由backup password，调用PBKDF2派生的key，保护keybag文件 => 暴力破解

如果用户没有设置encrypted backup，备份文件就不会被加密，keychain items仍被UID-derived key保护。

即，keychain items 仅能在设置了backup password的条件下，导入新设备。

用passcode保护backup中负责保护backup data class key的generated key（首次备份时临时生成）。

### escrow keybag

用于usb连接时itunes备份、或者remote clear passcode，无需用户输入passcode。

escrow keybag 可能需要访问所有class的data。

当passcode-locked device首次连接itunes时，用户需要输入passcode，随即，device生成escrow keybag，包含了该device上各class keys，以一个随机key保护。

escrow keybag 和 随机key 分别存储于 device 和 itunes主机，data 以 class C 保护。

因此，device 重启，必须输入passcode之后，itunes才能备份。

#### OTA

OTA的场景，用户需要输入passcode初始化update任务，同时生成一个one-timee unlock token。该token用于在update之后，unlock user keybag。

one-time unlock token 本身，由另一个key保护。该key由secure enclave的一个counter、keybag的UUID、secure enclave UID联合派生。

attended software updates：one-time unlock token 的有效期为20 min。

unattended software updates (automatic updates、install later): one-time unlock token的有效期为8 hour。如果在该8 hour时间周期内没有升级，则在每次lock的时候删掉token，每次unlock的时候生成新的token。

### icloud backup keybag

与backup keybag类似。

所有keybag里的class key都是非对称的，类似class B。

类似的keybag也用于icloud keychain的备份与重置。

##  protecting keys in alternate boot modes

alternate boot modes: Device Firmware Update (DFU) mode, Recovery mode, Apple Diagnostics, software update

Recovery: Class A/B/C/D protected.

Alternate boots of DFU/Recovery/software update : Class A/B/C data protected.

Secure Enclave AES Engine 基于 UID 派生某个key时，根据key的用途，会设置一个passcode seed bit的标识位。如果该seed bit为true，则表示该key需要结合passcode派生（例如class A/B/C key）；如果为false，则表示该key无需结合passcode派生。

Diagnostics 模式下，禁止访问user data。其实是另一个seed bit标识位，管控是否能够访问media key。media key是访问metadata必须的一个key，因此只须该标识位的控制效果。uid保护media key。

DFU/Recovery 模式下，passcode seed bit被locked，禁止更改。也就避免了无passcode访问对应data。

进入DFU模式后，可以刷入apple-signed的code。

## Protecting user data in the face of attack

Sealed Key Protection (SKP) : key materials不要随意被读取。

apple-designed SoC 支持SKP。

## Sealed Key Protection (SKP)

Data Protection 的 KEK is protected (or sealed) with  "measurements of the software on the system" + UID

FileVault keys = Class C

Sealed Key Protection process:
- Secure Enclave Boot Monitor 收集Secure Enclave OS 的measurement、LLB Image4 manifest的measurement、LocalPolicy的LLB measurement，派生得到的key保护long-term SKP system key
- user password、long-term SKP system key、hardware key 1，派生key保护KEK
- xART key、KEK、hardware key 2，派生key保护volume encryption key
- volume encryption key进一步保护volume data

### SMRK & SMDK

SMRK: crypto-hardware-derived system measurement root key

SMDK: system measurement device key

注意，SMRK保护SMDK。

与DICE类似，由于SMRK基于measurement派生，当Firmware更新时，SMRK也要更新。因此，SMDK要先以旧SMRK解密，再以新SMRK加密，才能确保更新后的下一次启动ok。

## Role of Apple File System (APFS)

macOS:
- Preboot volume
- vm volume: swap
- recovery volume
- system volume
- data volume

ios:
- system volume
- data volume

## keychain data protection

keychain保护: passwords, keys, login tokens

同样，different keychain protection classes

### overview

SQLite database

两个aes-256-gcm keys: table key (metadata), per-row key (secret key)

keychain metadata 以 table key 加密，table key由secure enclave保护、缓存在Application Processor里，支持快速查询。

secret value 以 per-row key加密，per-row key由secure enclave保护。

访问控制：keychain-access-groups, application-identifier, application-group；设置谁可以访问该行keychain内容。

例如同一个开发者账号下的不同app，可以设置共享keychain的对应item。

keychain data protection:
- Accessible When Unlocked ——对应Class A
- Accessible after First Unlock ——对应Class C
- Accesible Always ——对应Class D
- Accessible When Passcode Set This Device Only  ——与Accessible When Unlock相同，但是要求device设置了passcode。这类keychain内容仅在system keybag出现，不同步到icloud keychain，不备份，不在escow keybags里。

例如，app的后台刷新，可以用Accessible after First Unlock 的 keychain items。

如果keychain item指定了"this device only"，则备份时还会加入UID的保护，也就是说，其他device无法恢复。

如果keychain item指定了"nonmigratory"，则只在该device上蹲守。

### keychain data class protection

例如：
- wifi passwords: after first unlock
- itunes backup: when unlocked, nonmigratory
- VPN certificates: always, nonmigratory
- Find My token: always

### keychain access control

只有输入passcode/password，或者通过touchID/FaceID认证后，才能访问keychain。

还可以进一步设置：如果touchID/FaceID发生变化，则禁止访问之前已有的keychain item —— 避免恶意添加指纹/面容信息。

### macOS

macOS user keychain: passwords, digital Identities, encryption keys, secure notes

macOS system keychain: Root CA certificates, network credentials, ...

## FileVault

使用AES-XTS protect volume

macOS 11以后
- system volume : signed system volume (SSV) feature
- data volume : encryption，需要password才能解密、挂载到其他mac无法暴力破解、删掉cryptographic material达成wipe content的效果
- 修改password只需要reencrypted KEK

internal volume encryption when FileVault = on
- password + UID ： 保护KEK
- KEK + xART key + UID : 保护 volume encryption key
- volume encryption key : 保护 volume data

internal volume encryption when FileVault = off
- xART key + UID : 保护 volume encryption key
- volume encryption key : 保护 volume data

### deleting FileVault volumes

删除 volume encryption key

此外，还有一个"media key" wrap "all volume encryption key"

erase media key 可以确保无法访问volume

### Managing FileVault in macOS

secure token:  a wrapped version of a KEK  protected by a user's password

bootstrap token: administrator 的 secure token，可以建普通user

## How Apple protects users' personal data

### protecting app access to user data

third-party apps: data protected in a Data Vault

user signs in to icloud, apps are granted access by default to icloud drive

### protecting access to user's health data

data protected : class B

device lock 10min 之后，无法访问对应data；下一次unlock之后才可以再访问

Management data protected: class C

health data 可以存储于icloud，要求end-to-end encryption, 且two-factor authentication.

health data is stored `only if` the backup is `encrypted`.

### clinical health records

oauth2 client credential 下载 clinical health records

tls 1.3

下载之后，与health data一起安全存储

### health data integrity

optional metadata: digital signature, Cryptographic Message Syntax (CMS) RFC5652

### health data access by third-party apps

申请授权: separate access for reading and writing, separate access for each type of health data

apps can't determine access granted to other apps

### medical ID for user

用户可以设置，是否允许Medical ID在device lock的条件下直接显示

Medical ID 可以与其他health data一起安全存储，使用cloudkit备份

## Digital signning and encryption

### mail

Personal Identification Verification (PIV) tokens : 含 digital signing and encryption certificate

### per-message S/MIME

SCEP: Simple Certificate Enrollment Protocol

### smart cards

smart cards include one or more digital Identities that have a pair of public and private keys and an associated certificate.

使用personal identification number (PIN) unlock smart card

### encrypted disk images

the contents of a disk image are encrypted and decrypted in real time.

# App Security

## app security in ios 

code signature => verify ...  => Apple-issued certificate

动态加载的library同样需要签名校验，与developer certificate里的team id关联。

Apple Developer Enterprise Program (ADEP) with a D-U-N-S number，用于企业自签名。

mobile device management(MDM)

## security of runtime process in ios

sandbox 隔离

entitlement: key-value pair, digitally signed，相当于给app颁发一些权限码。。。

app只能通过系统提供的api执行background process

address space layout randomization (ASLR)

ARM's Execute Never (XN) feature

## support extensions 

注意区分
- the extensions that are embedded within the app ——继承该app获得的授权
- the extensions that are activated by the app ——类似sandbox

custom keyboards 同样sandbox

## app protection and app groups in ios

### data protection

ios software development kit (SDK)

adopting data protection in apps

### joining an app group

apple group IDs (GID)

- shared on-volume container for storage
- shared preferences
- shared keychain items

### verifying accessories 

当MFI accessory要与ios设备通信时，ios device发一个challenge，accessory返回一个signed response。

该signed response可以用apple-provided certificate校验。

apple提供custom integrated circuit (IC), accessory manufacturer直接集成。

audio例子：
- 只有Authenticated accessory能granted full access to the device —— 钱啊。。。
- 没有Authenticated的accessory，只能limit access

AirPlay/CarPlay:
- MFi-SAP(Secure Association Protocol)  通信，aes-128-ctr。
- 会话协商用STS，其中ecdhe用curve25519，签名密钥用rsa-1024。

## app security in macOS

### code signing

apple-issued developer ID ceritifcate

### gatekeeper and runtime protection

only trusted software runs on a user's mac

gatekeeper ensure software signed by : App Store, or registered developer and notarized by apple

MDM can override gatekeeper policy

runtime protection: isolation, sandbox

### protecting against malware in macOS

3个层面：
- prevent launch or excution malware: App Store, or Gatekeeper and Notarization
- block malware from running on custom systems: Gatekeeper, Notarization, XProtect
- Remediate malware that has executed: MRT

Notarization: apple 检测 app，签发notarization ticket，标识着apple认可该app的安全性——该ticket可被撤销。Gatekeepera可以离线校验notarization ticket（数字签名）。

XProtect: apple定期更新malware的签名数据。当app first launched/app has been changed/XProtect signatures are updated —— 扫瞄。。。

### Malware Removal Tool (MRT)

删。。。

## Secure features in the Notes app

### secure notes

user's passphrase => end-to-end encrypted secure notes

基于user's passphrase派生一个16-byte key，派生函数使用PBKDF2 + SHA256。aes-gcm

user必须输入passphrase、或者经过Touch ID/Face ID认证后，才能查看secure note

如果passphrase更新，需要重新加密existing notes的keys

重置passphrase需要校验user's icloud account passphrase

### shared notes

notes aren't end-to-end encrypted with a passphrase can be shared with others.

shared notes 仍然使用 CloudKit encrypted data type:
- assets 使用一个DEK加密
- DEK由KEK加密后，密文存在CKRecord Metadata中

## secure features in the shortcuts app

轻量级。。。

shortcuts can be shared with other users through icloud

# Services Security

## Apple ID

账号安全(user & password)

two-factor authentication  => 6-digit verification code: display on trusted device / sent to a trusted phone number

### account recovery

reset password:
- 在trusted device重置
- 无trusted device，可以输入password + sms verification; 
- previously used passcode + sms verification

如果都不行，启动account recovery

### managed Apple ID

受控的，也就受限。

## icloud

icloud 提供用户数据、第三方app数据的同步服务

每个 icloud file 拆分成chunks，每个chunk 以aes-128加密
- 加密chunk的key、file's metadata，由apple cloud存储
- chunk的密文，由aws/google cloud等平台存储

### icloud drive security

file content keys 被 record keys wrapped，密文存储于icloud drive metadata

record keys 被 用户的icloud drive service key wrapped, 密文存储于用户的icloud account 数据区域中

用户登录icloud，能够访问到metadata；用户提供icloud drive service key，才能读取明文

#### icloud drive backup

icloud backup 仅在device locked + 连接电源 + 有wifi连接 的条件下，自动同步。

icloud backup 的文件加密传输、存储，使用secure tokens认证

icloud backup 支持后台静默备份、增量备份

对于device locked状态下，无法访问的files：per-file keys 用 icloud backup keybag 里的 class keys 加密，这些files是以与device上完全相同的密文状态上传到icloud。

在icloud存储时，以account-based keys加密（如cloudkit所述）

icloud backup keybag 中asymmetric (curve25519) keys 用于那些device locked状态下无法访问的files。

backup set：
- 存储在该user account名下
- 包含user files的备份
- 包含icloud backup keybag
- icloud backup keybag 由一个随机key保护，该随机key与backup set关联存储
- 用户的icloud password仅用于认证，不用于加密；因此，修改密码不会影响icloud备份

keychain:
- keychain database 备份到icloud时，仍由一个UID-tangled key保护。
- 因此，keychain的备份，仅能由原始device载入。

恢复时：
- 从icloud获取 backup files, icloud backup keybag,  保护icloud backup keybag的随机key
- 解密备份文件之后，按照文件所属的class，重新加密存储到本地device。

#### security of icloud backup

backup 付费内容的相关信息（但不是backup付费内容本身），等restore之后，付费内容会再次下载

photos & videos 信息，存入用户的icloud空间，因此无需再以icloud backup的形式备份

messages:
- 如果用户在icloud开启了messages服务，那么icloud backup里存储的imessage/business chat/sms/mms等信息都会从icloud backup中移除
- icloud使用CloudKit中为messages提供的end-to-end encryption container
- icloud backup保留一个访问该messages container的icloud service key
- 如果用户后续丢失所有trusted device，无法恢复keychain，还可以icloud backup保留的messages专用的icloud service key恢复备份
- 如果用户关闭icloud backup，那么container就主动更新icloud service key => 此时，该key仅在icloud keychain内存储，即，icloud backup无法继续访问

用于restore message的key
- 存储于icloud keychain, 以及a backup in cloudkit
- 如果icloud backup is enable, 这个backup in cloudkit的行为会强制自动关联备份；恢复的时候，也强制自动关联恢复。

### cloudkit end-to-end encryption

一些apple service使用cloudkit service key的end-to-end encryption, 各领一个cloudkit container

cloudkit service key 本身随icloud keychain同步

因此，这些cloudkit container data 仅在trusted device + 可访问icloud keychain data 的条件下，可访问。

cloudkit end-to-end encryption data recovery，仅在trusted device上、或者icloud keychain recovery已成功、或者icloud backup同步开启的条件下，能够成功恢复

## passcode and password management

### sign in with apple

用户可以向第三方网站网站隐藏真实的apple email地址，而是使用apple private email relay service，弄一个unique、anonymized email adress去注册

同时 antifraud

### automatic strong passwords

自动为网站生成password，并通过keychain服务存取，autofill

strong password: opt-out

注意以下功能：
- sharing passwords securely to a user's contacts
- providing passwords to a nearby apple TV that's requesting credentials

### app access to saved passwords

app developer 必须在 app 里提供 entitlement，entitlement中列出app关联网站的FQDN

app关联网站必须在server上放置一个文件，列出已被apple approved的app的unique identifier。

即，FQDN的website上放置周知文件
- apple-app-site-association
- .well-known/apple-app-site-association

### comparing users' password against a curated list

apple 把 1.5 billion pw，pw => hash => trunc 到前15 bit，即，分成2^15个bucket

apple为每个bucket中的每个pw计算:
    P_pw = a * H_swu(pw)  # a 是 apple 的secret random key, H_swu 是 hash_to_curve 里的函数

假设用户的密码为 upw
    device计算 upw => hash => trunc 到前15 bit，发给apple，找到对应的bucket
    device -> apple :  P_c = b * H_swu(upw)
    apple -> device : a * P_c = a * b * H_swu(upw)
    apple -> device : upw对应的bucket里的所有P_pw
    device : 对upw对应的bucket里的所有P_pw, 计算 b*P_pw
    device : 检查是否存在一个 b*P_pw 的值与 a*P_c相等，如有，则认为是弱密码

### sending passwords to other users or apple devices

开启icloud，通过airdrop同步website-user-password

iphone/ipad <-> apple TV 通过BLE互联，可能跨账号，autofill password
- 同账号：无感互联
- 跨账号：PIN code

## icloud keychain

端到端加密，不泄漏到apple (?)，易于recover。
- keychain syncing
- keychain recovery

所以，即使icloud被入侵，第三方也难以获得user's password

### secure keychain syncing

keychain首次初始化:
- device生成一个sync identity key pair(curve25519)
- 公钥被放到一个circle
- circle整体内容被签名2次：以sync identity private key签名，以icloud account password派生的p-256私钥签名(派生参数salt, iteration 与circle关联保存)

signed syncing circle 存储于 icloud key-value storage area：
- 只有知道icloud password才能访问
- 只有circle member的sync identity private key才能更新circle

同一用户的另一个device2同步keychain：
- device2生成一个sync identity key pair(curve25519)
- device2生成一个application ticket，请求加入circle
- icloud要求校验icloud password，返回key-generation parameters
- device2结合icloud password + key-generation parameters，派生一个private key => sign the application ticket
- device2把application ticket提交icloud存储

同一用户的其他device首次发现该application ticket:
- 要求用户输入icloud password, 用相同的key-generation parameters派生private key
- 使用派生的private key，确认application ticket的签名无误
- 将device2的公钥加入circle
- 对新circle进行双重签名

所有device之间共享相同的circle，circle中包含其他device的公钥，确保keychain syncing的端到端安全性:
- exchange individual keychain items through icloud key-value storage , or store them in cloudkit
- 如果keychain item撞车，以最新的同步
- 仅接收方device可解密

当一个new device被加入circle，其余device都会与new device同步一次keychain，确保大家的keychain内容一致

部分内容不同步，例如vpn连接配置信息；部分内容会同步，例如wifi密码等。由 kSecAttrSynchronizableattribute 区分。

默认情况下，由third-party app添加的keychain items不同步；除非third-party app developer明确设置 kSecAttrSynchronizableattribute要求同步。

### secure keychain recovery

apple 提供secondary authentication, 以及一个secure escrow service。

使用一个strong passcode对keychain内容加密，escrow service为通过鉴权的用户提供keychain的copy。

- 如果开启two-factor authentication，则使用device passcode恢复escrowed keychain
- 如果未开启two-factor authentication, 则使用icloud security code恢复escrow keychain

device如何备份keychain：
- 使用asymmetric keybag里的keys加密keychain copy，将密文置于icloud key-value storage area。
- asymmetric keybag被icloud security passcode wrapped，并且由云端HSM cluster的public key再搞一个envelope，该envelope即为escrow record。
- 对于HSA2 account: keychain 由intermediate key wrapped，密文存储于cloudkit；intermediate key 只能以escrow record的方式解密。
- 也可以生成random key，然后使用icloud security code wrap random key，无需escrow record。

可以sms message进行recovery的授权校验

#### escrow security for icloud keychain

云端要校验icloud account password、sms确保用户处于安全登录态，然后使用SRP协议校验用户已知icloud security code，注意icloud security code本身并不会传输。

云端hsm解密escrow record，将asymmetric keybag的密文传给device。

device使用icloud security code解密asymmetric keybag。

防暴力破解：10th failed attempt，云端就删掉escrow record。

## applepay

payment交易: user, merchant, card issuer

secure element: 
- java card platform
- 存储Device Account Numbers
- 包含payment network 或者 card issuer 认证的applet
- 每个applet关联存储payment / card issuer 部署的密钥

nfc controller: 
- 在application processor 与 secure element 之间，传递交易消息
- 在secure element 与 point-of-sale终端 之间，传递交易消息
- 当用户(cardholder) 通过passcode/touch ID/face ID鉴权成功，请求某个交易，secure element准备的信息会由nfc controller转发。近场NFC支付信息，会直接转给NFC对端；app/web支付信息，会转给Application Processor再转给apple pay server，前提是secure element <-> apple pay server 端到端。

secure enclave: 
- touchID负责Authentication process，允许一个payment transaction to proceed.
- apple watch: 设备必须解锁，用户双击side button。双击的信号被直接传递到secure element or secure enclave，不往application传

apple pay server: 
- manage Device Account Numbers
- device <-> apple pay server
- apple pay server <-> payment network
- apple pay server <-> card issuer server
- reencrypted payment credential for payment `within apps` or `on the web`

### credit, debit, and prepaid cards

card provision:
- 用户在apple wallet添加card，apple将`card information, user's account information, device information`发给card issuer、或者card issuer授权的service provider。
- card issuer决策是否允许绑卡
- apple pay 与 card issuer / network 的通信分三个步骤： Require Fields、Check Card、Link and Provision。
- user device、apple pay server 不会存储full card number。
- user device 的 secure element 加密存储 unique Device Account Number，相当于标识该user在该device上的一张card
- apple pay server无法获得Device Account Number的内容
- apple watch 绑卡，需要在iphone侧通过apple pay、或者card issuer app操作，apple watch <-> iphone 近场蓝牙通信。

### payment authorization with apple pay

#### shared pairing key

secure enclave与secure element之间的通信
- 使用一个生产过程中共享的shared pair key，由secure enclave基于uid与secure element的id共同生成。
- aes, 用nonce防重放

生产的时候，shared pairing key从secure enclave传给产线的hsm，hsm再注入secure element。

#### authorizing a secure transaction 

业务authorize交易，secure enclave就sign { 交易内容, 交易类型(contactless、还是within apps), Authorization Random (AR) }

AR 是 apple pay 首次 provision 某个credit card时，secure enclave生成的。只要apple pay还是enable，AR就一直存在，受secure enclave的anti-rollback保护。

如果secure element收到一个新的AR值，secure element就把之前所有card标记为deleted。

#### using a payment cryptogram for dynamic security

添加card时，applet会provision一个key，该key与 payment network / card issuer 共享。

同时维护一个transaction counter，递增。

    one-time-code = some_func(key, transaction counter, transaction data, other data [optional])
    other data 例如：
    - NFC交易时，terminal unpredictable number
    - within apps交易时，apple pay server nonce

交易信息发送时： { Device Account Number, one-time-code, transaction data, other data [optional] }

还可以把交易时间、位置传上去

### paying with cards using apple pay

#### paying with cards in stores

注意，如果没有user authentication，任何交易都不能自动发送

user authentication方式包括：touchID/faceID, passcode, double click side button

#### paying with cards within apps

在交易信息发送给developer/merchant之前，apple reencrypt the transaction with a developer-specific key, apple pay保留交易信息的概要，但不与用户/商品关联。

当 device -> apple pay -> merchant 初始化一个transaction时，apple pay会使用一个merchant-specific key对device传过来的信息做reencryption.

#### app payment authorization

app 将 { transaction data, apple pay server nonce } 传给 secure element，

secure element 计算一个payment credential，并使用apple key加密该credential

该credential上传到apple pay server，由apple pay server解密、校验credential之后

apple pay server使用merchant-specific key重新加密payment credential，并打apple pay server的签名之后，再发给merchant

merchant使用自身私钥解密获得payment credential, 并校验apple pay server的签名。

app可以把一些交易信息、或者用户标识信息，做hash，添加到encrypted payment data域里；merchant在接收到payment credential后，可以校验这个hash。

### paying with cards at websites

支持apple pay的website要找apple注册，由apple颁发一个tls client Certificate。

使用该tls client certificate，与apple安全通信。

merchant session data由apple签名。在merchant session被validated之后，所有操作与pays within apps相同。

如果payment-related information从mac -> iphone/apple watch，apple pay使用的是apple identity service(IDS) protocol进行end-to-end的encrypted message handoff 

当用户authorize payment之后，payment token使用website's merchant certificate加密，再从iphone/apple watch -> mac -> website

注意proximity通过BLE advertisements发现近场同账号设备。

### contactless passes in apple pay

apple value added services (Apple VAS) protocol

当device近场靠近某个NFC终端，NFC终端发一个pass request给device

如果device发现调有该pass provider签发的pass，则启动user authentication(touchID/faceID/passcode)

user authentication通过，则使用random ECDH P-256 key + pass provider's public key派生DEK，加密 passdata = { timestamp, pass information }

将数字信封传给NFC终端

pass provider可以配置用户选择pass之后，是否还需要authentication

### rendering cards unusable with apple pay


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

