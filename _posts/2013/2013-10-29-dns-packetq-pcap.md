---
layout: post
category : tech
title:  "dns software: pcap 拆包"
tagline: ""
tags : [ "dns", "software" ] 
---
{% include JB/setup %}

# 用PacketQ解析dns查询的pcap包

- [PacketQ](https://github.com/dotse/PacketQ)
- [PacketQ: SQL queries on DNS pcap files](http://jpmens.net/2011/05/23/packetq-sql-queries-on-dns-pcap-files/)
- [Abusing  Resources to Process 7TB of PCAP Data](https://indico.dns-oarc.net//getFile.py/access?contribId=16&sessionId=1&resId=3&materialId=slides&confId=1)

号称PacketQ比tshark快很多，嗯，可以试试

# 用tshark解析dns pcap数据包

1000多个协议的参数：[Display Filter Reference](https://www.wireshark.org/docs/dfref/)

dns协议的参数：[Display Filter Reference: Domain Name Service](https://www.wireshark.org/docs/dfref/d/dns.html)

修复损坏的pcap：[pcapfix](http://f00l.de/pcapfix/)

{% highlight bash %}
tshark -r .\test.cap -E 'separator=;' -T fields -e frame.time -e ip.src -e ip.dst -e dns.flags.opcode -e dns.qry.name -e dns.qry.type -e dns.flags.rcode -e dns.flags.response -e dns.flags.truncated -e dns.resp.name -e dns.resp.class -e dns.resp.type -e dns.resp.ttl -e dns.a -e dns.cname -e dns.ns -e dns.aaaa
{% endhighlight %}
