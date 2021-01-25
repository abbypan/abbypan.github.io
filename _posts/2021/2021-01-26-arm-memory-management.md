---
layout: post
category: tech
title:  "Arm: Memory Management"
tagline: ""
tags: [ "arm" ] 
---
{% include JB/setup %}

* TOC
{:toc}

# doc

[Memory management](https://developer.arm.com/architectures/learn-the-architecture/memory-management/single-page)

virtual address -> physical address 映射关系放在Translation table中

software manages the TLBs(Translation Lookaside Buffers)

# memory management

软件访问虚拟地址(virtual address space)，处理器转换为物理地址

通过虚拟地址机制，OS可以控制软件访问的权限，天然适合sandbox场景

# virtual and physical address

virtual address space: peripherals, kernel data, kernel code, application data, application code

-> Translation Tables

physical address space: ddr, peripherals, flash, sram, rom

注意，Translation Tables一般由OS/hypervisor运行软件维护，在memory中载入


# Memory Management Unit (MMU)

MMU负责执行virtual address与physical address的translation：
- table walk unit: 负责执行管理逻辑，并且将Translation Tables读入memory
- Translation Lookaside Buffers (TLBs): 缓存最近的translation

即，先找TLBs，再Table Walk Unit去Memory找

Translation Tables里包含PA base, Attributes


# Address spaces

NS.EL1 / NS.EL0 
-> Guest OS Tables (stage 1 Translation) 
-> physical memory map seen by guest os (peripherals, ram, flash) 
-> Virtualization Tables (stage 2 Translation)
-> (peripherals, ram, flash)

NS.EL2 
-> Hypervisor Virtual memory map
-> Hypervisor Tables
-> (peripherals, ram, flash)

EL3
-> Secure Monitor Virtual memory map
-> Secure Monitor Tables
-> (peripherals, ram, flash)

IPAs: intermediate physical addresses

# virtual address space

虚拟地址空间大小可以动态设定，以`TCR_ELx.TnSZ`动态控制：`2^(64 - TCR_ELx.TnSZ)`

不能设定比物理地址大的虚拟地址空间。

Address Space Identifiers（ASIDs）：用于标识不同app的虚拟地址空间。

TLB：VA Tag（标识虚拟地址空间前缀——区分Kernel Space, User Space, ...）、ASID、Descriptor

Virtual Machine Identifiers: VMID => 区分不同的VM

