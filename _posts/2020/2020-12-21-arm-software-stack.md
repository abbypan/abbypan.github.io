---
layout: post
category: tech
title:  "ARM: PAC, BTI, MTE"
tagline: ""
tags: [ "arm" ] 
---
{% include JB/setup %}

* TOC
{:toc}

# pac, bti, mte

[Providing protection for complex software](https://developer.arm.com/architectures/learn-the-architecture/providing-protection-for-complex-software)

## UXN & PXN

UXN： User (EL0) Execute-never

PXN: Privileged Execute-never

例如，

application code应该在EL0用户空间执行(UXN=0)，但不应当在内核权限下执行（EL1、EL2）, PXN=1

application data: PXN=1 , UXN=1

kernel code: PXN=0, UXN=1

kernel data/peripherals: PXN=1, UXN=1

此外，还有system call的滥用，get privileged code to call code from user memory，提权

## Return-oriented programming (ROP) attack

攻击者篡改返回地址。。。

一种方案是将地址空间随机化 Address Space Randomization (ASLR)，增加攻击的困难度

另一种方案是对返回地址做校验，Point Authentication

## Point Authentication Code (PAC)

用户空间、内核空间的内存地址高位其实都比较固定，可以弄成虚拟地址映射，把地址高位挪出来放PAC

虚拟地址空间的大小，决定了留给PAC的高位bit数的多少

PAC的思路是在stack push之前，计算返回地址的mac值，在返回时强制检查返回地址是否匹配

有5个128-bit keys用于计算PAC：
- 2把key, A/B, 用于 instruction pointers
- 2把key, A/B, 用于data pointers
- 1把通用key

pac = mac(pointer, key, modifier)

不同的pointer可以选用不同的key

modifier可以是一些context信息，例如此次function call的Stack pointer(SP)信息。

每个running application可以使用不同的key，相同application每次运行被分配不同的key。

后向兼容是用入栈、出栈前加个NOP

## Jump-oriented programming (JOP) attack

攻击者诱使代码跳到异常地址，而非预设的空间。

Branch Target Instructions (BTIs), 也称landing pads，即，仅允许跳转的指定类型的目标地址。


## Memory Tagging Extension (MTE)

内存问题：
- use after free：use allocated memory after releasing it，or after it is out of scope
- buffer overrun/overflow，内存越界

所以，其实可以在分配内存空间的时候，给内存空间打tag。

tag符合预期的才允许访问，这样就可以防止越界访问。

内存释放后就改tag，旧pointer知道的旧tag没法继续用。

注意，PAC与MAC可以同时启用，占的都是虚拟地址的高位bit空间。

# qualcomm pac

[Pointer Authentication on ARMv8.3](https://www.qualcomm.com/media/documents/files/whitepaper-pointer-authentication-on-armv8-3.pdf)

一些内存安全的策略：
- 设置敏感数据的内存只读
- 对pointer进行一些检查，统称software stack protection (SSP)。例如Control Flow Integrity(CFI), ROP mitigations
- 将地址空间随机化(ASLR)
- Data Execution prevention(DEP/W^X): code is not writable, data is not executable
- hardened heap

## software stack proctection (ssp)

placing a random canary value between the return address and buffers on the stack

## pac

PAC的key在processor registers存储，EL0读不到。

PAC还能抵御DMA attack，即，在processor core之外的攻击。。。

pac的mac算法用qarma，比siphash、prince强点。

key是ephemeral的，per process for EL0, per boot for EL1 to EL3


## pointer substitution attack

以另一个合法的pac替换正确的pac

这个得看参与pac计算的context的区分度，同一类context下的pointer可能被恶意替换。。。

另外就是可以设法读取栈内容，然后触发对应的function call。。。

## Just-in-Time compilation (JIT)

JIT使用writable and executable (RWX) memory，比较危险。。。




## control flow integrity (CFI)

control flow follows only legitimate paths determined in advance.

CFI主要保护function pointers，即，只能调同class的function pointer，每次indirect call/jump的时候，都会check一下白名单的function pointer调用表

function pointer可以是编译期生成，也可以是启发式生成









