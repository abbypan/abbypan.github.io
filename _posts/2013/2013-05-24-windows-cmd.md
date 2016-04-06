---
layout: post
category : tech
title:  "windows : cmd 控制台 字体"
tagline: "目录同步"
tags: [ "windows", "cmd", "font" ]
---
{% include JB/setup %}

参考：http://blog.csdn.net/arbel/article/details/7294407

假设系统已安装 Monaco 英文字体

直接在``HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Console\TrueTypeFont``

添加Monaco项（000），并把中文字体（936）修改成雅黑

![windows_cmd](/assets/posts/windows_cmd.png)

注册表

``HKEY_CURRENT_USER\Console``

``HKEY_CURRENT_USER\Console\Command Prompt``

``HKEY_CURRENT_USER\Console\%SystemRoot%_system32_cmd.exe``

调整字体配置，FontFamily 注意设成48，表示TrueType
