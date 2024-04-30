---
layout: post
category: chip
title:  "Arm: Trustzone"
tagline: ""
tags: [ "arm" ] 
---
{% include JB/setup %}

* TOC
{:toc}

# doc

[Arm TrustZone Technology](https://developer.arm.com/ip-products/security-ip/trustzone)

核心是区分了Non-Secure, Secure的Physical Address Space

Translation Lookaside Buffer: Tag, Translation Regime(EL1, EL2, ...), NS (1, 0), VMID, ASID, Descriptor

SMC: Secure Monitor Call

# Enforcing Isolation

Secure, Non-Secure, Boot time configurable (启动时配置device是S/NS), Trustzone aware

Trustzone aware => Trustzone Address Space Controller (TZASC) => 分配DDR

balance cost, usability and security

# devices

OTP(one-time programmable memory) or fuse

Non-volatile counter: anti-rollback

Trusted ROM: first boot code, attacker cannot replace it. can not reprogram it.

Trusted RAM: SRAM, on-chip, running in secure state, attack hard to gain access to its content.


# Trusted Base System Architecture (TBSA)

guidelines for system designers


# software architecture

软件架构图比较关键。

user-space application 不会直接访问trustzone，而是通过service api library调用。

srvice library <-> trusted service 之间通过message queues / mailboxes in memory 通信。

注意，Non-secure state can only see Non-secure memory.

有一些driver通过secure state, 底层EL3的smc传递到Trusted Kernel. 

# boot and chain of trust

first stage: boot ROM, 主要是load and verify { second stage boot code from flash }
-> second stage: boot code from flash, 一般为off-chip dram建立memory Controller。load and verify { the images that will run in secure and non-secure state }, 例如TEE, UEFI.
-> third: TEE
-> third: UEFI -> OS/hypervisor

Trusted Board Boot Requirement (TBBR)

# example use case

## encrypted file system 

authentication 之后，encrypted filesystem key 被读入 on-chip secure memory。使用master device unique key解密后，存储于on-chip.

filesystem key is provisioned, 只能由crypto engine / memory controller 安全访问

the provisioned key is used for filesystem encrypt/decrypt

Trustzone  never expose the filesystem keys to Non-secure state software.

