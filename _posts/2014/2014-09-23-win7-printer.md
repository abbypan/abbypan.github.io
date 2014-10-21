---
layout: post
category : tech
title:  "win7 : 安装打印机"
tagline: ""
tags : [ "windows", "printer" ] 
---
{% include JB/setup %}

提供 \\\\xxx.xxx.xxx.xxx 访问网络邻居的方式安装打印机

如果提示无法访问 \\\\ 路径，可以尝试获取打印机的IP地址（例如，在xp虚拟机中安装打印机，在备注或系统提供的信息栏中查看IP）

win7 -> 控制面板 -> 设备和打印机 -> 添加打印机 -> 添加网络打印机

-> 我需要的打印机不在列表中 ->  使用tcp/ip地址添加打印机

-> 输入IP地址 -> 下一步 -> ...
