---
layout: post
category : tech
title:  "取网页并解析数据 ：几种 web crawler 对比"
tagline: ""
tags : [ "curl", "wget", "lwp", "casperjs" ] 
---
{% include JB/setup %}

## 目前选择

取网页重点用casperjs，辅助用curl

解析网页数据用Web::Scraper，api设计的很简洁，解析函数写起来非常爽 
 
| 工具 | 优点 | 缺点 |
| ---- | ---- | ---- |
| [WWW::Mechanize::PhantomJS](https://metacpan.org/release/WWW-Mechanize-PhantomJS) | 支持JS | 没casperjs那么多封装好的函数
| casperjs | 支持JS | 有时crash，部分情况下click form跳不过去（[issues-49](https://github.com/n1k0/casperjs/issues/49#issuecomment-23147718)，windows下--ssl-ignore-errrors失效导致）
| wget / curl / LWP::Protocol::Net::Curl | 轻量级，支持https | 命令行拼装碰到参数多的时候有点烦，不支持JS
| LWP::UserAgent / WWW::Mechanize / HTTP::Tiny / HTTP::Lite | 相对轻量级，使用简单 | 不支持JS，https支持要另外装模块，有点麻烦
| WWW::Mechanize::Firefox | 支持JS | 要开firefox，多进程容易僵住
| Win32::IEAutomation | 简单，一路 get / click | 只能在windows下调ie用，有些链接像``onclick="javascript:xxxx()"``之类点了不动
