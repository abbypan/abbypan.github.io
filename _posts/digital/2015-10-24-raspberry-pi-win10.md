---
layout: post
category : tech
title:  "windows 7 环境刻录 raspberry pi 2 的 win10 iot"
tagline: ""
tags : [ "raspberry", "win10" ] 
---
{% include JB/setup %}

参考 [How-To: Install Windows 10 IoT on the Raspberry Pi](How-To: Install Windows 10 IoT on the Raspberry Pi)，下载 ffu2img.py

下载 [Download RTM Release for Raspberry Pi 2](http://ms-iot.github.io/content/en-US/Downloads.htm)

解压iso，获取msi文件，双击安装。

开始菜单找到安装的目录，找到flash.ffu

python ffu2img.py flash.ffu 将flash.ffu转换成flash.img

下载 [win32diskimager](http://sourceforge.net/projects/win32diskimager/)

将flash.img刻录到sd卡中
