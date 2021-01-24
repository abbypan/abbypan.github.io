---
layout: post
category: tech
title:  "Arm: Generic Timer"
tagline: ""
tags: [ "arm" ] 
---
{% include JB/setup %}

* TOC
{:toc}

# doc

[AArch64 Programmer's Guide: Generic Timer - Arm Developer](https://developer.arm.com/-/media/Arm%20Developer%20Community/PDF/Learn%20the%20Architecture/Generic%20Timer.pdf?revision=c710e7a7-9f52-4901-8c9d-91b19f44f9c7)

每个PE有自己的Timer，每个Timer都与System Counter系统计数器相连(System Time Bus)。

Timer由Interrupt Controller(GIC)通过Private Peripheral interrupt交互

system count value通过time bus广播到各个Timer。注意这个是系统计数值，不是时间(time)或者日期(date)。

SoC包含Real-Time Clock(RTC)，负责时间(time)和日期(date)。

# EL

EL1/Non-secure EL2/Secure EL2: physical/vitual timer

EL3: physical timer

# System Counter

System Counter用于在各个PE协同，例如：
- Device A将当前system count附加到message，给到Device B
- Device B将收到system count与当前system count对比，确保收到的count比当前的count小

system counter是在always-on power domain，以fixed frequency递增

## TVAL & CVAL

TVAL设置 timer trigger in X ticks

CVAL设置一个绝对值，当timer达到指定值时fires

# External timer

外部Timer也可能连到System Time Bus，通过GIC的Shared Peripheral Interrupts(SPIs)传递中断
