---
layout: post
category: dns
title:  "Wireshark 解析 DNS 数据包的细节"
tagline: "dns"
tags : ["wireshark", "dns", "drill", "dig" ] 
---
{% include JB/setup %}

这个是今天junjun总测试时发现的，记一下。

DNS域名压缩资料： DNS报文域名压缩规则 ,细节参考 RFC1035 中 4.1.4. Message compression

注意：包含指针的域名无须以字符 ``\0``结尾

当DNS应答包结尾域名包含指针，在结尾处误加了``\0``时：

![wireshark_dns_parse](/assets/posts/wireshark_dns_parse.png)

三个工具测试结果：

- dig：提示DNS应答包格式出错

- wireshark：读错误DNS应答包没有提示出错，原因在于Wireshark的DNS dissectors源码packet-dns.c，其中 dissect_dns_common 函数，没有校验最终指针offset cur_off是否指到数据包尾

- drill：读错误DNS应答包提示出错，并提示错误细节是Invalid compression pointer。在其源码wire2host.c中，错误标记为LDNS_STATUS_INVALID_POINTER

结论：drill比较靠谱，以后测试可以多用
