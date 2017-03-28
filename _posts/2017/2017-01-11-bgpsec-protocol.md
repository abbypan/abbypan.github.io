---
layout: post
category: tech
title:  "笔记：RPKI & BGPsec"
tagline: ""
tags: [ "security", "bgp", "rpki", "rfc" ]
---
{% include JB/setup %}

* TOC
{:toc}

# RFC6480 : RPKI

# RFC6482 : ROA

ROA: Route Origin Authorizations 路由源地址认证

注意每个ROA里只含一个AS

## ROA结构

ROA : { version, asID, ipAddrBlocks } 其中，ipAddrBlocks是ROAIPAddressFamily地址序列

ROAIPAddressFamily : { addressFamily, addresses } 其中，addresses是ROAIPAddress地址序列，Address Family Identifier(AFI)区分ipv4/ipv6

ROAIPAddress : { address, maxLength } 其中，address是IPAddress的bit string，maxLength为最大前缀长度，如果未指定maxLength，就限定只能为地址中的前缀长度

## ROA使用

用ROA验证路由宣告之前，需要事先验证ROA

注意ROA内容完整性校验支持用的是CMS: Crytopgraphic Message Syntax


# RFC6488 : Signed Object Template for RPKI

# RFC6810 : The RPKI/Router Protocol 

# RFC6811 : BGP Prifix Origin Validation

VRP: Validated ROA Payload

BGP speaker 定期 load validated objects到本地，其内容包括：IP，前缀长度，最大前缀长度，源AS

Prefix : IP + 前缀长度

Route: Prefix + AS_PATH

Covered： 一个Route prefix被一个VRP covered，当且仅当，二者prefix address相同(cidr计算后比对bit位)，且VRP prefix length <= Route prefix length

Matched: 一个Route prefix被一个VRP matched，当且仅当，Route prefix被VRP coverd，且 Route prefix length <= VRP prefix max length，且二者AS号相同

因此，BGP Route的三种状态：

Not Found: 找不到Cover该Route的VRP

Valid: 至少有一个VRP match该Route

Invalid: 至少有一个VRP cover该Route，但没有VRP match该Route

对于invalid状态的处理由本地策略决定

如果invalid就discard，那么保存roa、vrp的数据库就成为风险单点。攻击者伪装成valid source AS，发布伪造的BGP route announcement

# draft: BGPsec Protocol Specification

[BGPsec Protocol Specification](https://datatracker.ietf.org/doc/draft-ietf-sidr-bgpsec-protocol/)

## BGPsec_Path

用于源认证，处理路由劫持问题

BGPsec Capability format 的 dir 指示功能方向：0 收，1 发

一个前提是支持BGP multiprotocol扩展(rfc4760)

支持4字节AS号(rfc6793)

BGPsec_Path 与 AS_PATH 互不相容

BGPsec_Path 由两部分组成，Secure Path + Sig Blocks。Secure Path与AS_PATH类似。每个Sig Block中含有Secure Path中的每个AS的签名片段。为了向后兼容，可以有两个Sig Block。

### Secure Path

Secure Path的片段格式（见Fig5）：1字节 pCount，1字节Flags，4字节AS号

pCount标识对应签名覆盖的as个数

Flags 是最左一位记为Confed_Segment flag，取1则标识该bgp update message是发向与当前peer相同AS confederation的

### Sig Blocks

每个Signature Segment格式（见Fig7）：20字节SKI，2字节sig长度，最后是sig

SKI就是对应的RPKI证书

## 注意事项

BGPsec speaker为每个对端生成独立的BGPsec update message

如果BGPsec router收到消息含AS_Path，不能换成BGPsec；如果没有AS_PATH，例如来自内部对端节点的NLRI，则可以加BGPsec往外发

为减少DDoS风险，先过简单的语义合规检查，再做签名验证

注意BGPsec是保护BGP消息不受篡改、正确性，但是BGP消息本身的合理性是另一层面的问题
