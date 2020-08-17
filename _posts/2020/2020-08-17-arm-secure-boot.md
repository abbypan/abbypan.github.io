---
layout: post
category: tech
title:  "Trusted Board Boot Requirements CLIENT (TBBR-CLIENT) Armv8-A"
tagline: ""
tags: [ "chip" ] 
---
{% include JB/setup %}

* TOC
{:toc}

# doc

[Trusted Board Boot Requirements CLIENT (TBBR-CLIENT) Armv8-A](https://static.docs.arm.com/den0006/d/DEN0006D_Trusted_Board_Boot_Requirements.pdf)

    Trust RAM: on-chip SRAM, off-chip DRAM

    SCP: system control and power management subsystem

    ROTPK: root of trust public key hash

    HUK: hardware unique key

    EK(optional) : endorsement key，内容的可信背书

    SSK(optional) : Secret Symmetric Key，镜像加密 

    BSSK: unique per device key => Binding Secret Symmetric Key

    SOC_ID: SHA256(ROTPK || AES_HUK(Fixed Pattern))

# trusted boot process

code reset启动，进 Power Control Function Trusted Boot ROM，配置Clock、Reset、Power Configuration

然后进AP Trusted Boot ROM，选择ROM分支：
- Manufacturing Test / Key Provisioning Mode
- AP Trusted Boot ROM: Soc TEE配置，检查是否要升级firmware（如果是，转下面AP Non-Trusted RAM）；校验firmware。
- AP Non-Trusted RAM：下载、升级firmware；升级完毕，转AP Trusted Boot ROM。

AP Trusted Boot ROM正常检验AP Trusted Boot Firmware(ROM/ Trusted SRAM)后，校验证书、firmwares。

firmwares的执行顺序为：Trusted Debug Configuration, SoC Firmware/Patch Software execution, SCP Software execution, AP Trusted OS execution, Non-Trusted World Bootloader execution

# certificate chain

arm的secure boot关键信息，存在x.509证书的extension域。

与qualcomm不同的是，arm的每个certificate都是*自签名*证书，链式信任关系通过extension域存储下级的public key实现。
显然，自签名证书的校验开发会简单相对一些，Extension域内容的提取会麻烦一点。

NV counter 用于标记当前firmware版本，防回滚。

image先加密(optional)，后签名。

## Non-Trusted Firmware Updater certificate

Public Key (OEM): Root of Trust Public Key

Extension域包含： Firmware Updater hash，AP Firmware Update Config hash，SCP Firmware Update Config hash

## Trusted Boot Firmware certificate

Public Key (OEM): Root of Trust Public Key

Extension域包含：Trusted Boot Firmware的hash，NV Counter

## Trusted Key certificate

Public Key (OEM): Root of Trust Public Key

Extension域包含： NV Counter, Primary Debug Certificate Public Key, Trusted World Public Key, Non Trusted World Public Key

### Trusted Debug Certificate

Public Key (OEM) : Primary Debug Certificate Public Key

Extension域包含：Debug Scenario, SoC Specific, Secondary Debug Certificate Public Key

#### Secondary Debug certificate

Public Key (Third Party): Secondary Debug Certificate Public Key

Extension域包含：Debug Scenario, `SOC_ID`, SoC Specific

### Trusted SoC Firmware certificate

Public Key (OEM) : Trusted World Public Key

Extension域包含：NV Counter, SoC Firmware Content Certificate Public Key

####  SoC Firmware Content Certificate

Public Key (OEM/ARM) :  SoC Firmware Content Certificate Public Key

Extension域包含：NV Counter, AP Rom Patch Hash, SoC Config Hash, SoC AP Firmware Hash


### Trusted OS Firmware certificate

Public Key (OEM) : Trusted World Public Key

Extension域包含：NV Counter, Trusted OS Firmware Content Certificate Public Key

####  Trusted OS Firmware Content Certificate

Public Key (Trust OS Owner) :  Trusted OS Firmware Content Certificate Public Key

Extension域包含：NV Counter, Trusted OS Firmware Hash


### Non-Trusted Firmware Key certificate

Public Key (OEM) : Non Trusted World Public Key

Extension域包含：NV Counter, Non Trusted Firmware Content Certificate Public Key

####  Non-Trusted Firmware Content Certificate

Public Key (OEM/Rich OS Owner) :  Non Trusted Firmware Content Certificate Public Key

Extension域包含：NV Counter, Non Trusted World Bootloader Hash

### Trusted SCP Firmware certificate

Public Key (OEM) : Trusted World Public Key

Extension域包含：NV Counter, SCP Firmware Content Certificate Public Key

####  SCP Firmware Content Certificate

Public Key (OEM/ARM) :  SoC Firmware Content Certificate Public Key

Extension域包含：NV Counter, SCP Rom Patch Hash, SCP Firmware Hash

#  list of images and patch files

文档的附录B列的比较全，略。

