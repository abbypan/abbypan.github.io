---
layout: post
category: tech
title:  "RFC: RPKI & BGPsec"
tagline: ""
tags: [ "security", "bgp", "rpki", "rfc" ]
---
{% include JB/setup %}

* TOC
{:toc}

# RFC4272 : BGP Security Vulnerabilities Analysis

# RFC6480 : RPKI

包含3部分：Resource Public Key Infrastructure(RPKI)，ROA 对routing objects签名，distributed repository system存放PKI objects和ROA

IANA / RIR (Regional Internet Registry) / NIR (National Internet Registry) / LIR (Local Internet Registry) 分发地址

ISP基本上可看所是LIR

Certification Authority (CA) Certificates: 用于证明resource holder确实拥有该AS以及AS下辖的IP prefix。一个CA不能为其下属的两个不同实体签发相同名称的证书。

End-Entity (EE) Certificates: 每个EE只用于签发一个object，与ROA/manifests打包使用，一起撤销，同生同灭。由于只用于签名验证，也不需复杂的私钥存储管理之类。

Trust Anchors (TA): 每个 relying party (RP) 需要选择其 trust anchors (TAs) 做为PKI信任的起始。RP可以选择建立并管理自身的TAs，因为它自己也可以多层次分发资源。

## ROA

Route Origination Authorizations (ROA): 资源拥有者认证了，某个AS拥有某些prefix。一个ROA里只有一个AS。BGPsec基于此验证源路由。ROA随EE生成，随EE撤销。

示例见Figure 1，

RIR, CA -> ISP, CA -> ISP, EE -> ROA

NIR, CA -> ISP, CA -> ISP, EE -> ROA

## Repositories

存放CA, CRLs, manifests, ROA

支持外部pull上述数据

注意数据时效性，数据更删等关键操作的访问控制

一般来说，Registry的RP含有用其CA签发的所有CA，EE，CRLs, manifests数据，LIRs/ISPs的RP里还有ROAs.

每个Certificate有其对应的URI，层次指针示例见Figure 2。假设Cert A签发了Cert B/Cert C。则Cert A中的Subject Information Access(SIA)指向A的Responitory Publication Directory，在该Directory中包含了Cert B/Cert C。并且，Cert B/Cert C中的 Authority Information Access(AIA)指向Cert A, Cert B/Cert C中的CRL Distribution Points(CRLDP)指向A的CRL。

通过这种SIA/AIA层次结构URI指针的路径保持稳定性，当某个CA certificate is reissued **with the same public key**，下面的certificates不用再重新签发一次。当CA certificate的key更新时，也只要随之更新该certificate直接签发的对象，而不用签发整个下级子树。

RP数据可用rsync增量更新

## Manifests

manifest里存的是当前Repositories里的signed object list，即certificate/CRL/ROA之类每个object的filename及hash

manifest本身也要被对应的certificate签名

ROA的manifest生存期与EE certificate一致

manifest内容包含：编号，签发时间，预计下次签发时间，<filename, hash>的列表

## Local Cache Maintenance

RP要获取相关certificates, manifests, CRLs

验证manifest签名，检查失效时间

验证manifest中的CA, CRLs

验证EE

## Common Operations

注意resource holder **不能** 对多个CA certificates配置相同的public key

由于subject name由上级issuer指定，那么同一个subject在不同上级issuers签发的certificates里会被指定为不同的subject name

resource holders管理ROA的原则是，make before break，因为invalid后果可能严重

### multi-homed subscribers

如果一个subscriber接入了多个上级ISP

那么该subscriber最好申请一个专用AS号。一种方案是由primary ISP签发CA certificate，然后subscriber签发ROA。另一种方案是由primary ISP签发ROA，注意其他ISP提供的prefix也在这个ROA里一起签发。

没有专用AS号，就只能各个ISP各签一个ROA，不推荐。

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

# RFC6810 : The RPKI to Router Protocol 

Local Cache 周期性的获取 Global RPKI 数据

Router 从一个或多个 Cache 获取相关 RPKI 数据

## serial number

Router 与　Cache 之间，增量更新是基于Serial Number的比对

Cache 更新Serial Number之后，会给当前连接的所有router发一个Notify，但并非强制要求router立即更新

由于certificate，roa的有效性依赖于时间，还需要1小时的容忍时间差

## session id

cache 与 router 传输数据的 Session ID必须一致。如果不一致，回退，重置。

如果cache发现router复用了旧session id：如果 serial number已经差很多，cache reset；如果serial number差不多，cache response

如果router发现cache提供的内容与自身不一致，也会reset session

如果router发现cache response内容与当前自身状态一致，则可以等time period正常更新

## protocol message type

根据PDU type区分

Serial Notify: 通知有更新

Serial Query: 询问cache是否有更新

Reset Query: 重置，获取全量数据

Cache Response: 增量/全量更新内容，主要看serial number

IPv4 Prefix:  as, ipv4 prefix, prefix length, max prefix length

IPv6 Prefix:  as, ipv6 prefix, prefix length, max prefix length

End of Data: 标识一次session的结束

Cache Reset: cache知会router，表示不支持增量更新；router可以选择Reset Query，或切换cache源

Error Report

## protocol sequences

原文 sec 6

## security 

cache validation 有效性验证

cache peer identification 双向身份认证

transport security 传输安全，TCP-AO, SSHv2, TCP MD5, IPsec。。。

## IANA

rpki-rtr

rpki-rtr-tls


# RFC6811 : BGP Prefix Origin Validation

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

# RFC 7132 : Threat Model for BGP Path Security

PKI : address space holder 拥有该前缀

ROA : 前缀拥有者确认，某个AS被授权该前缀

注意BGP路由以AS为核心

INRs ( Internet Number Resources ) : IPv4 / IPv6 address space and ASNs

Network Operator 可能为调整路由，到对其自身更为经济的线路，而这个调整可能对其他相关方不是一件好事

repository system 是 RPKI 生效的关键所在，数据可用性，及时更新，稳定性。。。

如果错误在CA自身发生，则外部无法确定该错误，因为CA是下属节点的授权起点。而其下属的受灾户，则会迅速发现。。。

如果CA为overlapping INRs签名，则RPs也无法确认哪个是错误的重复分配。证书合法，不代表内容正确。。。

这篇比较话唠，中间多数可以略读，不影响问题理解

# RFC 7353 : Security Requirements for BGP Path Validation

这篇属于列流水账风格，知道了的用不着看，不知道的也搞不清楚场景

除AS_PATH之外的BGP attributes只应用于本地

数据面可能不按控制面提供的path走

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
