---
layout: post
category: tech
title:  "TLS token binding 安全扩展"
tagline: ""
tags: [ "tls", "security" ] 
---
{% include JB/setup %}

* TOC
{:toc}

# 资料

[http://browserauth.net/](http://browserauth.net/)

## Bearer Token

client -> server 的验证票据，例如password，cookie

也就是可以用password，cookie伪装客户身份

## challenge

client 生成公私钥对，server预先保存公钥，后续：

server -> client : challenge

client -> server : 用私钥对challenge签名；负责签名的模块 Trusted Platform Module (TPM) 与 client硬件绑定，防止回落到传统的纯password/cookie

server : 用公钥验证

## TLS Client Authentication

如果用client ca证书模式，用户操作复杂，且证书ok是否等同logging in？

同一http session的多用户账号切换（google账号切换场景）

多个网站用相同的ca证书，或者每个网站用不同的ca证书，都存在运维方面的问题

此外，由于ca与设备绑定，与之相关的多设备、ca迁移问题，等等

## Trusted Computing Base in Datacenters

TLS terminator 两种做法：

1） TLS terminator 验证ok后，请求更多资源时不需继续验证 

2） TLS terminator 验证ok后，任何后续的资源请求，原样转发cookie用于内部验证

所以其实tls用来做用户身份验证不太靠谱

## Token Binding

TLS Extension and HTTP Header: [tokbind](https://datatracker.ietf.org/wg/tokbind/documents/)

client 与 server 在 tls 握手阶段 协商 token binding

client 添加 Token-Binding 的 HTTP 头，发送到 server，内容是private Token Binding key对nonce的签名。

这个Token Binding 公私钥对的生成对用户完全透明，且不与用户身份关联，不同网站互不相同。

##  Channel-Bound Cookies

HTTPS + Token Binding ：服务器通过client public token binding key将cookie与https channel绑定，也就是说，cookie只能用在当前public key对应的https channel

此时，窃取cookie无用（无法通过Token-Binding的公钥验证）

并且，在绑定https channel之后，链路上的中间人攻击难以生效

## Channel Binding

服务器将cookie与client public key绑定，而非像RFC5929一般（将数据与server public key绑定）

{% highlight bash %}
Kb :  client public key

server -> client --------------
Set-Cookie : { uid, Kb } signed with  Kb

client -> server --------------
Cookie: { uid, Kb } signed with  Kb
Token-Binding:  Kb, { EKM } signed with Kb

{% endhighlight %}

服务器检查 :  

{% highlight bash %}
cookie received = cookie sent

Kb in Token-Binding is same with Kb in { uid, Kb } 

{ EKM } signed with Kb  match TLS { EKM }
{% endhighlight %}

EKM signature 参考 [Token Binding Protocol Message](https://tools.ietf.org/html/draft-ietf-tokbind-protocol-08#section-3)

EKM 参考 [Keying Material Exporters for Transport Layer Security (TLS)](https://tools.ietf.org/html/rfc5705)

这里的细节在于，Token-Binding里的EKM签名作用是与tls session信息关联，而Cookie里的uid+Kb签名作用是与Token-Binding里的Kb关联，两层关联即实现tls channel + client public key的信息绑定，有效减小中间人攻击的风险。

## Proof-Key Federation Protocols

第三方验证

client 生成两份公私钥对。向Identity Privider同时发送 k1对nonce的签名、k2对nonce的签名

[token bind https](https://datatracker.ietf.org/doc/draft-ietf-tokbind-https/)

## Proof of Possession for JWT

[oauth proof of possession](https://tools.ietf.org/html/draft-ietf-oauth-proof-of-possession)

identity privider -> client : ``rp.com/?{id=bob&key=K2}``

client -> relying player : ``GET rp.com/?{id=bob&key=K2}`` with HEADER: {nonce}signed by k2

。。。。。

channel交互：[postmessage based secure federation](http://www.browserauth.net/proof-key-federation-protocols/postmessage-based-secure-federation)

## Strong User Authentication 

the risk associated with original user authentication

安全密码环境，用户证书

二次认证（例如短信验证码），但是容易被钓鱼

FIDO：钓鱼、中间人攻击

## 总结

这是tls的增强扩展，优势在于攻击者在`client<->server`的channel建立之后难以进行中间人攻击，但是没法解决建立channel之前就存在的中间窃听问题。

fido解决重点其实是在于身份认证，而tls token binding重点在于链路安全。

实际浏览器支持的方面，fido应用驱动优势估计更大一些。
