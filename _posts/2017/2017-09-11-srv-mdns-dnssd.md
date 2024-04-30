---
layout: post
category: dns
title:  "SRV & MDNS & DNS-SD & Multicast Discovery Proxy"
tagline: ""
tags: [ "dns", "srv", "mdns", "dns-sd" ] 
---
{% include JB/setup %}

* TOC
{:toc}

# RFC2782 SRV

DNS的SRV记录，用于查询指定域是否提供某些通用服务，以及服务的地址

_Service._Proto.Name TTL Class SRV Priority Weight Port Target

例如 _ldap._tcp.example.com

# RFC6762 mdns ( Multicast DNS )

本地域：.local 

组播地址：224.0.0.251:5353

本地节点zero-config特定的DNS，自己起个名称啥的（不能冲突, any）

节点向组播地址通报自身local域名及IP地址

节点向组播地址查询某个local域名的IP地址

# RFC6763 DNS-SD ( DNS-Based Service Discovery )

参考： [DNS Service Discovery (DNS-SD)](http://www.dns-sd.org/)

如果1楼的人查询 _ipp._tcp.example.com. 的SRV记录，随机选了一个7楼的打印机，显然是不合适的

因此，接着SRV记录的思路，加入服务实例的标识

先查询 _ipp._tcp.example.com. 的PTR记录，得到一堆服务实例域名的SRV信息

Service Instance Name = <Instance> . <Service> . <Domain>

然后再选取其中1个实例域名，查询其TXT记录（此时还能支持一些key-value属性对）

# Discovery Proxy for Multicast DNS-Based Service Discovery

[Discovery Proxy for Multicast DNS-Based Service Discovery](https://tools.ietf.org/html/draft-cheshire-dnssd-hybrid)

dns-sd同时支持组播与单播。 例如apple用dns-sd组播查询，与mdns结合，可以自动获取本地服务实例的端口及IP地址信息。

但是由于mdns只支持本地组播，无法处理多局域网的本地服务发现。

hybrid方案是用Multicast Discovery Proxy，在各本地链路仍是mdns，但是不同链路有不同的Unicast DNS namespace。

这个Multicast Discovery Proxy可以用VLAN trunk port模式出现在各局域网链路。。。

client同时发组播跟单播查Domain Enumeration的PTR记录：

1) 如果应答里给了Unicast DNS name: example.com，那么client就单播再查example.com下面的PTR

    b._dns-sd._udp.example.com.    PTR   Building 1.example.com.
                                          PTR   Building 2.example.com.
                                          PTR   Building 3.example.com.
                                          PTR   Building 4.example.com.

再用该PTR记录查SRV

    My Printer._ipp._tcp.Building 1.example.com.
                                  SRV 0 0 631 prnt.bldg1.example.com.
    prnt.bldg1.example.com.       A   203.0.113.2

2) client 同时发 .local 域下的组播查询

    My Printer._ipp._tcp.local. SRV 0 0 631 prnt.local.
    prnt.local.                 A   203.0.113.2

最终可兼用两者返回结果。

# draft : DNS Name Autoconfiguration for Internet of Things Devices

[DNS Name Autoconfiguration for Internet of Things Devices](https://tools.ietf.org/html/draft-jeong-ipwave-iot-dns-autoconf-01)

https://datatracker.ietf.org/meeting/94/materials/slides-94-6man-1/

https://www.ietf.org/proceedings/91/slides/slides-91-dnssd-6.pdf

https://www.ietf.org/proceedings/91/slides/slides-91-homenet-4.pdf

想省掉物联网设备初始化DNS配置的过程，直接自动注册名称

    unique_id + vendor_device_model + device_category + domain_suffix (e.g., .home) 

在 Node Information Protocol 及 DNS Dynamic Update 的基础上实现

这个号称跟mdns场景不同，主要因为mdns是局域网场景，而dnsna可以支持公网IPv6地址

个人觉得不同点主要在于，mdns是在节点上同时实现了轻量级的server/client收发广播包，而dnsna是通过ipv6 zero-config先找到本地局域网DNS然后进行自动化注册登记

名称的自动生成方式其实也可以参考oid/ons/handle等协议

远程控制家庭物联网设备，必然通过网关。因此，局域网地址/ipv6公网地址在该场景下，区别不会非常大（同样都要开放监听端口接收命令）

# RFC8882:  DNS-Based Service Discovery (DNS-SD) Privacy and Security Requirements

dnssd over mdns 不可避免的会泄漏某些信息。

核心是：是否泄漏identity信息、与business/social关联的信息(linkable identifiers)，client interest 等等

authenticity, integrity, freshness, confidentiality

dicitionary attack, ddos, sender impersonation, sender deniability

快稳省

信息锚点：pki, tofu, pake

