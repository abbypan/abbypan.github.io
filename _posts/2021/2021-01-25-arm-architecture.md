---
layout: post
category: arm
title:  "Arm: Introducing the Arm architecture"
tagline: ""
tags: [ "arm" ] 
---
{% include JB/setup %}

* TOC
{:toc}

# doc

[Introducing the Arm architecture](https://developer.arm.com/architectures/learn-the-architecture/introducing-the-arm-architecture/single-page)

[Don't We All need ARMs?](https://www.cs.umd.edu/~meesh/cmsc411/website/proj01/arm/home.html)

three architecture profiles: 
- A-profile (application), 例如手机
- R-profile(Real-time), 例如网络设备、嵌入式控制系统
- M-profile (Microcontroller), 例如IoT

arm按功能打包成不同IP模块卖。。。

核心内容：
- Instruction set
- Register set
- Exception model
- Memory model
- Debug, trace, and profiling

核心组成：
- Debug Port
- Generic Interrupt Controller (GIC)
- DMA
- System Memory Management Unit(SMMU)
- System Controller
- Interconnect
- System Counter
- Generic Timer
- RAM
- Peripheral

Architecture:
- SBSA: Server Base System Architecture
- TBSA: Trusted Base System Architecture 
- AMBA: Advanced Microcontroller Bus Architecture

Processing Element (PE): anything that has its own program counter and can execute a program
