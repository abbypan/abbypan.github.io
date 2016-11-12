---
layout: post
category: tech
title:  "笔记 ：TLS 1.3 & TLS 1.2 Handshake & Resumption "
tagline: ""
tags: [ "tls", "crypt", ] 
---
{% include JB/setup %}

* TOC
{:toc}

# 参考

[An overview of TLS 1.3 and Q&A](https://blog.cloudflare.com/tls-1-3-overview-and-q-and-a/)

[Change the (S)Channel! Deconstructing the Microsoft TLS Session Resumption bug](https://blog.cloudflare.com/microsoft-tls-downgrade-schannel-bug/)

[RFC 5077: Transport Layer Security (TLS) Session Resumption without Server-Side State](https://tools.ietf.org/html/rfc5077#section-4)


下面以Diffle-Hellman为例

# 密钥生成

Client、Server 通过D-H协商生成的密钥为``预备主密钥(pre_master_secret)``，

然后，用pre_master_secret、ClientHello.random、ServerHello.random，可以生成48位的``主密钥(master_secret)``

见 [RFC 5246 : TLS 1.2 section 8.1](https://tools.ietf.org/html/rfc5246)

{% highlight bash %}
#PRF是伪随机生成函数，根据密钥、标识、种子生成随机序列
master_secret = PRF(pre_master_secret, "master secret",
                  ClientHello.random + ServerHello.random)
                  [0..47];
{% endhighlight %}

再根据主密钥生成TLS Record通信所需的密钥套件：对称加密的密钥、消息认证码密钥、CBC模式的IV

见[RFC 5246 : TLS 1.2 section 6.3](https://tools.ietf.org/html/rfc5246)

{% highlight bash %}
key_block = PRF(SecurityParameters.master_secret,
                      "key expansion",
                      SecurityParameters.server_random +
                      SecurityParameters.client_random);
{% endhighlight %}

# Handshake

## TLS 1.2 Handshake

(1) Client-> Server : ClientHello 

提供Client Random，Sessio ID, 支持的ciper suite

(2) Server -> Client : ServerHello 

ServerHello 提供Server Random, Session ID, 选择使用的cipher suite

Certificate 提供Server的证书

ServerKeyExchange 提供D-H 交换的 P, G, 以及Server在此次D-H交换的公钥

CertificateRequest 请求客户端证书（可以有）

(3) Client -> Server : ClientKeyExchange

ClientKeyExchange 提供Client在此次D-H交换的公钥

Certificate 提供客户端证书（可以有）

ChangeCipherSpec 切换密码（后续开始用Client/Server两边协商后、各自生成的、相同的、对称密钥等信息进行Record加密通信）

(4) Server -> Client :  ChangeCipherSpec

(5) Client -> Server :  

Handshake结束，后续可以开始正常的GET/POST/...

## TLS 1.3 Handshake

(1) Client -> Server : ClientHello

ClientHello的时候，Client一并提供它支持的所有cipher suites以及KeyExchange需要的信息(keyshare)，但是具体用哪种cipher，还是让Server端挑。

(2) Server -> Client : ServerHello

返回挑选的cipher suite，以及keyexchange相关信息(keyshare)

服务端证书、签名，等等

ChangeCipheSpec, 完成handshake

(3) Client -> Server ：

ChangeCipherSpec

Handshake结束，后续可以开始正常的GET/POST/...

## 笔记

TLS 1.3 把 TLS 1.2 握手的2-RTT缩减为1-RTT

重点是由Client发起keyshare协商

# Resumption 

## TLS 1.2 Resumption

(1) Client -> Server : Client Hello

可以提供之前的Session ID，

或提供之前的Session Ticket，相当于之前key exchange结果的一个快照的加密，只能由Server解密，此时Server无状态

(2) Server -> Client : 

ServerHello, ChangeCipheSpec, 完成握手

(3) Client -> Server :

Clinet Key Exchange, ChangeCipheSpec, Finish

顺便 GET/POST/....

省掉了cipher选择、证书交换的一轮RTT。

## TLS 1.3 Resumption

0-RTT

(1) Client -> Server : 

ClientHello, SessionTicket(PSK)，Key share

HTTP GET/POST

上面HTTP GET/POST的请求数据沿用之前的密钥PSK加密

由于SessionTicket只能由Server解密，因此Server具备从SessionTicket解出PSK，再用PSK解出HTTP GET/POST DATA的能力

(2) Server -> Client :

ServerHello, Key share, ...

HTTP Answer

Answer这里就有新密钥可以用了

## 笔记

TLS1.2 Resumption是复用了cipher suite，但是更新了两边随机数，再通信。

TLS1.3 Resumption的Client HTTP请求用了PSK，因此，Client->Server的这个请求无法防重放攻击。除了这个请求以外，其他后续的通信都可以用上新密钥。

假设Resumption 0-RTT请求带的是GET，那么不会有太大安全风险，应答返回时已changecipherspec，且由于0-RTT，比较快，适合Cloudfare的CDN厂商服务场景。

假设Resumption 0-RTT请求带的是POST，那么风险程度与该CGI的重要性相关。当然风险触发的概率与该敏感操作是否允许在0-RTT即时触发相关。这个实际概率一般较小，不过只要没有其他二次认证手段，敏感CGI理论上还是存在一定风险。

所以SessionTicket在TLS1.3场景下，最大用处感觉就在支持这个0-RTT了。。。
