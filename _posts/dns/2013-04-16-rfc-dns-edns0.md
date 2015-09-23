---
layout: post
category : tech
title:  "RFC 6891 : DNS  EDNS0"
tagline: "笔记"
tags : ["rfc", "dns", "edns0"] 
---
{% include JB/setup %}

扩展DNS，设置支持发送超过512字节的DNS UDP包

label type 头2位置 01 表示为扩展的label，后面6位则标记该label值

OPT pseudo-RR 一般放在查询包的additional段，要么就没有，要么就一个

OPT RR 的 type code 是41，对应 RDATA 格式是``{ OPTION-CODE, OPTION-LENGTH, OPTION-DATA }``

UDP PAYLOAD选多大，可以看看双方MTU，以太网环境1280也还行

应答方的最大支持udp payload在连续会话中最好不要变；开始发个空查询加上payload size的OPT RR确定最大payload，然后开始以此为payload参数进行真正的查询

不支持此扩展的应答方会返回RCODE NOTIMPL, FORMERR, or SERVFAIL，请求方cache这个不支持的信息直到TTL过期

支持这个buffer size指定会增大ddos攻击风险

注意：OPT RRs MUST NOT be cached,forwarded, or stored in or loaded from master files. 其实就是控制信息不缓存。

## 测试edns0

参考 [oarc-edns-test](https://www.dns-oarc.net/oarc/services/replysizetest)

$ dig @xxx.xxx.xxx.xxx +noall +comments +edns=0 yyy.com

$ dig @xxx.xxx.xxx.xxx +noall +comments +bufsize=1 yyy.com
