---
layout: post
category: tech
title:  "Google Pixel4 支持电信"
tagline: ""
tags: [ "pixel" ] 
---
{% include JB/setup %}

* TOC
{:toc}

# 参考

[Pixel 4刷机&常见问题指南](https://blog.csdn.net/weixin_45472158/article/details/113461883)

[Pixel 4 XL刷入Magisk、Root](https://sspai.com/post/57923)

[Google Pixel 4XL线刷固件、刷入Magisk面具进行root、解锁雷达和电信 Volte全记录](https://www.kejiwanjia.com/jiaocheng/102516.html)

# 进入fastboot

Pixel4 已解bootloader。

关机，重启时长按 电源+音量减 进入fastboot模式。

将手机usb连接到pc。

# PC线刷固件

线刷在 [Factory Images for Nexus and Pixel Devices](https://developers.google.com/android/images) 下载 Pixel4 的full ota image，例如 flame-tp1a.221005.002-factory-f91d46b5.zip 。

解压已下载的zip文件，执行 flash-all

刷入官方固件。

# 安装Magisk

在 [Magisk](https://github.com/topjohnwu/Magisk/) 下载 Magisk 的apk，安装到手机。

从full ota image固件包中提取 boot.img，放入手机。

在手机上运行Magisk，点击“安装” -> “选择并修补一个文件” -> 选中boot.img -> 修补之后获得一个新文件，假设新文件名是 bootMagiskPatched.img 。

将bootMagiskPatched.img提取到PC。

关机，重启时长按 电源+音量减 进入fastboot模式。

fastboot flash boot bootMagiskPatched.img。

刷入Magisk。

# 刷入Magisk模块

下载模块对应的zip文件到手机。

在手机上运行Magisk，点击“模块”->“从本地安装”->选中对应模块的zip文件进行安装。

[电信：Pixel2019-ChinaEnabler-by-Sun_Dream.zip]()

[雷达：EnableSoli](https://github.com/demj1206170/EnableSoli)

[riru-core](https://github.com/Magisk-Modules-Repo/riru-core)

[Riru-LocationReportEnabler](https://github.com/RikkaApps/Riru-LocationReportEnabler)

