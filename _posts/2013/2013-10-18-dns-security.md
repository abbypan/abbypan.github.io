---
layout: post
category : tech
title:  "DNS Security : DDoS, Hijack, Configure Error, Management 安全事件" 
tagline: ""
tags : ["dns", "security"]
---
{% include JB/setup %}

* TOC
{:toc}

[DNS WARS](https://blog.apnic.net/2019/11/04/dns-wars/)

一些典型案例问题，一些分析点简述。。。

# DDoS 拒绝服务

DDoS的问题在于：伪造UDP查询，无身份认证；放大攻击，递归反射。。。

abor 2011年关于dns攻击的PPT [enhancing-cloud-resiliency-with-dns](http://www.arbornetworks.com/docman-component/doc_download/543-enhancing-cloud-resiliency-with-dns)，几个图挺不错的 

## 根: 2016.6 根服务

Anycast。。。

分区域部署根服务，限制攻击影响范围

## TLD: 2013.08.25 .CN国家顶级域

带宽，分散部署，重点来源IP区分服务，专用服务区。。。

分布式探测点的时延变化

常见IP到顶级域的访问记录变化　

热点短TTL域名二级权威的访问IP数变化

重点递归，热点域名平均时延变化，重启一次查询时延变化

## SLD: 2016.10 DYN第三方权威服务

云解析服务提供商往往托管着大量域名，因此针对此类服务的攻击影响范围放大效果更为显著

来自物联网(IoT)设施的攻击来源IP更为分散


重点递归服务器增强对热点互联网域名的应急缓存，在权威服务器查询失败时，向用户响应上一次正常应答，减缓攻击影响面

权威云解析服务增强防御带宽，对托管的重点互联网域名实施分区服务，并提升重点访问来源IP白名单的识别能力，以应对海量真实IP的攻击

物联网设备自身的安全防护，以及可访问域名的安全限制措施

## 递归: 2009.05 DNSPOD

第三方权威服务DDoS+暴风影音客户端傻瓜重试，导致权威停止服务，递归反射，大面积断网

权威服务安全防御能力

递归应急缓存能力，对servfail/timeout的处理策略

客户端做为分布式DDoS攻击源

## 递归: 2012.02 湖南电信DDoS事件

合法源IP的僵尸访问

递归扛，家用路由器限，安全终端防，联动

## 递归: 2014.12 国内递归反射DDoS事件

BCP38，近源处置

## 终端Stub: 2018 Mami篡改macOS的stub DNS及本地根证书 


[New MaMi Malware targets macOS systems and changes DNS settings](https://securityaffairs.co/wordpress/67709/malware/mami-malware-dns-changer.html)


# Hijack 劫持

没有DNSSEC, DNSCrypt, DNSCurve，又或Registrar失守，递归被骗，如何处治？

## 2010.01 百度NS事件

主动监测，Glue变更锁定，设法延长未过期NS的递归针对热点域名的有效时长

## 2014.01 根域劫持事件

劫持定位逻辑题，呵呵

解析路径：用户PC ->  ISP递归 / 公共递归 -> 各级权威（根 、TLD、二级权威）

终端：终端侧监测host表异常？

递归：影响覆盖递归地理分布？

递归：影响覆盖递归类型（公共、运营商、公司自建）？

二级权威：影响覆盖互联网业务域名分布？

TLD：不同TLD查询截断表现？

重点业务域名权威：同NS下，不同业务域名的解析表现？

递归侧重点业务域名记录：NS的TTL时序内，同一热点业务域名的解析表现？

收工

## 递归侧xxx域名A记录劫持

本地Forwarding Resolver劫持,替换钓鱼IP

本地网关设备劫持,替换热点域名IP,挣钱

运营商侧异常外部劫持,恶意识别

运营商侧广告劫持,省钱

运营商侧缓存劫持,挣钱

运营商篡改正常IP响应/轮换策略,进水

运营商侧本地IP劫持,更加进水

## 递归侧xxx域名MX记录劫持

邮箱安全

仅次于手机验证码安全

# Configure Error 配置错误

## 2011.05 www.qq.com事件

CNAME错误检测

## 2013.09 xxx域名NS抽风事件

Glue NS　与　权威NS 记录不一致

权威NS记录的A记录缺失

## 2016.09 朝鲜 .KP 区传递事件

运维配置ACL问题

## 运营商递归到权威路径servfail

网络质量,权威分配

# Management 管理权 

## 伊拉克 .IQ 国家顶级域被撤

http://netsec.ccert.edu.cn/duanhx/?p=1850

http://blog.sina.com.cn/s/blog_7110463b0102v75z.html

ICANN 多方共治, 兄弟们...

RFC7706 不存在那啥...

只有一张互联网...

# 协议缺陷

## referral

[The “Indefinitely” Delegating NameServers (iDNS) Attack](https://indico.dns-oarc.net/event/21/contributions/301/attachments/272/492/slides.pdf)
