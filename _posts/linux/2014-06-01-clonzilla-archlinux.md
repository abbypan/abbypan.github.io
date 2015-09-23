---
layout: post
category : tech
title:  "用 clonezilla 迁移 archlinux 系统"
tagline: "move archlinux"
tags : [ "clonezilla", "archlinux", "clone"  ] 
---
{% include JB/setup %}

### 环境

假设旧机器为A，archlinux 装在A机器的 /dev/sda1 上

假设新机器为B，B上的硬盘为X

假设想要将 机器A上的archlinux 迁移到 机器B上硬盘X的第2分区

### 制作一个启动U盘

下载：[clonezilla-live-zip](http://drbl.nchc.org.tw/clonezilla/clonezilla-live/download/)

例如windows下可以在解压zip文件的目录中找到 utils\win32\ 的bat，双击即可自动制作U盘

###  复制分区

将启动U盘插入机器A，bios设置从U盘启动，重启机器A进入clonezilla-live

A机器的硬盘被挂载为/dev/sda

U盘被挂载为/dev/sdb

把硬盘X从机器B取出，当作移动硬盘插到机器A，假设被挂载为 /dev/sdc

按clonezilla提示，选择从``本机分区``复制到``本机分区``，源分区为/dev/sda1，目标分区为/dev/sdc2

等待clonezilla完成分区复制

### 安装grub

分区复制完成之后，回到clonezilla命令行

获取root权限：``su root -``

挂载/dev/sdc2： ``mount /dev/sdc2 /mnt``

安装grub到/dev/sdc：``grub-install --root-directory=/mnt /dev/sdc``

### 完成迁移

将硬盘X重新插入机器B，启动机器B，即可进入archlinux

如果硬盘X上还有其他操作系统，可编辑/boot/grub/grub.cfg，增加其他启动项
