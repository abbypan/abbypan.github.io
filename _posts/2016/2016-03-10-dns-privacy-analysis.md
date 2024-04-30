---
layout: post
category: dns
title:  "DNS Privacy: 隐私方案分析"
tagline: ""
tags : [ "dns", "privacy", "security" ] 
---
{% include JB/setup %}

* toc
{:toc}

# 背景

最近集中分析了一下 dns privacy，内心觉得它的应用前景很可能类似 PGP。。。

Pretty Good Privacy

GNUPG

# 参考材料

[knell for dns](https://gnunet.org/sites/default/files/mcb-en.pdf)

[dprive problem](https://tools.ietf.org/html/draft-ietf-dprive-problem-statement-06)

[DNS privacy considerations](https://datatracker.ietf.org/doc/draft-bortzmeyer-dnsop-dns-privacy/)

[dns oarc 2016 ag](https://indico.dns-oarc.net/event/22/timetable/#all.detailed)

[DNS Privacy Implementa3on and Deployment](https://ccnso.icann.org/sites/default/files/file/field-file-attach/2017-04/presentation-dns-privacy-implementation-deployment-13mar17-en.pdf)

# 现行解析架构

根据DNS协议的分层设计，用户的DNS解析请求从用户终端的Stub 解析器发送到递归服务器，再由递归服务器向根、顶级域、二级及以下权威服务器发起迭代查询。该查询过程至少会涉及上述5个DNS节点的4条查询链路：

（1）	Stub解析器 -> 递归服务器

（2）	递归服务器 -> 根

（3）	递归服务器 -> 顶级域

（4）	递归服务器 -> 二级及以下权威

在查询链路上，如果节点双方采取DNS over TLS等对称加密或Cookie型认证方案，可以有效隐藏查询域名信息，但是无法规避中间人攻击的风险。针对DNS节点在上述查询链路的隐私风险保护，现行方案概要如下：

## Stub解析器（用户终端）

用户终端的Stub解析器向递归服务器发起查询，由于DNS默认采用UDP包明文发送查询应答数据包，用户内网广播及查询链路存在流量窃听的风险，而从用户侧的Stub解析器到递归服务器链路上存在中间人攻击的风险。

对于用户终端而言，基于公钥体系可行的信息隐藏方案是终端侧采用DNSCrypt方案，解决“Stub解析器 -> 递归服务器”的链路的窃听、中间人攻击的风险，但用户终端的访问兴趣对递归服务器而言则是透明可见的。针对递归服务器对用户侧的信息收集问题，用户终端可以采取多层IP代理、或者域名混杂查询等模式，部分隐藏真实IP地址或域名访问意图。

## 递归服务器（运营商递归服务器、公共递归服务器等）

多数个人用户默认采用运营商提供的递归DNS服务、或者采用Google Public DNS/Open DNS等公用递归DNS服务。因此，递归服务器做为连接用户终端以及权威服务器的关键节点，拥有互联网关键热点业务域名的访问动态信息。

递归服务器可以选择支持增强用户隐私保护功能，例如OpenDNS等公共递归支持响应DNS over TLS、DNSCrypt的查询请求。

递归服务器可以选择向权威隐藏或展示部分DNS信息。Google的“Client Subnet in DNS Requests”方案在优化本地用户访问的同时，也在一定程度上泄漏了用户所在的网络地址范围。AFNIC的“DNS query name minimization”方案则对根、顶级域部分隐藏了二级及以下域名的热点访问业务域名信息，但是由于全球递归服务器的广泛性，除非各大运营商递归服务器、重点开放递归服务器全部支持该方案，否则实际隐私保护效果有限。此外，如果递归服务器向根、顶级域、二级及以下域名权威采用DNS over TLS的加密查询，可有效防范骨干节点的旁路透明监听，避免明文插入型的域名劫持风险。

## 根

根服务器是迭代查询的起点，现行解析架构下可以掌握绝大部分全球热点互联网域名信息。Google的“Root Servers by Running One on Loopback”方案直接在递归侧载入根区文件信息，如果各大运营商递归服务器、重点开放递归服务器全部支持该方案，则根服务器所能掌握的下级域名信息将大大减少，能够有效实现对跨境查询根服务域名信息隐藏。

## 顶级域（CN、COM、NET等）

重点顶级域拥有百万级到亿级的注册二级域名，由于COM/NET的先发优势，全球互联网重点企业例如Google、微软、IBM等多数在COM/NET注册关键业务域名。由于互联网业务流量具有长尾效应，顶级域掌握的信息质量主要由该域下的业务热度决定。

ICANN的NewG(新顶级域)策略能够增加某些特殊应用类的域名注册，但是短期内能够掌握互联网动态变化的顶级域仍集中在传统的热点顶级域。

递归内部的多层转发，或者域名混杂查询可以在一定程度上隐藏部分域名的真实查询比例分布。

## 二级及以下域名权威

互联网存在第三方提供的二级及以下域名权威解析服务（免费或收费），该服务提供商完全掌握了已托管的互联网域名的所有业务IP配置信息，因此重点互联网业务出于业务保密的考虑，往往拥有自行搭建的权威服务器。

二级及以下域名权威可以在向递归服务器返回权威应答的同时，设法延长NS记录的TTL时间，减少递归向上层顶级域权威查询的信息泄漏，应对注册商记录异常的风险。

#  现行DNS解析架构下的隐私方案

现行DNS解析架构下，DNS隐私重构方案的核心基本围绕递归服务器展开。重点递归服务器覆盖的用户范围，以及对加密、认证、数据隐藏的支持程度，决定了整体隐私保护的强度。

用户侧到递归的链路隐私问题可以通过DNSCrypt方案得到相对合理的解决。递归到上层权威的隐私问题，除了已有的域名层次最小化方案，还可以参考TTL调整主动热点域名查询、全局域名的混杂查询及主动缓存方案，隐藏热点域名信息。顶级域名权威服务查询源IP、二级域名均表现出明显的长尾特征，此时，如果递归侧根据历史缓存信息进行主动查询，则此时域名查询是相对均衡的分布，而非自然的业务访问特征与TTL自然过期的长尾表现。

例如，构建一种递归针对顶级域的信息隐藏方案：

（1）	递归接收来自客户端的域名查询请求

（2）	递归记录一段时间内（例如1~5天）所有来自客户端查询的二级域名NS信息

（3）	递归以预先配置的时间间隔（例如1小时~6小时）定期主动向顶级域查询二级域名的NS信息

（4）	递归根据已获取的二级域名NS信息更新自身缓存

理论上的好处：能够有效避免顶级域对某些重点递归的业务访问的热点域名以及TTL进行特征学习，从而进一步减少该递归服务器的某些特殊长尾域名的隐私泄露风险。能够在现有的 DNS 解析架构下进行，减少递归向外部顶级域的信息泄露。

产品上不实用的原因：适用于某些个特殊递归，绝大部分递归没有义务与动机去部署。

# namecoin 新型域名注册解析架构

基于bitcoin思路的Namecoin域名服务。

Namecoin是一种特殊的P2P去中心化的<key, value>信息对的注册和传输网络，其主要优势在于解析网络的节点平等，信息发布拥有较高的自由度。在Namecoin对等网络下，下级域的所有者不再受上级权威的制约，上级权威通过clientHold、删除子域等手段恶意停止某个子域的解析的手段无法成功。此外，Namecoin网络中域名所有者也不再受域名注册商信息的制约，相比于传统域名注册信息管理体制下，域名所有者无法针对注册商系统内部错误进行主动性事先预防，有更大的自主管控优势。

由于Namecoin网络的节点拥有整个域名数据信息库，或者选择信任某个上级节点提供的域名数据。因此，传统的递归到上级权威查询链路的隐私泄漏风险不复存在，节点访问互联网业务所需的.bit域名解析能够收缩到网络内部，或节点可信任的子网内部通信。

Namecoin网络主要解决了域名解析信息隐藏的问题，但方案生效的前提在于域名在Namecoin网内注册使用。即使进行IP代理转发、域名混杂请求，用户侧向递归请求传统COM/NET等子域名的内容对于递归仍相对透明，存在某些溯源关联的路径依赖。与现实网络结合的用户侧DNS隐私保护增强，还需要递归侧热点域名的缓存信息有着更广泛的分发共享网络，类似于热点黄页信息预取支持。

# 用户查询域名信息隐藏方案

DNS本质上是一种查表型的信息服务，在传统层次型的DNS解析架构方案中，递归服务器掌握了最关键的用户域名访问信息。DNSCrypt方案仅解决了用户到递归的链路隐私问题，尽管用户可以通过混淆发包查询多个域名、或者代理查询方式进行部分隐藏，但是用户的真实域名访问兴趣仍可在递归日志中留存记录，存在某些溯源关联的路径依赖。

因此，与现实网络结合的用户侧DNS隐私保护增强，还需要递归侧热点域名的缓存信息有着更广泛的分发共享网络。

例如，构建一种用户查询域名信息隐藏方案：

## 递归主动参与热点域名信息分发

（1）	类似杀毒软件的病毒特征数据更新模式，递归服务器每分钟更新发布热点域名数据。

（2）	客户端运行独立的递归缓存更新软件，直接获取热点域名信息。此时，递归无法直接获知用户对热点互联网业务的访问兴趣。

## 客户端协作网络查询长尾域名

（1）	客户端接入P2P协作式域名查询网络，例如基于chord构建。

（2）	发起查询的客户端节点根据<TIMESTAMP，QNAME，QTYPE>生成唯一的key值。

（3）	查询节点在chord网络中根据key值定位到该时刻系统分发负责此项查询的对等目标节点、或节点集合。

（4）	如果对等目标节点没有该key值对应的dns应答缓存，则目标节点需要调用自身、或者相关邻居合作节点启动DNS查询，获取<TIMESTAMP，QNAME，QTYPE>的相关应答信息。

（5）	由于不同域名查询频度不同，需要进一步考虑该协作式查询网络节点负载均衡策略。此外，DNS应答往往随着地区运营商的不同返回智能解析结果，应答数据集中还可以加入<AREA, ISP>等辅助信息。

（6）	由于恶意节点加入的安全问题，需要综合多个对等节点提供的应答信息投票进行综合评估，或引入更严格的节点信誉度评分机制等等。

##  分析

理论上的好处：能够避免递归服务器对客户端的域名查询信息进行监测分析，从而规避“用户<->递归”层面的隐私泄漏问题。结合现有的 DNS 解析架构形成一个客户端协作网络，减少递归对于用户的集中式窥探可能。

产品上不实用的原因：配个DNS就能搞定的事，大部分人不会再去装一个专用client。


# Nowadays DNS architecture 

As hierarchical design in DNS protocol, dns queries are generated at stub by end-user, first send to recursive resolver, and then recursive  resolver send to authoritative severs such as Root, TLD, SLD.
There are 5 dns nodes and 4 query links:
* stub -> recursive resolver
* recursive resolver -> Root
* recursive resolver -> TLD
* recursive resolver -> SLD

If nodes use DNS over TLS、DNS Cookie to communicate with each other, then they can hide the dns query information from the query link, but still risk at MITM.

Nowadays DNS privacy protection technologies: 

## stub resolver (end-user)

stub resolver send clear text udp query to recursive resolver, there are eavesdrop and MITM attack risk on the link.

DNSCrypt can slove eavesdrop and MITM risk.

But recursive resolver can know all about the domain quries of each end-user. To avoid the domain queries interest gathered by recursive resolver, end-user can use ip proxy, mix-query to hide the truely ip address and visit domain interest.

## recursive resolver (public recursive, isp recursive)

most of end-users use isp recursive resolvers, or public recursive resolvers such as Google Public DNS/OpenDNS.

As a critical node between end-user and authoritative server, recursive resolver can know about realtime hot domain queries of internet business.

Recursive resolvers can support some privacy protection to end-user, such as DNS over TLD, DNSCrypt.

Recursive resolver can hide some information from authoritative server, or give some additional information to authoritative server. Google's "client subnet in dns requests" ECS option, leak the subnet of end-user. AFNIC's "DNS query name minimization" hide part of domain name from Root and TLD. But, DNS is globally deployed, the privacy protection is on a long road. If recursive resolver communicates to Root/TLD/SLD with DNS over TLS encrypt, then it can avoid the eavesdrop on the resolution path, and defense the tranditional domain hijack on clear text dns queries.

## Root

Root can know almost all hot domain queries of interest business. Google's "Root Servers by Running One on Loopback" directly run 

root zone on the recursive resolver, if top isp recursive resolver and most of public recursive resolvers enable "Root Loopback", 

SLD domain information leakage to Root will be dramatically decreased. recursive resolver can hide information from cross-national root instances successfully.

## TLD ( cn, com, net, ...)

top TLD contains billions of SLDs, the most important internet company like google, microsoft, ibm  registered their domain at .com/.net. As a long-tail flow, the information quality of TLD is decided by the importance of the business that has registered their domain.

ICANN NewG may disperse part of domain queries from com/net in the future.

recursive multi-forwarding, or domain mix-query can hide part of truely query distribution of domains.

## SLD

There are many free authoritative service for SLD, like cloudfare, godaddy, etc. The authoritative service provider can known all about the parked domain zone. 

Therefore, many important internet businesses run their own authoritative server.

When recuse the ns hijack, SLD authoritative server can try to lengthen the NS TTL return to recursive resolver, the mitigating the hijack influnence.

# A privacy proposal satisfied with Nowadays DNS architecture

recursive resolver is the most important node of dns privacy proposal. the user number of recursive resolver covered, the user privacy protection is influnenced by the support of encrypt, dnssec, query hiding on recursive resolver.

DNSCrypt can protect the query link from end-user to recursive resolver. qname minimization, adjust ttl of hot domain query, mix-domain query, prefetch hot domain, can partly hide recursive resolver to authoritative server. 

the query source IP, SLD are long-tail distribution at TLD. If recursive resolver make active prefetch to update history domain cache, then the distribution of domain query will be more even, different from the natural long-tail.

For example, recursive resolver want to hide from TLD:
- recursive resolver receives domain query from end-user
- recursive resolver saved all SLD NS of the domain queries
- recursive resolver send the SLD query to TLD in the history set periodlly
- recursive resolver update the cache

it can avoid TLD learning the hot-domain distribution of recursive resolver, avoid long-tail domain interest leak.

but this is an ideal proposal for special recursive, not realistic to all recursive.

## namecoin 

namecoin can prevent the tranditional clientHold or delete zone or Registrar misconfigured ns on the Root/TLD.

user can hide the domain queries by load namecoin cache.

another similar proposal can be :  recursive resolvers share their hot-domain queries and response in an share network,
user load the hot-domain cache by anonymous proxy or encrypt tunnel.

## hide end-user domain query proposal

In tranditional DNS architecture, recursive resolver can know all domain interest of end-user.

To improve user's privacy, recursive resolvers can build hot-domain cache share network.
- like virus database update, recursive update hot-domain data every minute.
- end-user run independent software to pull latest recursive cache.

recursive resolver can not directly know the domain interest of end-user.

## end-user domain query P2P network

- build a P2P collaborative domain query network, for example, based on chord.
- query node generated unique key by <TIMESTAMP, QNAME, QTYPE>
- query node send the key to assign the dest node
- dest node make dns query to build <TIMESTAMP, QNAME, QTYPE>'s response 
- consider about load balance and satisfied with geolocation, maybe add some <AREA, ISP> information.
- consider about evil node, compared with different nodes' response, or node credit rank.

## conclusion

the good part is improve user privacy, avoid the monitor of recursive resolver.

but it is not so realistic, because most people may not install a special dns software.
