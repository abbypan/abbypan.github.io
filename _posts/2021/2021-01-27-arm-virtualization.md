---
layout: post
category: chip
title:  "Arm: virtualization"
tagline: ""
tags: [ "arm" ] 
---
{% include JB/setup %}

* TOC
{:toc}

# doc

[AArch64 virtualization](https://developer.arm.com/documentation/100942/0100/aarch64-virtualization)

virtualization支撑：isolation, high availability, workload balancing, sandboxing

type 1: Hypervisor上跑Guest OS；例如xen

type 2: Host OS上跑hypervisor，hypervisor上跑Guest OS；例如virtualbox, vmware, kvm

# VMID & ASID

每个VM有它自己的ASID空间

VMID区分VM，ASID区分应用

# System Memory Management Units (SMMUs)

SMMU, DMA都是可以直接访问Physical Address的。。。

Guest OS -> VA -> MMU -> IPA -> MMU -> PA

DMA -> IPA -> SMMU ->  PA

# virtualizing exceptions

GIC管所有Physical CPU, vCPU的中断

