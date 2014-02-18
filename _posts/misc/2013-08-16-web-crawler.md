---
layout: post
category : tech
title:  "取网页并解析数据 ：几种 web crawler 对比"
tagline: ""
tags : ["curl", "wget", "lwp", "casperjs" ] 
---
{% include JB/setup %}

## 目前选择

取网页重点用casperjs，辅助用curl

解析网页数据用Web::Scraper，api设计的很简洁，解析函数写起来非常爽 
 
## 用过几种取网页的工具

### wget / curl
优点：轻量级，支持https

缺点：命令行拼装碰到参数多的时候有点烦，不支持JS

注：curl有perl模块LWP::Protocol::Net::Curl可以调用，类似LWP

### LWP::UserAgent / WWW::Mechanize / HTTP::Tiny / HTTP::Lite
优点：相对轻量级，使用简单

缺点：不支持JS，https支持要另外装模块，有点麻烦

### WWW::Mechanize::Firefox
优点：支持JS

缺点：要开firefox，多进程容易僵住

### Win32::IEAutomation

优点：简单，一路 get / click

缺点：只能在windows下调ie用，有些链接像 onclick="javascript:xxxx()"之类点了不动

### casperjs
优点：支持JS

缺点：有时crash，部分情况下click form跳不过去（看这个 https://github.com/n1k0/casperjs/issues/49#issuecomment-23147718 bug report，windows下--ssl-ignore-errrors失效导致）
