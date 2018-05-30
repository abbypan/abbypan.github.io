---
layout: post
category: tech
title:  "archlinux/windows10 双系统迁移"
tagline: ""
tags: [ "grub", "windows", "archlinux", "clonezilla" ] 
---
{% include JB/setup %}

* TOC
{:toc}

# 背景

不拆机，不直接对拷硬盘。

以archlinux, windows10为例。

刻录3个启动u盘：clonezilla，archlinux，winpe。

# 步骤

用clonezilla备份旧机器上的archlinux系统。用winpe的ghost备份旧机器上的window10系统。备份的数据存放在外接移动硬盘。

用clonezilla进入新机器，fsck硬盘分区，注意n是新建分区，t是改分区类型(例如ntfs是86)。

新机器外接备份数据所在的移动硬盘。

用clonezilla在新机器上恢复archlinux系统。

用archlinux的启动u盘在新机器上chroot，然后grub-install /dev/sda 写入，可能需要编辑/etc/fstab，/boot/grub/grub.cfg。

用winpe在新机器上ghost恢复windows10系统。

重启新机器，进入archlinux，用os-prober检测windows10系统，更新grub.cfg。

重启新机器进入windows10。
