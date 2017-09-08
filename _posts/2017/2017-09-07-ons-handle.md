---
layout: post
category: tech
title:  "OID-ORS & EPC-ONS & DOI-HANDLE"
tagline: ""
tags: [ "" ]
---
{% include JB/setup %}

* TOC
{:toc}

# Object Identifiers (OID)

## RFC 3061

    0 - ITU-T assigned
    1 - ISO assigned
    2 - Joint ISO/ITU-T assignment

层次化标识，支持各国家分区管理

    Human-readable notation: {joint-iso-itu-t(2) alerting(49) wmo(0) authority(0)}
    Dot notation: 2.49.0.0

## OID Resolution System (ORS)

[Information technology – Open systems interconnection – Object identifier resolution system](https://www.itu.int/rec/T-REC-X.672-201008-I/en)

各层次的ORS其实就是zone files里配置了ORS域的DNS各级权威，向ORS client最终返回NAPTR记录以标识获取信息的URL

各级ORS配置DNAME，以同时支持数字/字符串格式的域名，例如 joint-iso-itu-t.oid-res.org. IN DNAME 2.oid-res.org

# Electronic Product Code (EPC)  &  Object Naming Service (ONS)

RFC 5134

例子：urn:epc:id:sgtin:900100.0003456.1234567

注意，sub namespace支持自定义Validation mechanism，例如gtin可以自定义校验码生成规则

[ONS Version 2.0.1](https://www.gs1.org/epcis/epcis-ons/2-0-1)

## EPC转换成FQDN

GS1 Identification Key type 有多种数据类型，例如GTIN/GDTI/GSIN等等

这些数据类型可以转换成统一格式的Application Unique String (AUS)， ONS Client可以把AUS转换成FQDN域名格式用于ONS查询：

GTIN-13 061414132260 -> AUS : ||gtin|00614141322602  -> 0.0.6.2.2.3.1.4.1.4.1.6.0.gtin.gs1.id.onsepc.com

AUS到FQDN的转换大概规则：去掉  optional serial number / checksum digit ; 保留leading digit；reverse剩余的digit。

||gtin|00614141322602，去掉末位的2，提取首位0，剩余061414132260倒转为 062231414160，类型为 gtin，使用onsepc.com权威域，最终生成：

    0.0.6.2.2.3.1.4.1.4.1.6.0.gtin.gs1.id.onsepc.com

    0.  0.6.2.2.3.1.4.1.4.1.6.0.  gtin.gs1.id.  onsepc.com

## ONS查询

ONS Application -> ONS Client : Application扫瞄RFID之类获取信息，以 Global Trade Item Number (GTIN) 为例。

ONS Client -> DNS Recursive : ONS Client 将收到的 GTIN 最终转换成 FQDN 域名格式，发DNS查询其NAPTR记录

ONS Client -> ONS Application : 返回NAPTR记录

ONS Application -> EPC Information Services (EPCIS) server : 根据NAPTR记录给出的URL发起查询

    onsepc.com                  ONS maintained by GS1 Global
    ons.epcglobalcanada.org     Canadian ONS
    onsepc.fr                   French ONS
    ons.epcglobal.cn            Chinese ONS


# HANDLE

## DOI : digital object identifier

[doi手册](https://www.doi.org/doi_handbook/translations/chinese/doi_handbook/TOC.html)

DOI 号永久性地分配给一个对象，为该对象的当前信息提供可解析的持久性网络链接，这些当前信息包括该对象在互联网上的位置和资料等

doi:10.1000/123456 :  doi前缀 10.1000，doi后缀 123456

简单解析：解析到一个持久性URL；多重解析：支持解析出多条该对象的关联信息

使用HANDLE系统进行解析。支持代理服务器例如 http://doi.org/10.123/456

[9.1.3 运行本地 handle 服务](https://www.doi.org/doi_handbook/translations/chinese/doi_handbook/9_OperatingProcedures.html)

全球 Handle 注册中心 (GHR)。本地 handle 服务 (LHS)。

每个前缀均在 GHR 中创建。前缀包括了各个LHS的唯一标识信息，如 IP 地址和服务器公钥。GHR 使用这些信息确定向何处发送 DOI 号解析请求。

Handle System 使用私/公钥或密钥。DOI 号的创建权限位于前缀层，但每个 DOI 号都有自己的管理员（通常为前缀记录中的一个群组）。

## RFC 3650/3651/3652

Handle系统由CNRI开发

    <Handle> ::= <Handle Naming Authority> "/" <Handle Local Name>

以 ncstrl.vatech_cs/tr-93-35 为例，
- Client -> Global Handle Registry :  查询Local Handle Service信息 0.NA/ncstrl.vatech_cs
- Client -> ncstrl.vatech_cs 的 LHS : 查询handle信息 ncstrl.vatech_cs/tr-93-35

Client -> Handle服务器之间的通信支持：加密、认证、签名、隐私控制。支持 公钥+挑战码模式。

注意：缓存、代理服务器不做为Handle服务的一部分。

# UUID: Universally Unique Identifier

[ITU UUID](http://www.itu.int/en/ITU-T/asn1/Pages/UUID/uuids.aspx)

8-4-4-4-12 共32个16进制数，即128位，随机生成。

## 其他

## UID : Ubiquitous ID

[Specifications White Paper Related to Ubiquitous ID Center](http://www.uidcenter.org/spec#UID-00005)

Ubiquitous Code(ucode) 128bits: Version 4bits, Top Level Domain Code(TLD) 16bits, Class  Code(CC) 4bits,  Second  Level  Domain(SLD) Code,  and  Identification  Code  

按TLD/CC/SLD分层解析，最终根据SLD返回的cgi获取信息

## MCode: Mobile RFID Code

[RFID Code Structure and Tag Data Structure for Mobile RFID Services in Korea](http://www.ekaie.com/upload/dzqk/dianzixinxi/RFID%20code%20structure%20and%20tag%20data%20structure%20for%20mobile%20RFID.pdf)

128bits: TLC 12bits, Class 4bits, Company Code + Item Category Code + Item Code + Serial Code 112bit

解析与ORS类似，返回NAPTR指向的Object Directory Service (ODS) 服务地址

## CID

[中欧物联网标识白皮书2014](http://www.miit.gov.cn/n1146312/n1146909/n1146991/n1648536/c3489529/part/3489531.pdf)

通信标识符（ Communication Identifier ， CID ）是工信部电信研究院提出的一套面向公众用户的物联网标识命名管理系统。

## Ecode 

[中欧物联网标识白皮书2014](http://www.miit.gov.cn/n1146312/n1146909/n1146991/n1648536/c3489529/part/3489531.pdf)

物品统一编码（ Entity  Code ， Ecode ）是中国物品编码中心提出的用于标识物联网标识体系中任意物品的统一的、兼容的编码方案。
