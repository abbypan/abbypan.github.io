---
layout: post
category : tech
title:  "Windows Phone : lumia 822"
tagline: ""
tags : [ "lumia", "wp8" ] 
---
{% include JB/setup %}

设置，刷机、发短信、上网、切换软件市场、视频播放等等

## nokia wp8 设备刷机
http://www.wpxap.com/thread-538832-1-1.html

## nokia wp8 设备降级刷机
http://www.coolxap.com/thread-157247-1-1.html

## 联通3g，186号段发短信

ROM 1532.2108.1244.0003 版本 能正常发短信

ROM 1532.5951.1250.1012 版本要把【语言设置成中文繁体、地区设置成香港】才能正常发短信


## 联通3g，186号段，sim卡

要用sim卡大卡剪卡才能上网，nano小卡不行

## 联通3g网络配置

设置 -> 手机网络 -> 添加internet接入点 -> 接入点 -> 3gnet

## 联通3g彩信配置

参考 http://zhidao.baidu.com/question/266253267.html


## 视频播放

lumia 目前支持播放的视频格式较少

要把rmvb之类的转成mp4啥的才能在wp8上看

视频转换的脚本（调用ffmpeg）：https://github.com/abbypan/misc/blob/master/x2mp4.pl

## 中文输入法

设置 -> 键盘 -> 添加

## 手机屏幕截图

电源键 + win开始键 

## 切换软件市场

设置 -> 语言+区域 -> 国家/地区 -> ...

注意，只有"国家/地区"换掉，其他各项仍保持"中文(简体)"不变

## wp8 听歌 快进

长按 下一首 的按钮

这坑爹的设计，吐槽一百遍啊一百遍 

## 升级gdr3 开发者预览

关闭节电模式

打开反馈

检查时间设置跟区域设置匹配，比如北京时间、区域设置为中国

参考：[GDR3尝鲜附带方法!!!](http://tieba.baidu.com/p/2650737949)

如果提示不能更新，就重启，多试几次
