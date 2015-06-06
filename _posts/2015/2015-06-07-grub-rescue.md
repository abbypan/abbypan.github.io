---
layout: post
category : tech
title:  "linux/windows 双系统调整分区后重启显示 grub rescue"
tagline: ""
tags : [ "grub" ] 
---
{% include JB/setup %}

问题：linux/windows 双系统调整分区后，重启显示 grub rescue，无法引导系统。

修复：

1. 查看分区名称

    grub rescue > ls

2. 依次测试grub在哪个分区下，例如：

    grub rescue > ls (hd0, msdos2)/boot/grub

3. 假设linux安装在msdos2分区下面

    grub rescue > root=(hd0, msdos2)
    grub rescue > prefix=/boot/grub
    grub rescue > insmod normal
    grub rescue > normal

    选择对应linux启动项，键盘输入e，编辑其中引导的分区为msdos2，F10保存自动重启到linux系统

4. 进入linux系统，重装grub到硬盘，假设硬盘为 /dev/sda

    linux系统最好预先安装 os-prober，用于自动探测多系统
   
    # grub-install /dev/sda
    # os-prober
    # update-grub
