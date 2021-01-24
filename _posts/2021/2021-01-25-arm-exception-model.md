---
layout: post
category: tech
title:  "Arm: Exception Model"
tagline: ""
tags: [ "arm" ] 
---
{% include JB/setup %}

* TOC
{:toc}

# doc

[AArch64 Exception model](https://developer.arm.com/architectures/learn-the-architecture/exception-model)

Exception Level: EL0 (Application), EL1(Rich OS), EL2(Hypervisor), EL3(Firmware/Secure Monitor)

不同Level的权限不同，主要是两类权限：
- Memory Privilege（访问内存）: 通过MMU管控。EL0是非特权模式，EL1/2/3要做权限检查。
- Register Access(访问处理器资源)

# exception types

synchronous exceptions: caused by, or related to, the instruction that has just been executed

asynchronous exceptions: generated externally, not synchronous with the current instruction stream
- Physical interrupts: SError(system error), IRQ, FIQ
- Virtual interrupts: vSError, vIRQ, vFIQ

不同的level收到不同的type的exception，根据对应的访问控制策略处理



