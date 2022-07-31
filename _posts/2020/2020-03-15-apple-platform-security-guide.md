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

[APPLE Platform Security pdf](https://help.apple.com/pdf/security/en_US/apple-platform-security-guide.pdf)

[data security](https://support.apple.com/en-us/HT202303)

# intro

custom silicon

privacy is a fundamental human right

# Hardware Security and Biometrics

## overview

in-line  encryption and  decryption   as files are written or read

## apple soc security

System Security:
- kernel Integrity Protection
- fast permission restrictions
- System Coprocessor Integrity Protection
- Pointer Authentication Codes
- Page Protection Layer (PPL): execute only signed and trusted code.  is not applicable in macOS.

Data Protection:
- Sealed Key Protection (SKP)
- recoveryOS - all Data Protection class Protected
- Alternate boots of DFU, Diagnostics, and Update - Class A, B, C Data Protected

## secure enclave

### overview

dedicated secure subsystem

keep sensitive user data secure even when the application Processor or kernel becomes compromised

独立的 boot rom & trng & pka & secure enclave aes engine & memory protection engine

访问独立的 secure nonvolatile storage

### secure enclave Processor

prevent side-channel attack

lower clock speed, protect it against clock and power attacks

### memory protection engine

dedicated region of DRAM  => 不与ap混用

device启动时，secure enclave boot rom生成一个random ephemeral memory protection key，给到memory protection engine。

当secure enclave写内容到memory，engine就执行AES-XEX（xor-encrypt-xor）加密memory block，并计算CMAC authtag。最终存的是encrypted memory + authtag。

当secure enclave读取memory，engine就进行authtag校验，如果authtag匹配，就解密memory。

replay protection：nonce参与CMAC计算，除了存储authtag，还存储nonce。

nonce的完整性保护： nonces for all memory blocks are protected using an Integrity tree rooted in dedicated SRAM within the secure enclave。写memory时，更新nonce & Integrity tree。读memory时，校验nonce。

A14之后有两个临时的memory protection key，一个用于secure enclave，另一个用于secure neural engine。

对于secure enclave而言，memory protection engine提供的memory encryption/decryption是透明的。

### secure enclave boot rom

iBoot 为 secure enclave 分配 dedicated region of memory。

secure enclave boot rom 是 secure enclave 的信任起点，首先初始化memory protection engine。

Application Processor(AP) 把 sepOS image 传给secure enclave boot rom，把sepOS image的内容拷到secure enclave protected memory。

secure enclave boot rom对sepos image进行校验，校验通过，则sepOS接管运行。

A10之后，secure enclave boot rom把sepOS的hash锁到专用的register里，Public Key Accelerator(PKA)用这个hash派生os-bound keys。

### secure enclave boot monitor

保护the hash of booted sepOS

secure enclave Processor's system Coprocessor integrity Protection (SCIP) configuration，用于确保secure enclave Processor仅执行secure enclave boot rom。

secure monitor确保 secure enclave不能直接修改 SCIP configuration。

secure enclave boot rom 向boot monitor 发一个request，带上loaded sepOS的address & size。
boot monitor重置secure enclave processor，计算loaded sepOS的hash，更新SCIP configuration以便允许执行loaded sepOS，随后载入执行loaded sepOS。
boot过程中，载入其他code的处理也类似。

boot monitor维护一个running hash，当boot process更新时，同步更新running hash。当boot complete, boot monitor把running hash传给PKA，用于OS-bound keys派生。即使secure enclave boot rom出漏洞，该过程仍无法被绕过。


### TRNG

    CTR_DBRG

### Root Cryptographic Keys

UID: unique to each individual device, fused into SoC, 256

sepOS 使用 UID 保护 device-specific secrets，例如：
- 在UID的保护下，internal SSD storage拆到别的机器上，数据仍然无法读取。
- Touch ID data / Face ID data
- mac下仅fully internal storage有类似的保护，u盘/移动硬盘不这样

GID: device group ID
- 与SoC绑定

UID/GID无法通过Joint Test Action Group(JTAG) 或者其他调试口读取

### secure enclave aes engine

防范timing and static power analysis (SPA) and Dynamic Power Analysis (DPA)。

secure enclave aes engine支持hardware key & software key

hardware key通过secure enclave UID/GID派生，外部无法直接读取，但是可以请求加解密。

A10之后，使用lockable seed bits区分派生UID/GID的不同用途的keys。在不同的device's mode下，对data access进行访问控制。例如Device Firmware Update(DFU)模式下，无法访问Passcode-protected data。

### aes engine

aes256

direct memory access(DMA) 路径下，在application  processor system memory 与 NAND flash storage之间

device启动时，sepOS 生成random ephemeral wrapping key，secure enclave把这个key传给aes engine。

sepOS用这个wrapping key，加密application Processor file-system所需要用的file keys，把wrapped key传给aes engine。

aes engine使用wrapping key解密出file keys，可以支持file-system的解密。

核心在于file keys 不会明文传输。

### Public key Accelerator (pka)

RSA/ECC

防范timing and side-channel attacks such as SPA & DPA

PKA支持hardware key & software key

A13 SoC之后，PKA的密码学实现，支持形式化证明

hardware key通过secure enclave UID/GID派生，sepOS software也读不到

A10之后，PKA支持OS-bound keys，又称为Sealed Key Protection(SKP):  基于 UID + secure monitor提供的hash(sepOS) 派生。sepos 版本绑定。

如果出现无用户授权的system变更，则无法访问对应的key material，提升了Passcode-protected data的安全性。

### secure nonvolatile storage

secure nonvolatile storage只能由secure enclave访问

存储user data encryption key

secure enclave <-> secure storage component 配对，双方communication使用encrypted and authenticated protocol。

secure storage component: immutable rom code, hardware RNG, per-device unique cryptographic key, cryptography engines, physical tamper detection

counter lockbox，支持anti-replay，用于Passcode-protected user data的访问控制校验

secure enclave访问counter lockbox也是通过encrypted and authenticated protocol

每个 counter lockbox: 
- 128-bit salt
- 128-bit passcode verifier
- 8-bit counter
- 8-bit maximum attempt value


passcode entropy: 基于passcode & UID派生

初始化：

    secure enclave -> secure storage component : passcode entropy value & maximum attempt value
    secure storage component: 随机生成salt，结合passcode entropy value + secure storage component's unique cryptographic key，派生passcode verifier value + lockbox entropy value
    secure storage component -> secure enclave: lockbox entropy value

后续：
    传输passcode entropy value
    校验passcode verifier value，返回lockbox entropy value，重置counter

访问Passcode-protected data的keys基于counter lockboxes关联的entropy派生。

### secure neural engine

使用direct memory access (DMA)访问，使用sepos kernel control实施input-output memory management unit(IOMMU)管控

### power and clock monitors

limited voltage & frequency envelope

使用monitoring circuits

### secure enclave feature summary

memory protection engine, secure storage, aes engine, pka

## face ID and Touch ID

### face ID and Touch ID security

注意，touch ID & face ID 无法取代 passcode & password

trigger Face/Touch ID的前提是校验过passcode/password。

确保secure enclave与sensor的安全通信

### face ID security

关键是识别digital spoofing & physical spoofing

### touch ID security

touch ID sensor在工厂已经写入一个与secure enclave绑定的shared key。

touch ID sensor 与 secure enclave 的session key基于shared key协商(aes key wrapping)，application processor只转发不解密。

其实就是两边各随机生成一个random key，用shared key wrapping一下。

session 用 aes-ccm

### magic keyboard with touch ID

magic keyboard上的touch ID，同样要与secure enclave安全配对。出厂前，或者出厂后。

在蓝牙信道的基础上。。。

magic keyboard含hardware PKA，用于provide attestation，基于hardware-based keys，实现secure pairing。

secure enclave <-> magic keyboard PKA block 互相交换trusted Apple CA信任链下的public keys，使用hardware-held attestation keys and ECDHE 进行identity attestation

nist p-256

安全配对之后，aes-gcm-256

stored identities

### secure intent to pair

touch ID检验，输入macOS user passcode, 双击touch ID button

### magic keyboard with touch id channel security

magic keyboard's PKA <-> mac's secure enclave : secure pairing

magic keyboard's touch ID sensor <-> magic keyboard's PKA block: secure comm, 还是基于shared key

### face id & touch id & passcode & password

安全敏感型的操作必须校验passcode/password：软件升级、设备重置、修改配置、解锁、重启、账号登出、多次解锁失败等。

### uses for face id and touch id

如果禁用touch ID/face ID：device/account lock状态， keys for the highest class of Data Protection —— 要discard；等下回使用passcode/password解锁，才能把对应的files/keychain items的key弄回来。

如果启用touch ID/face ID：device/account lock状态， keys for the highest class of Data Protection —— 不discard；使用touch ID/face ID解锁成功，则提供keys for the highest class of Data Protection的unwraping key。

设备重启之后，touch ID/face ID用于解锁device/account的key已丢失，要输入password/passcode才能获取。

apple pay: 双击确认+face ID, 或者 touch ID。

apple store: Biometrics校验通过后，调用对应的ecc key为交易签名。

### secure intent and connection to secure enclave

物理连接，double click

### hardware microphone disconnect

硬件开关

避免恶意监听

### express cards with power reserve

低电量，刷nfc交通卡

### developer

指定touch ID/face ID作为secure-sensitive app的second factor

生成touch ID/face ID保护的公私钥对

# System Security

## secure boot

The Boot ROM code contains the Apple Root CA public key

boot过程以boot rom为起点，链式校验签名，安全启动，最终执行ios kernel。

如果启动失败：
- A9之前，boot rom无法load LLB的设备： 进入DFU mode
- LLB/iboot的设备：进入recovery mode

secure enclave 使用 boot progress register (BPR) ，限制不同模式下对 user data 的访问：
- DFU mode: boot rom 管
- recovery mode: iboot 管

此外，
- cellular baseband subsystem 自己也有secure boot
- secure enclave自己也有secure boot，确保sepOS来自apple

### memory safe iboot implementation

通过编译工具优化，防范c的相关缺陷

### mac computer with apple silicon

Boot ROM 
-> LLB 
-> LLB 校验 LocalPolicy signature，签名是secure enclave内的私钥计算的。校验签名用到的LocalPolicy nonce是secure enclave boot rom 从secure storage component读的。 
-> LLB

nonce的作用是anti-replay，相当于secure storage component读出来的nonce，与LocalPolicy里的nonce一致。避免降级到旧版本image、旧LocalPolicy。

LocalPolicy file设定operating system的三种模式：
- Full Security: personalized signature，与ios类似，只能运行install time时找apple sining server签回来的内容——签名请求中包含exclusive chip identification(ECID)，相当于apple后台对cpu、software的状态进行审核，per-device, anti-rollback
- Reduced Security: global signature——只与software内容关联，无法保证latest，无法anti-rollback, install only apple-signed code
- Permissive Security: global signature——也可以不严格要求只执行含合法signature的image。。。

如果想调整system integrity protection (sip) 策略，要进recovery os。

### LocalPolicy 生成

restore场景下，系统会随机生成Owner Identity Key（OIK, private key) —— 由secure enclave管控，保护等级与Volume encryption key相同。

activation lock初始化，生成User Identity Key (UIK, private key)，登录用户账号，基于UIK生成 User Identity Certificate (ucrt) 的CSR，由apple签发ucrt。

基于UIK签发Owner Identity Certificate (OIC) 的CSR——注意这里公钥是OIK对应的公钥，由Basic Attestation Authority (BAA) server签发OIC。BAA server使用ucrt里的公钥校验CSR。

Image4 可以有 LocalPolicy ， LocalPolicy 内容由 OIK 签名，使用OIC校验。—— 在BAA的trust chain下。

Image4 可以有 RemotePolicy，在ucrt中constraints表达：BAA限定ECID/ChipID/BoardID等，确保per-deivce；本地device限定要求本地鉴权后访问OIK、账号远程鉴权的认证凭证(activated lock)，防范downgrade。

Image4 文件是 asn.1 DER format。

OIK在Sealed Key Protection(SKP)机制的保护下，其上层KEK，与 Volume encryption key(VEK) 级别等同。KEK由password + hardware key派生，受password + os度量 + policy 层次派生保护。

注意3个nonce hash： LocalPolicy Nonce Hash (lpnh), RemotePolicy Nonce Hash (rpnh), RecoveryOS Nonce Hash (rohn)

## signed system volume (ssv) security

ssv: read-only system volume, dedicated, isolated volume for system content

SSV内部类似merkle hash tree, ssv root node hash 称为 seal, 在整体file-system metadata tree 中 

system volume 是单独的一个volume。

SSV: 运行时校验system content的完整性，拒掉所有未经apple签名的data（不论是否code）。

SSV使用APFS (Apple File System) snapshots，升级失败的场景下，可以直接用旧版本恢复，不用重装。

每当macOS 安装/升级，seal要重算。

measurements要经过apple签名。

bootloader把measurements和signature发给kernel，kernel要校验seal，才能mount root file system。

SSV 确保读取的内容的完整性

code signing确保内存执行内容过程中的完整性

system volume 加密没啥意义。

开启SSV，system volume有完整性保护，不用加密。

如果开启了FileVault保护user data，那么SSV必须同时开启。

## secure software updates

    device -> apple authorization server: Cryptographic measurements (例如各Firmware的hash)、nonce (anti-replay)、device's unique exclusive chip identification (ECID)
    apple authorization server: 基于measurements确认升级状态，基于ECID确保personalized
    
    user data volume 在software update过程中不会被mount，避免读取

## operating system integrity

kernel integrity protection (KIP), Application Processor's Memory Management Unit (MMU)，限定内核专用的memory region

Fast Permission Restrictions, 限制某个memory的execute permission

System Coprocessor Integrity Protection (SCIP), 与KIP类似，在启动时，iboot把Coprocessor的Firmware读到protected memory region

Pointer Authentication Code (PAC): 5个128-bitd的key用来算PAC, signature值放在64-bit pointer的头部bits内; 不同场景下的key，salt不同; 抵御内存攻击，例如return-oriented programming (ROP) attack，等等。

Page Protection Layer(PPL): PPL用于prevent user space code from being modified after code signature verification is complete.  
就是校验通过之后，还要防止被篡改。 
基于KIP & Fast Permission Restrictions，确保PPL的管控。 
PPL is only applicable on systems where all excuted code must be signed.

### additional macos system security capabilities

system Integrity protection (sip): 限制kernel写critical system files, mandatory access control

sandboxing, parental controls, managed preferences, extensions, ...

restrict components to read-only in specific critical file system locations to prevent malicious code from modifying them

### Trust caches

SSV保护下的system binary被执行前，它对应的code directory要算hash。

如果该hash能在SSV trust cache里找到，grant platform privileges，不用再搞更多的签名校验。

Nonplatform binaries执行之前，要校验签名，来自apple的信任链。

### Direct memory access protections for MAC computers

支持DMA。

使用IOMMU管控DMA agent——每个agent只能访问限定的memory region。

### kernel extentions ( kexts )

kexts 合入 Auxiliary Kernel Collection (AuxKC)，在boot process时载入

AuxKC 的 measurement 在LocalPolicy中

不推荐使用kexts

如果SIP enabled，AuxKC有安全校验；反之，kext signature没有强制校验

## System security for watchOS

### wrist detection

检测到卸下, 就自动lock

### activation lock

unpair/erase/reactivate时，要求输入apple id & password 

### secure pairing with iphone

watch 一次仅能与一个iphone 配对：
- 默认使用animated pattern，使用扫瞄的方式，out of band (oob) process。生成BLE link shared secret。
- 如果不能用OOB，就用传统的BLE passkey配对。

配对成功后，使用link shared secret建立蓝牙信道，安全交换公钥(256-bit Ed25519 key pair)。
- 类似Apple Identity Service (IDS)的方式
- 类似IKEv2/IPsec的方式。使用ble session key / IDS key 负责 initial key exchange process 的认证。

成功交换公钥后：
- 基于已交换的公钥，做数据层加密
- 如果前面是用IKEv2/IPsec，已协商的密钥存入system keychain，用于后续会话 CHACHA20-POLY1305 (256-bit key), AES-256-GCM。

15分钟更新一次ble地址

streaming data 场景(例如Facetime)，使用Apple Identity Service (IDS) 与iphone 互联、或者直接进行internet连接。

使用hardware-encrypted storage and class-based protection of files and keychain items。

### auto unlock and apple watch

场景：iphone解锁watch；watch解锁mac；

设备间：Station-to-station (STS) protocol，secure enclave保护long-term key。

#### unlocking

target device （被解锁方）生成一个32 bytes Cryptographic unlock secret，发给 initiator device （解锁方）， 用于下一次的解锁。

该secret负责wrap target deivce的passcode-derived key(PDK)。

该secret在STS tunnel上传输。

成功解锁后，重新生成新的unlock secret，重新加密PDK，重新传输。

#### apple watch auto unlock security policies

为了用户体验，不在watch输passcode：

random unlock secret 用于生成一个long-term escrow record，存于apple watch keybag。

与此同时，escrow record secret存储于iphone keychain，用于在apple watch重启后初始化一个新session。

该secret可以用于获取watch的Data Protection key。

iphone不知道watch的passcode。

#### iphone auto unlock security policies

watch解锁iphone要满足多个限定条件，例如：iphone最近几小时被unlock过；用户的nose and mouth被sensor检测到；距离较近；。。。

#### apple watch unlock mac

近场BLE环境，可以使用apple watch解锁mac，前置条件：icloud account with two-factor authentication configured

watch可以协助认证、授权的场景还包括：
- macOS/apple apps authorization
- 第三方app的authentication
- saved safari passwords
- secure notes

#### secure use of Wi-Fi, cellular, icloud, gmail

Wi-Fi凭据安全同步。

iphone帮某个配对的watch找gmail要一个该watch专用的oauth token。iphone通过Apple Identity Service(IDS)服务把oauth token安全传给watch。watch使用该oauth token访问gmail。

### RNG

CPRNGs: Cryptographic pseudorandom number generators

#### Entropy sources

- secure enclave hardware TRNG
- Time-based jitter collected during boot
- Entropy collected from hardware interrupts
- seed file used to persist entropy across boots
- intel random instructions, such as RDSEED, RDRAND

#### kernel CPRNG

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

Erase Data option is tunned on  => 10 consecutive incorrect attempts to enter the psscode  => remove

fail attempts , delay time interval rise

## Data Protection

### implementation

Apple File System (APFS) 

per-file / per-extent (分chunk，每个chunk的key不同)  => 256-bit key
- A14, M1 devices: AES-256-XTS,  NIST SP 800-108, (256-bit tweak, 256-bit cipher key) = kdf(per-file key)
- A13, S5, S6: AES-128-XTS, 256bit per-file key = 128 bit tweak + 128 bit cipher key

A7/S2/S3 Soc: AES-CBC, iv值用sha1(per-file key)加了个密

mac with apple silicon: defaults to class C, but use volume key ( not  per-extent/per-file key )，方便切换FileVault for user data

### Data Protection in Apple device

RFC3394 NIST AES Key Wrapping

使用 class key wrap per-file key, 密文存储于 file metadata

file cloning: 解密，再加密。

file open:
- secure enclave: 用file system volume key 解密 file metadata
- secure enclave: 从file metadata 提取 per-file key 的密文
- secure enclave: 用class key 解密 per-file key
- secure enclave: 用开机时与aes engine协商的临时wrapping key 加密 per-file key，将密文传给aes engine
- aes engine: 用开机时与secure enclave协商的临时Wrapping key 解密 per-file key
- aes engine: 用per-file key解密文件内容

file system volume key: 
- 用于加密该data volume file system下的所有文件的metadata
- os首次安装、或者用户wipe device时，随机生成file system volume key
- secure enclave里的一个long-term KEK 加密 file system volume key
- 用户erase device时，随机生成long-term KEK 
- 发给aes engine使用时，仍是使用开机临时生成的wrapping key加解密file system volume key
- file system volume key的密文存储: 用effaceable storage里存的effaceable key再wrap一层；或者，用secure enclave的 media key-wrapping key 再wrap一层。用于支持快速erase all content and settings。

class key:
- 受UID派生的key保护
- 部分class还与passcode关联
- 更新file class只需要用新的class key加密per-file key
- 更新passcode只需要用新的passcode + UID 派生key，重新wrap class key 

### Data Protection classes

Class A: Complete Protection
- 由 passcode / password  + UID 派生的key保护该class key
- 用户lock device 10s 之后，memory自动discard 缓存的decrypted class key相关信息
- 用户下一次unlock device之后，再重新解密

Class B: Protected Unless Open
- 适用于设备锁定、或者用户logged out的条件下，仍需要在后台执行文件写入的业务场景。例如邮件附件下载。
- 使用ecdh over Curve25519
- per-file key 用NIST SP 800-56A 中的One-Pass Diffie-Hellman Agreement 派生的key 保护；临时生成的x25519 public key，与per-file key的密文一起存储。
- 派生算法为NIST SP 800-56A的 Concatenation Key Derivation Function
- 文件close之后，aes engine 自动discard缓存的per-file key
- 文件再次打开，使用class private key 与 临时的public key派生出wrap key，解密per-file key

Class C: Protected Until First Authentication
- 与Class A基本相同
- 用户lock device、或者用户logged out的条件下，memory 仍然缓存 decrypted class key相关信息
- 适用于磁盘加密的场景

Class D: No Protection
- class key 只由UID派生的key保护，wrapped key在effaceable storage里存储。
- macos不支持

## Keybags for Data Protection

按照用途，把file & keychain 的 Data Protection key 打包到keybags中

keybags主要用途场景： user, device, backup, escrow, icloud backup

keybag本身是一个class D的binary property list(.plist)结构

### user keybag

normal operation of device 

例如，用户输入passcode，从user keybag载入wrapped file class A key，unwrapped。

keybag的.plist文件，以class D级别保护

A9之前的SoC，.plist file由effaceable storage里的key加密，该key由user passcode派生的key保护。

A9及之后的soc，.plist file中包含一个key，标识该keybag在一个locker中存储，该locker由secure enclave保护，anti-replay nonce。

secure enclave管理user keybag，接收查询，仅当user keybag里的所有class key都可访问，且被成功unwrapped，认为device unlocked。

keychain 使用 user keybag 里的class keys,  保护 user keychain items。

### device keybag

device keybag 不由passcode保护。

应对一些用户未logged in的时候，需要的凭据。

system 使用 device keybag 里的class keys 保护 per-file key。

ios/ipad os 场景，如果是single user，则 device keybag = user keybag，不作区分，以passcode保护。

### backup keybag

finder/itunes 执行 encrypted backup 时，会新建一些key，放到一个新的keybag里。这些新key，用于reencrypted backed-up data。

注意，nonmigratory keychain items 仍被 UID-derived key 保护，即，仅能在原设备恢复。

keybag文件，由backup password调用PBKDF2派生的key，保护=> 暴力破解风险

如果用户没有设置encrypted backup，备份文件就不会被加密，但keychain items仍被UID-derived key保护。

注意，keychain items 仅能在设置了backup password的条件下，导入新设备。

用passcode保护backup中负责保护backup data class key的generated key（首次备份时临时生成）。

### escrow keybag

用于usb连接时itunes备份、或者MDM场景下remote clear passcode，无需用户输入passcode。

escrow keybag 支持访问所有class的data。

当passcode-locked device首次连接itunes时，用户需要输入passcode，随即，device生成escrow keybag，包含了该device上各class keys，以一个随机key保护。

escrow keybag 和 随机key 分别存储于 device 和 host/server，data 以 class C 保护。

因此，device 重启，必须输入passcode之后，itunes才能备份。

#### OTA

OTA的场景，用户需要输入passcode初始化update任务，同时生成一个one-timee unlock token。该token用于在update之后，unlock user keybag。

one-time unlock token 本身，由另一个key保护。该key由secure enclave的一个counter、keybag的UUID、secure enclave UID联合派生。

attended software updates：one-time unlock token 的有效期为20 min。

unattended software updates (automatic updates、install later): one-time unlock token的有效期为8 hour。如果在该8 hour时间周期内没有升级，则在每次lock的时候删掉token，每次unlock的时候生成新的token。

token由secure enclave locker保护

### icloud backup keybag

与backup keybag类似。

该keybag里的所有class key都是非对称的，类似class B。

类似的asymmetric keybag机制，也用于icloud keychain的备份与重置。

##  protecting keys in alternate boot modes

Data Protection: successful Authentication -> access to user data

alternate boot modes: Device Firmware Update (DFU) mode, Recovery mode, Apple Diagnostics, software update

Recovery: Class A/B/C/D protected.

Alternate boots of DFU/Recovery/software update : Class A/B/C data protected.

Secure Enclave AES Engine 与 lockable software seed bits关联。基于 UID 派生某个key时，seed bits在KDF参数内。
- A10, S3: 如果该seed bit为true，则表示该key需要结合passcode派生（例如class A/B/C key）；如果为false，则表示该key无需结合passcode派生。
- ios13, A10之后：Diagnostics Mode下，由于添加additional seed bits限制了访问media key的权限，无法访问user data。因为没有media key访问metadata。
- A12: DFU/Recovery mode, secure enclave boot rom lock passcode seed bit。防止通过输入user's passcode访问。

Diagnostics 模式下，禁止访问user data。其实是另一个seed bit标识位，管控是否能够访问media key。media key是访问metadata必须的一个key，因此只须该标识位的控制效果。uid保护media key。

DFU/Recovery 模式下，passcode seed bit被locked，禁止更改。也就避免了无passcode访问对应data。

进入DFU模式后，可以刷入apple-signed的code。

## Protecting user data in the face of attack

Sealed Key Protection (SKP) : key materials不要随意被读取。

apple-designed SoC 支持SKP。

### Sealed Key Protection (SKP)

Data Protection 的 KEK is protected (or sealed) with  "measurements of the software on the system" + UID

Mac上允许关闭secure boot / SIP，默认 FileVault keys = Class C

Sealed Key Protection process:
- Secure Enclave Boot Monitor 收集Secure Enclave OS 的measurement、LLB Image4 manifest的measurement、LocalPolicy的LLB measurement，派生得到的key保护long-term SKP system key
- user password、long-term SKP system key、hardware key 1(UID)，派生key保护KEK
- xART key、KEK、hardware key 2(UID)，派生key保护volume encryption key
- volume encryption key进一步保护volume data

### SMRK & SMDK

SMRK: crypto-hardware-derived system measurement root key

SMDK: system measurement device key

注意，SMRK保护SMDK。

与DICE类似，由于SMRK基于measurement派生，当Firmware更新时，SMRK也要更新。因此，SMDK要先以旧SMRK解密，再以新SMRK加密，才能确保更新后的下一次启动ok。

### Activating data connections securely

30 days

## Role of Apple File System (APFS)

macOS:
- Preboot volume: unencrypted
- vm volume: unencrypted, store encrypted swap file
- recovery volume: unencrypted
- system volume
- data volume

ios:
- system volume
- data volume

## keychain data protection

keychain保护: passwords, short sensitive data (keys, login tokens)

different keychain protection classes

### overview

SQLite database

两个aes-256-gcm keys: table key (metadata), per-row key (secret key)

keychain metadata 以 table key 加密，table key由secure enclave保护、缓存在Application Processor里，支持快速查询。

secret value 以 per-row key加密，per-row key由secure enclave保护，原子化操作调用。

securityd daemon进行访问控制：keychain-access-groups, application-identifier, application-group；设置什么条件可以访问该行keychain内容。

例如同一个开发者账号下的不同app，可以设置共享keychain items。

keychain data protection:
- when unlocked: Accessible When Unlocked ——对应Class A
- after first unlock: Accessible after First Unlock ——对应Class C
- always: Accesible Always ——对应Class D
- passcode enabled: Accessible When Passcode Set This Device Only  ——与Accessible When Unlock相同，但是要求device设置了passcode。这类keychain内容仅在system keybag出现，不同步到icloud keychain，不备份，不在escow keybags里。

例如，app的后台刷新，可以用Accessible after First Unlock 的 keychain items。

如果keychain item指定了"this device only"，则备份时还会加入UID的保护，也就是说，其他device无法恢复。

如果keychain item指定了"nonmigratory"，则只在该device上有效。

### keychain data class protection

例如：
- wifi passwords: after first unlock
- itunes backup: when unlocked, nonmigratory
- VPN certificates: always, nonmigratory
- Find My token: always

### keychain access control

只有输入passcode/password，或者通过touchID/FaceID认证后，才能访问keychain。

还可以进一步设置：如果touchID/FaceID发生变化，则禁止访问之前已有的keychain item —— 避免恶意添加指纹/面容信息。

### keychain architecture in macOS

macOS user keychain: passwords, digital Identities, encryption keys, secure notes

macOS system-level keychain: Authentication assets (not user specific), Root CA certificates, network credentials, ...

## FileVault

使用AES-XTS protect volume

Data Protection Class C with a volume key

有 Apple T2 Security Chip 的，secure enclave 保护

### internal storage with FileVault turn on

macOS 11以后
- system volume : signed system volume (SSV) feature
- data volume : encryption，需要password才能解密、挂载到其他mac无法暴力破解、删掉cryptographic material达成wipe content的效果
- 修改password只需要reencrypted KEK，无需全盘重加密

internal volume encryption when FileVault = on
- password + UID ： 保护KEK(class key)
- KEK + xART key + UID : 保护 volume encryption key
- volume encryption key : 保护 volume and metadata contents

internal volume encryption when FileVault = off
- xART key + UID : 保护 volume encryption key
- volume encryption key : 保护 volume data

### deleting FileVault volumes

删除 volume时，对应的volume encryption key从secure enclave删除 

"media key" wrap "all volume encryption key"

erase media key 可以确保无法访问volume，支持MDM远程删除

### removable storage device

与无T2 chip的 intel-based mac 做法相同

### Managing FileVault in macOS

secure token:  a wrapped version of a KEK  protected by a user's password

personal recovery key (PRK), institutional recovery key (IRK) : mobile device management(MDM) 也能用

bootstrap token: create administrator account， grant a secure token，支持MDM

## How Apple protects users' personal data

### protecting app access to user data

third-party apps data protected in a Data Vault

user signs in to icloud, apps are granted access by default to icloud drive

### protecting access to user's health data

HealthKit 用于 iphone - watch/其他健康设备 之间数据同步

data protected : class B

device lock 10min 之后，无法访问对应 health data；下一次unlock之后才可以再访问

#### Collecting and storing health and fitness data

Management data (access Permission, ...) protected: class C

锁定状态下，class B，将health record写入tempory journal files；解锁后合并到primary health database，再删除tempory journal files

health data 可以存储于icloud，要求end-to-end encryption, 且two-factor authentication.

health data is stored `only if` the backup is `encrypted`.

#### clinical health records

oauth2 client credential 下载 clinical health records

tls 1.3

下载之后，与health data一起安全存储

#### health data integrity

metadata: 至少要标识是哪个app存储的数据

optional metadata: digital signature, Cryptographic Message Syntax (CMS) RFC5652 digital signature，保护record的完整性

#### health data access by third-party apps

申请授权: separate access for reading and writing, separate access for each type of health data

apps can't determine access granted to other apps

#### medical ID for user

用户可以设置mediacal id，Medical ID在device lock的条件下直接显示，用于急救

Medical ID 可以与其他health data一起安全存储，使用cloudkit同步

#### health sharing

end-to-end icloud encryption

## Digital signning and encryption

### access control list

第三方app的凭据不能被其他开发者的app读取

### mail

RFC5322

Personal Identification Verification (PIV) tokens : 含 digital signing and encryption certificate

### per-message S/MIME

SCEP: Simple Certificate Enrollment Protocol

### smart cards

smart cards include one or more digital Identities that have a pair of public and private keys and an associated certificate.

使用personal identification number (PIN) unlock smart card

支持 kerberos 认证 

### encrypted disk images

the contents of a disk image are encrypted and decrypted in real time.

AES-128/256

# App Security

## app security overview

sandboxed

## app security in ios 

code signature => verify ...  => Apple-issued certificate

dynamic library同样需要签名校验，与developer certificate里的team id关联。

app source verified之后，进行secure measures，防范恶意code。

### in-house apps

Enterprise : Apple Developer Enterprise Program (ADEP) with a D-U-N-S number，用于企业自签名。

通过 mobile device management(MDM) 安装的，implicitly trusted

## security of runtime process in ios

sandbox 隔离

declared entitlements: key-value pair配置是developer digitally signed，相当于给app配置特权。。。并且，app只能通过system-provided api执行background process。

address space layout randomization: (ASLR)

ARM's Execute Never (XN) feature

## support extensions 

注意区分
- the extensions that are embedded within the app ——继承该app获得的授权
- the extensions that are activated by the app ——类似sandbox

custom keyboards 同样sandbox

## app protection and app groups in ios

### adopting data protection in apps

ios software development kit (SDK)

adopting data protection in apps

### joining an app group

apple group IDs (GIDs)
- shared on-volume container for storage
- shared preferences
- shared keychain items

### verifying accessories 

当MFI accessory要与ios设备通信时，ipod accessories protocol (iAP)

ios deivce -> accessory: req

accessory -> ios device: apple-provided accessory certificate

ios device: 校验apple-provided accessory certificate

ios device -> accessory: challenge

accessory -> ios device: 返回apple-provided certificate的signed response

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

### gatekeeper 

only trusted software runs on a user's mac

gatekeeper ensure software signed by : App Store, or registered developer and notarized by apple

MDM can override gatekeeper policy

### runtime protection

runtime protection: isolation, sandbox,  system-provided api

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

user-provided passphrase => end-to-end encrypted secure notes, aes-gcm。

基于user's passphrase派生一个16-byte key，派生函数使用PBKDF2 + SHA256。

仅支持针对指定类型的attachments进行encrypt，其他类型的attachments不加密。CloudKit 存储 encrypted note, attachments, tag, iv。

user必须输入passphrase、或者经过Touch ID/Face ID认证后，才能查看secure note。

如果passphrase更新，需要重新wrap existing notes encryption keys

重置passphrase需要校验user's icloud account passphrase

### shared notes

notes aren't end-to-end encrypted with a passphrase can be shared with others.

shared notes 仍然使用 CloudKit encrypted data type:
- assets 使用一个DEK加密
- DEK由KEK加密后，密文存在CKRecord Metadata中

## secure features in the shortcuts app

shortcuts can be shared with other users through icloud

本地加密存储，可通过icloud同步。

# Services Security

## Apple ID and managed apple ID

账号安全(user & password)

two-factor authentication  => 6-digit verification code: display on trusted device / sent to a trusted phone number,  confirm trust new device

### password reset and account recovery

reset password:
- trusted device：重置
- 无trusted device：输入password + sms verification; 
- 快速恢复：previously used passcode + sms verification

如果都不行，启动account recovery过程。mark。

### managed Apple ID security

按role-based给permission。

受控的，服务也就受限，例如apple pay/icloud keychain/HomeKit/FindMy不能用。

MDM场景下，inspector可以查看/修改账号下的内容。

## icloud

icloud 提供用户数据、第三方app数据的同步服务

每个 icloud file 拆分成chunks，每个chunk 以aes-128加密
- 加密chunk的key、file's metadata，由apple cloud存储
- chunk的密文，由aws/google cloud等平台存储

### icloud drive security

file content keys 被 record keys wrapped，密文存储于icloud drive metadata

record keys 被 用户的icloud drive service key wrapped, 密文存储于用户的icloud account 数据区域中

用户登录icloud，能够访问到metadata；用户提供icloud drive service key，才能解密record keys，进而解密content keys，最终读取明文

### icloud backup

icloud backup 仅在device locked + 连接电源 + 有wifi连接 的条件下，自动同步。

icloud backup 的文件加密传输、存储, 使用secure tokens认证

icloud backup 支持后台静默备份、增量备份

对于device locked状态下，受data protection class影响，无法访问的files：per-file keys 用 icloud backup keybag 里的 class keys 加密，这些files是以与device上完全相同的密文状态上传到icloud。

在icloud存储时，以account-based keys加密（如cloudkit所述）

icloud backup keybag 中asymmetric (curve25519) keys ，用于那些device locked状态下无法访问的files。

backup set：
- 存储在该user icloud account名下
- 包含user files的备份
- 包含icloud backup keybag
- icloud backup keybag 由一个随机key保护，该随机key与backup set关联存储
- 用户的icloud password仅用于认证，不用于加密；因此，修改密码不会影响icloud备份

keychain:
- keychain database 备份到icloud时，仍由一个UID-tangled key保护。
- 因此，keychain的备份，仅能由原始device载入；apple无法读取。

restore时：
- 从icloud获取 backup files, icloud backup keybag,  与icloud accout关联的、负责保护icloud backup keybag的随机key
- 解密keybag，恢复per-file keys，解密backup set中的files
- 解密备份文件之后，按照文件所属的class，重新加密，存储到本地device。

### security of icloud backup

backup 付费内容的相关信息（但不是backup付费内容本身），等restore之后，付费内容会再次下载

photos & videos 信息，存入用户的icloud空间，因此无需再以icloud backup的形式备份

messages:
- 如果用户在icloud开启了messages服务，那么icloud backup里存储的imessage/business chat/sms/mms等信息都会从icloud backup中移除，而是使用CloudKit中为messages提供的end-to-end encryption container
- icloud backup保留一个访问该messages container的icloud service key, 该key在icloud keychain内同步
- 如果用户关闭icloud backup，那么该message container key随之更新 => 此时，icloud backup无法继续访问
- 如果用户后续丢失所有trusted device，无法恢复keychain，还可以icloud backup保留的messages专用的icloud service key恢复备份

restore message
- icloud keychain, and  a backup in cloudkit
- 如果icloud backup is enable, 这个backup in cloudkit的行为会强制自动关联备份；恢复的时候，也强制自动关联恢复。

### cloudkit end-to-end encryption

一些apple service使用cloudkit service key的end-to-end encryption, 各领一个cloudkit container

cloudkit service key 本身随icloud keychain同步

因此，这些cloudkit container data 仅在trusted device + 可访问icloud keychain data 的条件下，可访问。

cloudkit end-to-end encryption data recovery，仅在trusted device上、或者icloud keychain recovery已成功、或者icloud backup同步开启的条件下，能够成功恢复

### icloud private relay

代理服务，包揽了dns request。mark。

### account recovery contact security

可以添加5个好友(recovery contact)协助恢复icloud account and data

使用一个random kek保护用于访问user's data的key，该random kek被split分发给recovery contact and apple

与recovery contact建议一个end-to-end encrypted cloudkit container，同步splited kek portion。
并且，给到apple & recovery contact相同的authorization secret，用于后续recovery。
recovery contact收到的信息，存入keychain。

好友协助恢复的邀请，通过IDS服务发送。

恢复时：
- Recovery Contact device提供一个spake2+ 的 recovery code，user在自身device输入该recovery code，用于向Recovery contact device证明身份。
- Recovery Contact device校验通过后，Recovery contact device将此前获得的splited kek portion，authorization secret给到user device。
- user device使用authorization secret，向apple server请求splited kek portion。注意，apple server基于authorization secret，也授权account password reset。
- user device合并kek信息，解密并恢复icloud data

恢复条件:
- 避免在无用户确认的情况下，由recovery contact触发recovery：进行user account活跃检查。
- 如果user是活跃的，那么还要输入recent device passcode, or icloud security code。

### legacy contact security

允许死后被人读取数据。。。

与recovery contact机制类似，但没有kek拆分的处理。而是给到一个access key。

Authorization secret的处理不变。

## passcode and password management

### sign in with apple security

用户可以向第三方网站网站隐藏真实的apple email地址，而是使用apple private email relay service，弄一个unique、anonymized email adress去注册

同时 antifraud

### automatic strong passwords

自动为网站生成strong password，并通过keychain服务存取，autofill

strong password: opt-out

### password autofill security

注意以下功能：
- sharing passwords securely to a user's contacts
- providing passwords to a nearby apple TV that's requesting credentials

### app access to saved passwords

app developer 必须在 app 里设置 entitlement，entitlement中列出app关联网站的FQDN

app关联网站必须在web server上放置一个周知文件，列出已被apple approved的app的unique identifier。
- apple-app-site-association
- .well-known/apple-app-site-association

### password security recommendation

多个网站用相同password

弱密码

被提示为leaked的密码

### password monitoring

private set intersection

apple 把 1.5 billion pw，pw => hash => trunc 到前15 bit，即，分成2^15个bucket

apple为每个bucket中的每个pw计算:
    P_pw = a * H_swu(pw)  # a 是 apple 的secret random key, H_swu 是 hash_to_curve 里的函数

假设用户的密码为 upw
    device计算 upw => hash => trunc 到前15 bit，发给apple，找到对应的bucket
    device -> apple :  P_c = b * H_swu(upw)
    apple -> device : a * P_c = a * b * H_swu(upw), 同时返回upw对应的bucket里的所有P_pw
    device : 对upw对应的bucket里的所有P_pw, 计算 b*P_pw
    device : 检查是否存在一个 b*P_pw 的值与 a*P_c相等，如有，则认为是leaked

### sending passwords to other users or apple devices

开启icloud，通过airdrop同步website-user-password

iphone/ipad <-> apple TV 通过BLE互联，可能跨账号，autofill password
- 同账号：无感互联
- 跨账号：输入PIN code

## icloud keychain

端到端加密，不泄漏到apple (?)，易于recover。
- keychain syncing
- keychain recovery

所以，即使icloud被入侵，第三方也难以获得user's password

### secure keychain syncing

icloud keychain首次初始化:
- device生成一个sync identity key pair(curve25519), keychain中存储
- 公钥被放到一个circle中，circle整体内容被签名2次：以sync identity private key签名，以icloud account password派生的p-256私钥签名(派生参数salt, iteration 与circle关联保存)

two-factor Authentication account, cloudkit 里也存了一个circle，机制类似。device identity含2个p-384的key pair，key chain中存储；每个device维护它信任的identity list，并以它的auth identity key签名。

### icloud storage of the syncing circle

signed syncing circle 存储于 icloud key-value storage area：
- 只有知道icloud password才能访问
- 只有circle member的sync identity private key才能更新circle

two-factor authorization account, syncing list在cloudkit存储。

### add other devices

两种情况：与existing icloud keychain device进行pairing安全同步，或者使用icloud keychain recovery

pairing, 同一用户的另一个applicant device新加入：
- applicant device生成sync identity key pairs, 用于syncing circle & syncing lists (two-factor authentication accounts)
- applicant device把sync identity public keys给到sponsor device
- sponsor device使用自己的sync identity private key 和 icloud password 派生的private key，添加applicant public key到circle。
- applicant device也会使用自己的sync identity private key 和 icloud password 派生的private key，对circle签名。
- two-factor authentication accounts, sponsor device同时使用自身sync identity key为applicant device提供设备证明，确保对方可信；并添加applicant device到其syncing lists

所有device之间共享相同的circle，circle中包含其他device的公钥，确保keychain syncing的端到端安全性:
- exchange individual keychain items through icloud key-value storage , or store them in cloudkit
- 如果keychain item撞车，以最新的同步
- 仅接收方device可解密

当一个new device被加入circle，其余device都会与new device同步一次keychain，确保大家的keychain内容一致

### certain items are synced

部分内容不同步，例如vpn连接配置信息；部分内容会同步，例如wifi密码等。由 kSecAttrSynchronizableattribute 区分。

默认情况下，由third-party app添加的keychain items不同步；除非third-party app developer明确设置 kSecAttrSynchronizableattribute要求同步。

### secure keychain recovery

apple 提供secondary authentication, 以及一个secure escrow service。

使用一个strong passcode对keychain内容加密，escrow service为通过鉴权的用户提供keychain的copy。

#### use of secondary authentication

- 如果开启two-factor authentication，则使用device passcode恢复escrowed keychain
- 如果未开启two-factor authentication, 则使用icloud security code恢复escrow keychain

#### keychain escrow process

device如何备份keychain：
- 导出keychain的copy
- 使用asymmetric keybag里的keys加密keychain copy，将密文置于icloud key-value storage area。
- asymmetric keybag被icloud security passcode wrapped，并且由云端HSM cluster的public key再搞一个envelope，该envelope即为escrow record。
- 对于two-factor authentication account: keychain 由intermediate key wrapped，密文存储于cloudkit；intermediate key 只能通过escrow record解密。
- 也可以生成random key，然后使用icloud security code wrap random key，无需escrow record。

用户以sms message，进行recovery的启动授权。

#### escrow security for icloud keychain

云端要校验icloud account password、sms确保用户处于安全登录态，然后使用SRP协议校验用户已知icloud security code，注意icloud security code本身并不会传输。

云端hsm解密escrow record，将asymmetric keybag的密文传给device。

device使用icloud security code解密random keys, 这些random keys用于解密asymmetric keybag，恢复user's keychain。

防暴力破解：10th failed attempt，云端就删掉escrow record。

## applepay

payment交易: user, merchant, card issuer

secure element: 
- EMVCo certificated
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
-  用双向nonce防重放, 协商session key
- aes

生产的时候，shared pairing key从secure enclave传给产线的hsm，hsm再注入secure element。

#### authorizing a secure transaction 

业务authorize交易，secure enclave就sign { 交易内容, 交易类型(contactless、还是within apps), Authorization Random (AR) }

AR 是 apple pay 首次 provision 某个credit card时，secure enclave生成的。只要apple pay还是enable，AR就一直存在，受secure enclave的anti-rollback保护。

如果secure element收到一个新的AR值，secure element就把之前所有card标记为deleted。

#### using a payment cryptogram for dynamic security

添加card时，secure element applet会provision一个key，该key的信息与 payment network / card issuer 共享。

同时维护一个transaction counter，递增。

    one-time-code = cryptogram_func(key, transaction counter, transaction data, other data [optional])
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

当card初始化时，secure element 保存pairing key & authorization random (AR)，用于后续认证

secure enclave 在某些场景下自动把AR标识为disable，使得card失效：
- passcode disable
- password disable
- sign out icloud
- erase all content & setting
- restore from recovery mode
- unpairing

丢失模式下：
- find my / icloud.com 远程冻结/移除card
- 联系card issuer，冻结/移除 在 apple pay绑定的card

### apple card security

bank account information 存在keychain

业务需要时，数字信封传到目标partner / 监管机构，apple表示无法解密

### apple cash security

可以在imessage里转账

当user sends money with apple pay时，同样是nonce + transaction data签名，apple pay server校验payment signature。encrypted payment credential 也类似。

card issuer可以触发风控问题，内容同样encrypted（apple pay无法解密）。

### tap to pay 

nfc闪付

### using apple wallet

基于secure element + nfc controller，支持各种业务，例如钥匙、卡片、证照、票据等。

student ID cards 场景，Express Mode默认开启，即，不用反复Authentication


如果把一个physical card的余额转到apple wallet app的card上，user必须provide personal information for proof of card possession。

如果可以直接provision from a physical card，在transit card issuer成功认证后，device就生成Device Account Number、转移balance、激活wallet card，与此同时，原物理卡片失效。

balance 在 applet 里加密存储。

如果user移除card时处于在线状态，后续card仍可恢复；如果是离线状态，可能找不回来。

### car key

车钥匙follow CCC标准，钥匙分享通过imessage & IDS。

car key 的增、删、挂失等，与apple pay card方案基本一致。

从iphone、apple watch、vehicle hmi都可以删除car key。

car key可以：lock/unlock, start engine, set the vehicle into drive mode。默认情况下mutual authentication。start engine强制mutual authentication。一些lock/unlock场景可以fast transaction。

car key create:
- eSE，ECC-OBKG(on-board key generation), p-256
- iphone <-> vehicle 之间通过NFC通信。
- key management, apple <-> automaker server 必须是mutually authenticated tls。
- after a key is paired to an iphone, any apple watch paired to that iphone can also receive a key.
- iphone/apple watch设备丢失/找回，key可以suspended/resumed
- 新设备provision key必须发起new pairing / sharing

#### owner pairing

初始化配对，owner必须prove possession of the vehicle。

automaker 发一个email link，或者 vehicle menu 显示：提供一个 one-time pairing password

iphone基于该one-time pairing password，与vehicle建立一个SPAKE2+ P-256的安全连接。

#### key sharing

owner's paired iphone 发送一个 device-specific invitation imessage消息给到key share的目标对象（family member, friend, 同一账号的watch）

通过IDS确保sharing command的e2e安全交互。

被邀请的对象接受邀请，则建立一个ecc digital key，并把该key的 creation certificate chain返回给owner's paired iphone校验。

owner's pair iphone对digital key对应的public key签名。

#### key deletion

device/vehicle端都可以进行key deletion，上报给key inventory server(KIS)

如果vehicle删除该key，automarker server会发remote termination request到keyholder device。

如果device删除该key，applet会签名一个termination attestation通知automaker，KTS会移除该key

#### standard transaction

vehicle reader 以 long-term private key 签名 ephemeral public key

iphone <-> vehicle reader: secure channel ... (DH, KDF)

iphone -> vehicle reader:  public key identifier, { vehicle reader's challenge, app-specific data }, sig

#### fast transaction

standard transaction 时，shared a secret。

可以 基于shared secret  + ephemeral key pair, 建立secure channel。

#### privacy

车厂server不存iphone device ID, SEID, APPLE ID，只存the instance CA identifier——相当于识别手机厂。

### user data confidentiality over radio links

session encryption => personally identifiable information (PII)

encryption is performed by the application layer

## imessage

imessage 基于 Apple Push Notification (APN) 进行应用扩展，内容端到端加密。

三个key： 
- rsa1280 加密，p-256 加密，p-256 签名
- 私钥存储于keychain（only available after first unlock)
- 公钥上传到Apple Identity Serive(IDS), 与用户手机号/邮箱、设备APN地址关联。phone通过sms校验、email通过confirm link校验。

### sends and receives messages securely

sender 找 IDS 查询 receiver 的 public keys & apn addresses。sender指定的查询源：phone, email, 本地contacts里的phone/email。

旧版：
- sender随机生成88-bit value
- 以88-bit value作为hmac-sha256的key，结合双方公钥+plain text，派生一个40-bit value。
- 将88-bit value & 40-bit value拼接为 128-bit aes-ctr key。
- 40-bit value可以用来校验plaintext。
- 以rsa-oaep加密aes-ctr key。
- { message密文+ key密文 } 使用 sender device's private signing key 签名, ecdsa-with-sha1。

ios 13之后，改用ecies加密数据，不用rsa。

APN:
- { message 密文, key密文, digital signature } 通过APN服务进行消息传递
- APN的timestamp, apn address明文
- device与APN server之间TLS

内容限制:
- APN转发的消息长度：4KB ~ 16KB
- 传图片等大的附件：随机生成aes-ctr 256-bit key加密附件，密文上传icloud；aes key, 附件密文URL, 密文的sha1 作为imessage消息内容传输。

群聊场景，1 : N 发送。

APN支持离线消息缓存，30 days。

### secure imessage name and photo sharing

data分成3个fields: name, photo, photo filename

首先随机生成128 bit record key, 再用hmac-sha256基于该record key + nickname，派生出key1, key2, key3。

每个data field: 
- 随机生成96 bit IV，使用key1加密, aes-ctr。
- key2 用于计算{ field name + field iv + file ciphertext } 的 mac, hmac-sha256
- 用key2计算的多个mac拼接，使用key3计算出一个hmac-sha256的总mac。总mac的前128 bit用作record id标记。
- record密文在cloudkit public database存储，以record id标识。record不会更新，如果user修改name/photo，会重新加密生成新的record。
- 用户分享photo：nickname & record key & record id 作为imessage消息内容传输。

### secure apple messages for business

business 不同步user's phone/email/icloud account information。

而是由apple identity service (IDS)生成一个custom unique identifier (opaque ID) => 与 user apple ID + business ID 唯一关联。

同一user apple ID 在不同business ID下，有不同的opaque ID。

### facetime security

初始化连接：APN message、Session Traversal Utilities for NAT (STUN) message。

密钥协商：校验device identity certificate, 派生shared secret。基于shared secret派生SRTP stream session key, aes-256-ctr, hmac-sha1。

安全通信：STUN、Internet Connectivity Establishment (ICE)。尽量E2E。

群组通信(支持33人)：基于IDS的点对点认证，分发群组密钥，支持前向安全。session key以aes-siv wrapped，使用p-256 ecies分发到各participants。如果有一个新参与者加入，则新起一个session key。

## find my

在线设备（连wifi，或者连cellular）可以上报自身位置信息给icloud。

离线设备可以通过蓝牙连接，使用其他设备作为中转，上报位置信息给icloud。

    device 初始化: P-224 密钥对{ d, P }，  256-bit SK_0，一个counter_i = 0。
    上述密钥信息不会传给apple，但是会通过keychain机制传给同一用户账号下的其他device。
    P-224公钥长度正好能塞到一个蓝牙广播里。

    每隔15分钟更新counter_i，更新 SK_i = KDF(SK_i-1, "update")
    (u_i, v_i) = KDF(SK_i, "diversify")
    d_i = u_i * d + v_i  
    P_i = u_i * P + v_i * G
    由于counter_i定期轮转，P_i也定期变换，避免追踪。
    nearby device(finder)使用接收到的P_i，ECIES加密自身location，上报到apple server，使用P_i的sha256做为关联id。

    同一用户的其他设备可以通过keychain同步的信息，推算d_i & P_i，获取多个finder上报的位置信息，提高精度。

## Continuity

通过icloud/bluetooth/wifi，设备接力干一些事情。

### handoff

设备近场接力。

如果两个设备都连icloud，则通过类似imessage的APN消息传递，同步out-of-band BLE pairing信息，无感配对。

device paired之后，每个device会生成一个256 bit的aes key，放在keychain同步。该key用于BLE advertisements的加密和认证，用于向接力的设备同步当前设备的活动状态、并防重放。

当device接收到某个新key保护的advertisement，就在与源device的BLE连接下、执行advertisement encryption key exchange。可以通过类似imessage的APN消息/BLE消息的方式，加密同步。

#### handoff between native apps and websites

native app 可以 resume user activity on a webpage in domain

前提是native app developer 也能管控该 domain，系统要校验app是否被授权

    sender:当用户浏览某个webpage时，system BLE加密广播该webpage的domain，仅同一账号下的其他设备可以解密该广播
    receiver: 系统解密收到的广播，通知app，app获得webpage的title & full url。

#### handoff larger data

初始化BLE连接，然后切换到WiFi p2p。

device 之间 wifi tls通信，双向校验iCloud identity certificates，确认user's identity。

#### universal clipboard

同一用户的不同设备下的app之间，通过handoff共享clipboard data

#### iphone cellular call relay

条件：当同一用户的mac/ipad/homepod等设备与iphone处于同一wifi环境

场景：iphone收到一个call，通过imessage的APN通知到其他设备，用户在某一个设备answer call，iphone与该设备建立e2e的信道传输通话信息。handoff BLE加密广播通知其他设备不要再响铃。

场景：在其他设备上外播一个call，通过APN通知到iphone，iphone外播call，同样建立e2e的信道传输通话信息。

在facetime上关闭iphone cellular call可以禁用phone call relay功能。

#### iphone text message forwarding

把iphone上收到的sms text传输到同一用户的其他ipad/mac/...

通过imessage进行消息传递。

reply的消息返回给iphone后，iphone再外发为imessage消息或者sms text。

### Instant Hotspot

设备连到某个其他ios/ipados设备的热点，必须是同一用户账号、或者是family sharing的账号。

用户在某个设备设置热点，基于与用户关联的DSID( Destination Signaling Identifier)派生identifier（周期性更新identifier），广播该identifier。
- 同账号（无感）：同一用户账号下的其他设备检测到该identifier，尝试连接热点。
- 跨账号：如果用户 isn't part of family sharing ，则会发一个turn on personal Hotspot的请求，该请求通过BLE加密发送（加密方案类似imessage），响应消息同样加密发送、返回personal hotspot connection information。
- 跨账号（无感）：如果用户 is part of family sharing，则personal hotspot connection information通过类似homekit device方案同步：设备之间已经预先通过IDS交换对方的device-specific ED25519 public key；通信时X25519-ED25519协商密钥。

# network security

## tls

没啥特别的

SHA-1 certificate 默认不给用了

RSA2048 / RC4 等拒绝

## app transport 

    ECDHE_ECDSA_AES and ECDHE_RSA_AES in GCM

    CBC mode

app可以为某个domain指定`RSA_AES`，禁掉FS。

## certificate

RFC5280, RFC6962

## ipv6

RFC3972 CGA (Cryptographically generated addresses)

SLAAC (stateless address autoconfiguration)

RFC7217

每24 hours更新地址

private wifi address => unique link-local address is generated for every Wi-Fi network，避免关联分析

ipv6 protection: RFC6980, RFC7112, RFC8021

## vpn

protocol: IKEv2/IPsec, SSL-VPN, L2TP/IPsec, ...

VPN on demand: use certificate-based authentication

per app vpn: 指定app才连接特定vpn

always on vpn: 所有

## wifi

AES encryption: 128-bit, 256-bit

WPA3 Enterprise aes 192-bit

802.11w PMF(protected management frame) service, unicast/multicast management

802.1x  radius authentication environment

### Platform protection

限制network processor访问application processor memory
- USB/SDIO(secure digital input output): network processor can't initiate DMA transaction to AP
- PCIe: each network processor is on its own PCIe bus. IOMMU to limit the network processor's DMA access to memory & resources.

### privacy

randomized MAC address => scan

a unique random MAC address per network

wifi frame seq number randomize

mac换，seq number也同步换

hidden service set identifier(ssid)

## bluetooth

pairing： p-256，aes-cmac

bonding：安全存储

Authentication： hmac-sha256 and aes-ctr, fips-approved algorithm

encryption：aes-ccm

message integrity：aes-ccm

secure simple pairing against eavesdropping: ecdhe

secure simple pairing against mitm ：passkey entry/numerical comparison，必须有用户参与，避免自动初始化

version: >=Bluetooth 4.1/4.2

### privacy

address randomize: rpa, identity resolving key(IRK)

cross-transport key derivation: LTK <-> LK 互相derive

## uwb (ultra wideband)

mac address randomization

wifi frame seq number randomization

## sso(single sign-on)

Enterprise network

sso : kerberos, PKINIT

spnego token, heimdal project

    AES-128-CTS-HMAC-SHA1-96
    AES-256-CTS-HMAC-SHA1-96
    DES3-CBC-SHA1
    ARCFOUR-HMAC-MD5

### extensible sso

openid, oauth, saml2, kerberos

## airdrop

BLE + WIFI P2P => 近场传输文件、信息

不需要wifi ap。

macOS: tls

### operation

用户登录icloud，device 存储一个 rsa2048 identity。

用户启用airdrop时，基于与用户appleid关联的phone number/email address生成一个short identity hash。

当用户选择airdrop 共享某文件，sending device 基于short identity hash发BLE广播，responding device监听到广播后回复自身的short identity information & WIFI P2P相关信息。

sending device与receiving device初始化wifi p2p连接，然后发送sending device自身的long identity hash；如果responding device在contacts里找到对应的long identity hash，就把responding device对应的long identity hash发给sender device。

long identity hash校验后，sending device显示备选的receiver device的name & photo，由用户选择。

sending device <-> receiving device: TLS based on icloud identity certificate；校验certificate里的identity信息

receiving device 侧应弹窗询问是否接受incoming transfer。

### wifi password sharing

ios devices 之间传递wifi password的方式与airdrop类似

某个device要连接某个wifi时，发广播请求获得该wifi的password

其他device要求requestor提供identity信息

identity校验ok后，传输password信息

### macos firewall

block all incoming connections

allow built-in software to receive incoming connections

allow downloaded and signed software to receive incoming connections

user-specified apps => user configure

不回应扫瞄器的icmp/port扫瞄

# Developer Kits

提供给第三方developer的开发框架: HomeKit, CloudKit, SiriKit, DriverKit, ReplayKit, ARKit

## HomeKit

ios设备生成 ed25519 keypair => homekit identity，存储于keychain。

homepod & apple tv 通过 tap-to-setup 等方式同步

iphone使用IDS将keys同步给watch。

### communication between homekit accessories

homekit accessories生成自身的ed25519 keypair。

绑定：使用SRP 3072-bit 协议，在ios系统设备上输入 8 digit code (accessory manufacturer提供)，用hdkf-sha-512派生密钥，CHACHA20-POLY1305 加密信道，最终完成ed25519的key exchange、accessory's MFi certification。

会话：使用STS(station to station protocol)，使用ed25519 + curve25519协商的密钥hkdf-sha-512派生的key

broadcast encryption key: HKDF-SHA-512 派生的key，CHACHA20-POLY1305。用于加密BLE advertisement。ios设备周期性更新该key，并通过icloud服务同步到其他设备。

### data security

homekit identity + random nonce => derive keys => encrypt homekit data

icloud & icloud keychain 远程同步

STS 近场同步—— X25519-ED25519

跨账号的控制，必须由owner's device 把跨账号的public key同步给accessory，accessory才能校验来自跨账号设备的指令。

#### apple tv & homekit

首先必须是icloud安全登录态(双因子认证)。

device & tv 从icloud云端获取对方的temp ed25519 public key。

如果device & tv处于相同local network，双方使用temp ed25519 public key进行sts协议协商会话密钥。

使用该安全信道，owner's device 把 user's ed25519 public-private key pairs 传给tv。这些keys用于tv与homekit accessories、tv与ios devices的安全通信。

#### home data and apps

用户授权apps访问home data数据

homekit数据存储于ios设备，使用user's homekit identity keys + random nonce 派生keys 加密。数据保护等级为 class C。

备份时必须加密。

### secure router

homekit router 支持wifi ppsk，即，为每个accessory分配专用密码。

### homekit camera 

camera stream 端到端加密(近场&远程)，ios device侧的app可以看，不能存/不能截屏。

### homekit secure video

本地apple device (例如homepod, apple tv, ipad, 作为home hub)存储video。

本地home hub与ip camera之间协商出hkdf-sha-512派生的session keypair，在home hub解密数据。aes-256-gcm。

随机aes key加密video内容，上传到icloud。相关metadata（包含随机aes key），端到端上传到cloudkit。

其他设备通过icloud同步获得metadata里的aes key，解密已下载的video内容。

### use third-party remote accessories with apple tv

apple tv <-> homekit remote accessory: per-session HKDF-SHA512 derived key-pair

apple device <-> apple tv: secure session里，把token给到tv，用于同步跨账号的数据(between users of the home)。

homekit accessories 与 home hub通信，home hub与icloud通信。

homekit accessories <-> apple device: 双向认证，端到端安全通信。

#### accessory setup process

homekit accessory 初始化...

用户signing in to icloud。

accessory 生成 p-256 keypair。

accessory 出厂built-in的 Apple Authentication Coprocessor 对一个来自ios设备的challenge计算签名。

accessory : p-256 pubkey, challenge's sig, x.509 certificate of the Authentication Coprocessor  

apple device 向 icloud provision server 请求为 accessory 签发一张certificate。除非accessory授权icloud remote access，否则该certificate不含任何identity information。

#### accessory list of allowed users

icloud server 为 user 分配一个 identifier，用于access 当前 accessory。注意，同一用户访问不同accessory，identifier可以不一样。

icloud server 也为 accessory 分配 identifier。

#### accessory connect to icloud remote access server

accessory 与 icloud remote access server联系时，会提供certificate、一个pass。

pass由accessory从其他icloud服务器获取，请求pass时，仅提供 manufacturer, model, and firmware信息，无身份认证。多个accessory可以共用相同的pass。

accessory <-> icloud remote access server: http/2，tls1.2，aes-128-gcm，sha-256，同步信息

icloud remote accessory server <-> ios device: 为accessory与ios device中转信息

## cloudkit

app developer存储 key-value data，structured data，assets

public databse: app的通用配置，不加密。

private database: app的用户数据，加密。

cloudkit service key -> cloudkit zonewide key -> cloudkit record key -> file metadata (包含per-file/per-chunk key) -> file chunklist  -> file chunk

cloud kit service key 存储于 user's icloud account

## sirikit

app设定siri可访问的内容

## driverkit

apple device driver 开发

## replaykit

直播/录频

recording and broadcast => camera & microphone 

## arkit

camera, photo, video 的 access control

# Secure Device Management

BYOD: bring your own device

把Enterprise data单独存储于一个专用的volume。

## pairing model

host computer <-> ios device: 输入passcode，交换 rsa2048 公钥。随后device向host提供一个256bit的key，用于解密device上的escrow keybag。

要求30天内曾经用usb连接过，此后双方可以通过wifi无感连接，建立SSL session。

apple TV 也可以用 SRP 协议作无线pairing。

## Mobile device Management

MDM 提供服务： configuration profiles, OTA Enrollment, APNs (apple push Notification service), 远程锁机。。。

### Enrollment types

user Enrollment : 用户的apple id绑定

device Enrollment :  设备初始化

automated device Enrollment: 机构批量管理设备

### device Restrictions

限制可用的app

管理员密码

### Enrollment profiles

Enrollment profile: XML

profile signing & encryption: cms RFC5652

可以用SFTP同步信息，用system for cross-domain identity management (scim) 或 active directory 生成账号。

### certification

ISO/IEC 27001  isms Information Security Management System

ISO/IEC 27018  PII personally identifiable information

FIPS 140-X, ISO/IEC 19790, ISO/IEC 24759  cryptographic module validation

Common Criteria Certifications (ISO/IEC 15408)

## activation lock

wifi 连接 -> 向apple server申请activation certificate

如果device is activation locked，用户输入应提供icloud credential——账号密码，然后获取activation certificate。

获得activation certificate后，默认打开activation lock。

### mac with apple silicon

启动时：LLB必须校验 LocalPolicy, 并确认LocalPolicy policy nonce 与 secure storage component 里存储的值相同。

激活：
- 获取activation certificate
- activation certificate key 用于进一步获取 RemotePolicy certificate
- LocalPolicy key  +  RemotePolicy certificate 构造LocalPolicy

### intel-based mac

启动时：校验activation certificate

### lost mode, remote lock, and remote wipe

丢失模式，远程锁定、擦除内容

#### lost mode

MDM administrator 可以远程打开lost mode。

当lost mode开启后，当前user自动登出，设备无法解锁。屏幕显示机主设置的消息内容。

#### remote lock & remote wipe

MDM, microsof exchange activesync, icloud 都可以下发remote wipe command

device也可以设置为，如果passcode尝试次数过多，自动wipe。

## shared ipad

multiuser mode

两种 signing: 
- identity provider's(IDP) sign, SRP, short live token, passcode 
- managed apple ID  Authenticated with APPLE identity service (IDS)

## screen time

同账号设备通过cloudkit e2e 同步screen time control & usage data

家长device <-> 孩子device : 通过IDS e2e 同步 usage data & configuration settings 
