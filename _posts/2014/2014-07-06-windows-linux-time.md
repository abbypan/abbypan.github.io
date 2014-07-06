---
layout: post
category : windows
title:  "windows & linux 双系统，重启之后，windows时间不同步"
tagline: "time"
tags : [ "windows", "linux", "time" ] 
---
{% include JB/setup %}

见：[How to fix incorrect time display in Windows when Dual Booting with Linux or OS X? ?](http://www.comptalks.com/how-to-fix-incorrect-time-display-in-Windows-when-dual-booting-with-Linux-or-OS-x/)

访问windows注册表``HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\TimeZoneInformation``

新建一个项``RealTimeIsUniversal``，类型为``dword(32)``，值为``1``

重启
