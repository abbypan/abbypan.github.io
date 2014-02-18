---
layout: post
category : tech
title:  "Pro DNS and BIND"
tagline: "笔记"
tags : ["dns", "bind" ] 
---
{% include JB/setup %}

## Pro DNS and Bind 10

### chap 3

迭代查询可能有几种返回：
- 域名的cname记录，需要标识是权威应答还是缓存应答
- 域名或主机不存在NXDOMAIN，包括CNAME到一个不存在主机的情况
- 出现临时错误，例如网络故障等
- referral应答，给出一个更加靠近权威DNS的ns记录

最好只有单个IP的PTR指向mail域名，否则可能会丢信。而不是单个IP的PTR指向多个域名。
两种Dynamic DNS：
- 允许从外部源实时更新zone RRs，而不中断服务（无法动态新增或删除一个域名/域；已存在域名的RR，除SOA之外，都可以被增/删/改）
- 从数据库读取zone RRs做解析，数据可以动态更新（BIND-DLZ、PowerDNS、BIND10；域名/域可以动态增/删/改，但是查询性能较差）

### 附录

附录A：一些域名的FAQ

附录B：DNS的RFC列表，很长，重点看过的几份：
- RFC1034/1035/2181 DNS介绍，基础必看
- RFC2308 否定缓存，写的挺好
- RFC3833 威胁分析，关键资料
- RFC4592 泛域名，感觉不错
- RFC4033/4034/4035 讲DNSSEC， 这几份读的很烦躁


## pro dns and bind 9

### CHAPTER 1

RFC基础定义：1034，1035

根 -> 顶级域TLD -> 二级域SLD

gTLD : .COM , .EDU, .NET 之类，通用

ccTLD: .US, .CN之类，国家

ICANN管根，将gTLD分给一些注册局registry管，将ccTLD分给各国管

有些注册局同时也是注册商registrar，例如verisign管.com，同时也给人提供域名注册服务

TLD的server配置由注册局管理，注册商可以向注册局申请修改记录

stub resolver : 一般是指操作系统内置的解析器

glue recode ：指向下一级NS的记录，一般是NS域名对应的A记录

dns server软件：bind，nsd，。。。


### CHAPTER 2

RFC 1912 推荐 ZONE FILE里 $TTL > 1day ，一般默认是2天

@ 表示默认域名串，即 $ORIGIN

NS、MX记录的取值必须是个FQDN，也就是最后有一个点

如 果example.com.的一个ns记录是外部域名ns2.example.net.，那么ns2.example.net.上必须有 example.com.的zone file，或者是example.com.的slave server。如果没有，就会出错，lame delegation，也就是说，NS记录被配置到无法给出权威回答的server。

多层CNAME不大好

如果一个域名是MX或NS指定的域名，就不要再配CNAME了，直接配A记录，RFC1034说的

反垃圾邮件的SPF会用TXT记录登记信息


### Chapter 3
BIND 根据 RTT 选择查询的NAME SERVER，还会参考ROUND ROBIN

stub resolver 是不支持迭代查询的；也就是说，PC上配的name server要支持递归查询，不然本机的resovler碰到迭代的应答就傻掉了

.IN-ADDR.ARPA  域用于IP反查域名

PTR的配置文件中，RR取值必须为FQDN，以 . 结尾

邮箱服务的MX域名得配对应的PTR，让一些邮箱软件反查

.ARPA 是ICANN/IANA在管（划IP段）；分到各个州就是RIR( Regional Internet Registries)，例如APNIC；再分到LIR(Local Internet Registry)或NIR(National Internet Registry)，各国运营商再各自划段

域配置的全量传送AXFR (tcp 53)，增量传送IXFR(tcp 53)，更新通知NOTIFY

slave收到NOTIFY的通知，会去问master的SOA，如果SOA的serial number比当前的记录大，就会发起AXFR或IXFR请求

DDNS(Dynamic DNS) 允许在server执行时从外界动态更新域的RR配置；不过没法添加或删除一个域。

一般外界更新域配置的时候，会加个密啥的，最常用的就是TSIG(RFC 2845)/TKEY(RFC 2930)，bind里的nsupdate就是ddns工具

如果域配置用数据库存取，就可以动态添加或删除一个域了，相关软件：BIND-DLZ、PowerDNS

DNS安全：

![dns_security_overview](/assets/posts/dns_security_overview.png)

zone file本身的安全

动态更新：限源IP，加密&认证 TSIS SIG(0)

zone transfer：限源IP，加密&认证 TSIS SIG(0)

查询：缓存中毒，数据篡改 => DNSSEC

本地resolver查询：缓存中毒，数据篡改，本地IP欺骗 => DNSSEC，SSL/TLS(用于resolver到local dns)


### Chapter 4

slave server : 总是返回该server上的域的权威回答

cache server ： 只有从master / slave server 刚刚问过来的回答才置为authoritative，从缓存搞出来的就标为no authoritative

如果一个server支持cache，那么它就必须支持recursive qurey

本地只用于cache的local dns，一般是用于向PC端的stub resolver提供应答，有时也称为proxy server，forwarding server；总是把请求转发给其他dns，自己把应答缓存起来

Stealth Name Server(或DMZ name server、split name server)，不让外界看到的name server，bind的view配置可以支持这种场景，区分内网外网配置 

 
### Chapter 5
ip地址分配:  ICANN/IANA –> RIR –> NIR –> LIR –> END USER

IPV6 地址:   global routing prefix (48 bit) +  subnet id (16 bit) + interface id (64 bit)

global routing prefix :   保留位 (3 bit) + TLA id (13 bit) + sub-tla (13 bit) + nla (19 bit)

TLA ID、sub-tla 是IANA给RIR(例如APNIC之类)分配的

nla 是RIR给下一层组织分配的，例如NIR、LIR

AAAA用于正向查询，IP6.ARPA地址段用于PTR反向查IPV6地址；A6用于正向查询，DNAME用于反向查询；未来用A6 + DNAME

AAAA形式的反向查询链太长了


### chapter 6   
bind 安装

### chapter 7  
bind 配置

### chapter 8  高级bind配置

example.com中切出一个子域us.example.com，则在example.com中要指定us.example.com的NS：

    假设为ns3.us.example.com(在example.com内)，则example.com的zone file中必须配上ns3.us.example.com的A记录或AAAA记录，这个称为glue record；不然查起来会无限循环

    假设为ns1.example.net(不在example.com内)，则example.com的zone file中，就不用配ns1.example.net的A记录或AAAA记录了，反正另外再去查一下IP就有了


优先选权值低的MX记录发邮件，低的发不了，才试高的；如果权值相同，一般就用round-robin负载均衡

一个RR SET里多个RR返回的顺序用rrset-order选项调

如果该域配置了泛域名(wildcards)，那么对不存在配置的域名会返回默认配置的RR，而不是返回NXDOMAIN。

注意，泛域名配置只对授权域有效；如果有子域已经切割出去，当前域的泛域名配置不会对该子域内的任何域名生效，详见RFC 1034。


### Chapter 9
nslookup、dig的用法

| dns包状态 | 作用 |
| --------- | ---- |
| qr(query response) |  这是个应答
| aa(authorative answer) | 应答来自权威
| rd(recursion desired) |  要求递归查询
| ra(recursion available) |  支持递归查询
| ad(authenticated data) | 应答来自一个可信的name server，且数据已被认证(dnssec)
| cd(check disabled) |  不想做任何验证(dnssec)
| do(dnssec ok) |  支持dnssec

| DNS server状态，RCODE | 详情 |
| --------------------- | ---- |
| NOERR | 正常 |
| FORMERR | 无法识别该查询 |
| SERVFAIL | 无法执行查询（可能是NS故障或配置，也可能是网络问题，总之就是查询失败） |
| NOTIMP | NS不支持指定的查询请求 |
| NXDOMAIN | 只能由权威给出，不存在此域名 |
| REFUSED | 拒绝 |
| YXDOMAIN |  域名不该存在，但它存在了（RFC 2136） |
| YXRRSET |   rrset不该存在，但它存在了（RFC 2136） |
| NXRRSET | rrset应该存在，但它不存在（RFC 2136） |
| NOTAUTH |  server不是该域的权威（RFC 2136） |
| NOTZONE | name不包含在该域内（RFC 2136） |


rndc远程管理bind，默认 tcp 953，要求 tsig加密

nsupdate 动态更新mater server的zone file

### Chapter 10

DNS 安全概览，每一步都可能出问题，orz…

dns_security_overview

TSIG：对称密钥，zone transfer加密传输，rfc 2845

SIG(0)：公钥认证，身份认证，加数据完整性，dynamic update时可以用，zone transfer时也可以用，rfc 2931

TKEY：交换对称密钥用的，支持Diffie-Hellman，gssapi(generic security services api)；rfc 2930要求用tsig、sig认证一下

Dynamic DNS(DDNS) ：RFC 3007, RFC 2136


### Chapter 11
DNSSEC rfc 4033,4034,4035  提供认证、完整性机制

DNSKEY RR 指定公钥

子域授权的NS，用DNSSEC认证，称为Delegated Signer RR (DS RR)

域认证的两种密钥：Zone Signing Key (ZSK)、Key Signing Key(KSK)

更新DS或name server的trusted anchor，都用KSK。更新RRSIG、DNSKEY可用KSK/ZSK

DNSSEC Lookaside Validation(DLV)是另一种链式认证方案，在父域zone file内可以不签名


### Chapter 12
 Bind 配置说明，好长……

### Chapter 13
zone file的说明，各种类型RR的详细介绍

### Chapter 14
bind库函数、resolver的库函数

### Chapter 15
DNS数据包结构 
