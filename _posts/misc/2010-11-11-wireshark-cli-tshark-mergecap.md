---
layout: post
category : tech
title:  "Wireshark 命令行抓包分析工具 tshark、mergecap等"
tagline: "packet"
tags : ["network", "packet", "wireshark", "tshark", "mergecap", "dumpcap", "capinfos", "editcap"] 
---
{% include JB/setup %}

## Wireshark 配了一些命令行工具

例如：tshark, dumpcap, capinfos, editcap, mergecap

使用教学见：
- http://www.euronet.nl/~sake/sharkfest08/
- [wireshark手册](http://www.wireshark.org/docs/man-pages/)
- [tshark filter手册](http://www.wireshark.org/docs/dfref/)
- [Cheat sheets: tcpdump and Wireshark](http://packetlife.net/blog/2008/oct/18/cheat-sheets-tcpdump-and-wireshark/)

## perl调用sharktools解析wireshark的pcap抓包的模块

[sharktools](https://github.com/armenb/sharktools) 提供了wireshark分析工具的调用接口

perl-sharktools 提供了从perl调用sharktools的接口

所以，perl-sharktools可以在perl中调用sharktools解析wireshark的pcap抓包的模块

代码示例：https://github.com/nanis/perl-sharktools/blob/master/Net-Sharktools/t/Net-Sharktools.t
