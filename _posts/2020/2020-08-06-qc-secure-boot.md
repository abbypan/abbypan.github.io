---
layout: post
category: tech
title:  "Qualcomm Secure Boot and Image Authentication"
tagline: ""
tags: [ "chip" ] 
---
{% include JB/setup %}

* TOC
{:toc}

# doc

[Qualcomm Secure Boot and Image Authentication](https://www.qualcomm.com/media/documents/files/secure-boot-and-image-authentication-technical-overview-v2-0.pdf)

secure boot 的起点是 PBL，只读，物理安全。

TEE(EL3)的boot chain: `PBL -> XBL_SEC -> QTEE`

REE(EL1)的boot chain: `PBL -> XBL -> QHEE -> OS Bootloader -> OS Kernel`

TEE的images可以同时被Qualcomm、OEM（设备制造商）并列签名，image遵守标准的ELF文件格式。

# TEE loading

- `XBL_SEC`先为TEE memory设访问控制
-  XBL把TEE image读入memory
-  XBL通知`XBL_SEC`校验TEE image
-  `XBL_SEC`锁定TEE image的memory
-  `XBL_SEC`校验TEE image
-  `XBL_SEC`跳转执行TEE image
-  XBL载入其他images（例如OS kernel）

#  signed image format

Qualcomm Technologies firmware images 遵守 ELF 标准格式，包含 { elf header, program headers, hash table segment, elf segments }

其实，hash table segment 也是一个elf segment，只是qualcomm为这个hash table segment设置了自定义的格式。

hash table segment 包含：
- mbn header: hash table segment各个field的位置信息
- QTI metadata: Qualcomm对当前image设置的一些信息
- OEM metadata: OEM对当前image设置的一些信息
- Hash Table: 该ELF文件的{ elf header + program header}的hash、其他elf segments的hash
- QTI signature
- QTI Cert Chain
- OEM signature 
- OEM Cert Chain
- 0xFF padding

QTI signature/OEM signature所对应的原文范围都是 { mbn header, QTI metadata, OEM metadata, Hash Table }

# image metadata

- `SW_ID` : 当前image的类型
- `HW_ID` : 当前image适用的芯片类型
- `OEM_ID`: 当前image适用于哪个OEM
-  debug标识
-  当前image是否与单个device绑定，而不是全局通用的image
-  防回滚

旧版本的设计是把metadata写到leaf certificate的OU field了，解析比较麻烦，每次image升级都要重新签发leaf certificate。

# cert chain & signature

RSSSSA-PSS, ECDSA NIST P-384

Root CA Cert的hash值 写在efuse里、或者hardware rom code里。

# image loading

loader对image依次干这些事：
- 安全载入elf header
- 安全载入program header
- 安全载入hash segment
- 校验hash segment的签名，一直验到root ca cert的hash
- 校验 { elf header + program header } 的hash是否与hash table里的一致
- 校验每个elf segment的hash是否与hash table里的一致
- 按elf header的设置跳转执行

# summary

分拆REE/TEE的boot chain，更安全

把metadata从leaf certificate里面挪出来，省事

