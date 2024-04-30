---
layout: post
category: chip
title:  "Arm: Memory Model"
tagline: ""
tags: [ "arm" ] 
---
{% include JB/setup %}

* TOC
{:toc}

# doc

[AArch64 memory model](https://developer.arm.com/architectures/learn-the-architecture/aarch64-memory-model/)

Memory address: peripherals, kernel data, kernel code, application data, application code

# memory

每个memory translation table (page table) entry，称为block, or page descriptor.

block descriptor：
- Uppper Attributes: Reserverd for software use, UXN (执行权限), PXN (执行权限), Contig
- Output Block Address
- Lower Attributes: nG, AF, SH(share), AP(access permission), NS, Indx

## hierarchical attributes

由于虚拟地址转换，memory attributes是follow更底层（或者说更高权限的）的设定

Peripherals: Non-cached Ordered, R/W Not executable, Privileged access only

Kernel Data: Cacheable, R/W Not executable, Privileged access only 

Kernel Code: Cacheable, Read-only executable, Privileged access only  

Application Data: Cacheable, R/W Not executable, Unprivileged

Application code: Cacheable, Read-only executable, Unprivileged

# memory access ordering

SSE: Simple Sequential Execution，指令按顺序执行

注意：memory access ordering 与 instructions ordering 不同


# memory types

包含memory type，以及cacheability information

normal memory, device memory

## normal memory

现代处理器可能merge accesses（提升性能）、predicting behavior（预取，提升速度）

## device memory

device memory for peripherals: Memory Mapped I/O (MMIO)

- `Device_GRE`
- `Device_nGRE`
- `Device_nGnRE`
- `Device_nGnRnE`

Gathering(G, nG): 是否允许merging multiple access

Re-ordering(R, nR)：是否允许re-order到某个peripheral的accesses

Early Write Acknowledgement(E, nE): 什么时候认为一个write是完成的，是到cache认为完成，还是到目标地址认为完成

# permissions attributes

PAN (Privileged Access Never): APP可以指定某些内容禁止OS特权LDR访问。注意，挡不住OS的LDTR/STTR特权访问。

UXN (User Execute Never): EL0

PXN (Privileged Execute Never): EL3/EL2

- Peripherals: Not executable, PXN=1, UXN=1
- Kernel Data: Not executable, PXN=1, UXN=1
- Kernel Code: Privileged executable, PXN=0, UXN=1
- Application Data: Not executable, PXN=1, UXN=1
- Application Code: Unprivileged executable, PXN=1, UXN=0

A location with EL0 write permissions is never executable at EL1 => 关键

Device regions: Execute Never (XN)

# Access Flag

AF = 0: Region not accessed

AF = 1: Region accessed

# memory aliasing and mismatched memory types

multiple virtual addresses => aliasing

如果virtual address space在stage1 tables标记为device，在stage2 tables标记为normal，那么从严不从宽，视为Device。

如果`HCR_EL2.FWB`置位，则stage2 tables的标记可以覆盖任何stage1 tables的标记

