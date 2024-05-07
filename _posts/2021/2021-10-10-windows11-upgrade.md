---
layout: post
category: util
title:  "手动升级windows10/windows11"
tagline: ""
tags: [ "windows", "grub" ] 
---
{% include JB/setup %}

* TOC
{:toc}

# windows 10

下载媒体创建工具(media creation tool): https://www.microsoft.com/zh-cn/software-download/windows10

使用媒体创建工具(media creation tool)，创建对应版本的windows10的iso文件。

检查C盘分区所在的磁盘，确保该磁盘分区表类型为GPT，并且含有ESP分区。注意ESP分区可以放在最前面，如果放在最后面，windows可能自己新建一个恢复分区，ESP分区编号乱掉。

断网。

挂载windows10的iso文件。

进入挂载后的虚拟光盘，双击setup.exe，选择保留应用和个人文件，执行升级。

升级完成后，自动重启。

# windows 11

windows 11 与 windows 10 类似。

跳过硬件检测：在开始检查时，删除`C:\$WINDOWS.~BT\Sources\appraiserres.dll`。

旧电脑升级，跳过cpu/tpm检查：regedit打开注册表，`HKEY_LOCAL_MACHINE\SYSTEM\Setup\MoSetup`，创建新项AllowUpgradesWithUnsupportedTPMOrCPU, type = DWORD, value = 1。

# archlinux + windows 双系统，恢复grub2引导配置

如果同一磁盘上，还有archlinux系统，需要恢复grub2引导配置。

使用archlinux的启动U盘，重启后，arch-chroot到磁盘上的archlinux分区。

在arch-chroot环境下，挂载ESP分区，参考配置grub.cfg: https://abbypan.github.io/2017/08/08/archlinux 。

