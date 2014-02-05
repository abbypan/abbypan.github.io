---
layout: post
category : tech
title:  "ipod classic"
tagline: ""
tags : ["ipod", "apple"] 
---
{% include JB/setup %}

## 硬盘坏道修复

报错：ipod内显示0kb可用，连接itunes检测到一个损坏的ipod

参考：[iPod classic 出现坏道的解决办法之分区](http://www.douban.com/group/topic/45423939/)

先在itunes点恢复ipod

menu + select 重启，出现白苹果， play + select 进入 disk 模式

用easeus partition magic 检测坏道

绕过坏道，新建一个fat32分区（只能有一个），设为 primary 分区，簇大小16kb，格式化

menu + select 重启

## 同步歌曲

[sharepod](http://www.getsharepod.com/)
