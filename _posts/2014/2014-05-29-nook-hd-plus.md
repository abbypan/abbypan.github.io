---
layout: post
category : tech
title:  "nook hd+ 刷机 笔记 cm11 rom"
tagline: "刷完比原生系统好用多了"
tags : [ "nook", "ebook", "android", "rom" ] 
---
{% include JB/setup %}

## 烧录sd卡

下载 [emmc-cwm.zip](http://nook.rootshell.ru/hd/cm-11-20140118-UNOFFICIAL-ovation-emmc.zip)

解压``emmc-cwm.zip``得到``emmc-cwm-early.img``

### windows

用 [Win32 Disk Imager](http://www.softpedia.com/get/CD-DVD-Tools/Data-CD-DVD-Burning/Win32-Disk-Imager.shtml) 软件

### linux

将sd卡以usb模式连接到linux，假设为``/dev/sdb``

``sudo dd if=emmc-cwm-early.img of=/dev/sdb bs=1M``

``sync``


## ROM文件

下载 [cm-11-rom.zip](http://download.cyanogenmod.com/?device=ovation)

把``cm-11-rom.zip``拷进nook原生系统的download目录

## 刷机

将sd卡插入nook hd+，并将nook hd+通过usb连接到电脑（否则有时可能进不了recover）

启动nook hd+，会自动进入recovery界面

先wipe data/cache

再刷入``cm-11-rom.zip``

刷完之后返回选择advanced，再wipe dalvik cache

最后reboot system，注意及时拔出sd卡

第一次重启可能会卡住，强制按电源键关机后再重启就正常了（刷华为mediapad的cm rom也碰到过这个问题）

## 安装 google play

在 [google apps](http://wiki.cyanogenmod.org/w/Google_Apps#Downloads) 下载对应的zip文件，进recovery刷入即可
