---
layout: post
category : program
title:  "用 wireshark / tshark 分析 adobe flash 在线视频rtmp地址，用rtmpdump下载保存为flv文件"
tagline: "flv"
tags : [ "wireshark", "tshark", "adobe", "flash", "rtmp", "rtmpdump", "flv" ] 
---
{% include JB/setup %}

 
以曾斯琪FX视频为例： [720878-China-Zeng-Siqi-FX](http://www.gymnastike.org/coverage/251079-2013-World-Championships/video/720878-China-Zeng-Siqi-FX)

这个网站比较有意思，没有用f4m链接，而是用rtmp视频流。

swf有好几个，反编译看的头晕。

不爽之下决定直接上wireshark，小样，看你还藏！

## wireshark手动分析

先打开wireshark设置抓包，然后在浏览器中观看视频，视频开始播放之后，停止抓包

在wireshark抓包中找到视频连接、播放的指令：

![wireshark_rtmp](/assets/posts/wireshark_rtmp.png)

因此，此视频的RTMP信息为：
- 连接url： ``rtmp://96.7.248.111/ondemand?_fcs_vhost=cp76677.edgefcs.net``
- 播放路径path：``mp4:s/lyYmQyZjo3BEcsOVWgTlDdnVgcnuhXjG/DOcJ-FxaFrRg4gtDEwOmk2OjBrO6qGv_``

## rtmpdump 手动下载

rtmpdump下载地址：http://rtmpdump.mplayerhq.hu/

下载flv视频，保存为zsq.flv ：
``rtmpdump -r "rtmp://96.7.248.111/ondemand?_fcs_vhost=cp76677.edgefcs.net" -y "mp4:s/lyYmQyZjo3BEcsOVWgTlDdnVgcnuhXjG/DOcJ-FxaFrRg4gtDEwOmk2OjBrO6qGv_" -o zsq.flv``

## 通过tshark命令行抓包 + 调浏览器打开视频url + rtmpdump导出

脚本：[video_rtmpt_to_mp4](https://github.com/abbypan/misc/tree/master/video_rtmpt_to_mp4)

### tshark 抓包过滤 rtmp

tshark 命令行抓包，-i 4 指定网卡序号：
``tshark -i 4 -w a.cap``

tshark 从a.cap提取rtmp连接url：
``tshark -r "a.cap" -Y "rtmpt"|grep connect``

tshark 从a.cap提取播放路径：
``tshark -r "a.cap" -Y "rtmpt"|grep play``

吐槽：

这边rtmp视频流协议的关键字是"rtmpt"，之前直接用"rtmp"死活过滤不出来。

原因看这里：http://www.wireshark.org/docs/dfref/#section_r
- rtmp: Routing Table Maintenance Protocol (1.0.0 to 1.10.2, 8 fields)
- rtmpt: Real Time Messaging Protocol (1.0.0 to 1.10.2, 57 fields)

这就叫网络协议太多，尼玛4个字缩写都不够用了。 
