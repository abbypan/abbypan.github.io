---
layout: post
category : perl
title:  "XML::Simple"
tagline: "解析文本"
tags : ["perl", "cpan", "xml" ] 
---
{% include JB/setup %}

## 多进程调用 XML::Simple 解析 xml 时提示ntdll.dll异常退出

用Pallel::ForkManager 多进程调用 XML::Simple 解析 xml

执行过2-3轮之后总是提示 ntdll.dll 异常，然后程序崩溃

换用 Web::Scraper 解析 xml 就ok了 
