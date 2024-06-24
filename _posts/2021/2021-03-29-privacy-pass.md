---
layout: post
category: privacy
title:  "Privacy Pass Protocol Specification"
tagline: ""
tags: [ "privacy", "security", "rfc" ] 
---
{% include JB/setup %}

* TOC
{:toc}

# doc

[Privacy Pass Protocol Specification](https://datatracker.ietf.org/wg/privacypass/documents/)

参考 RFC9576/9577/9578，主要是9578。

最初是用在TOR。

client -> server 的匿名授权，生成token。

server 无法基于 client 的 re-authorization ， link 跟踪到初始的授权。

# token

cookie 的问题就是token跟踪，跨域跟踪。

privacy pass protocol:
- unlinkability: client一次性获得多个single-domain/cross-domain的授权token，不用重复认证，且确保匿名性。
- unforgeability: client无法伪造token，或者增加token个数。

细节参考 voprf

phase:
    1) issuer server setup: 
    skS, pkS
    
    2) client setup: 
    pkS, m 
    
    3) issuance:  
    client: m (input) -> req (blindToken)
    issuer server: resp (evaluation)
    client: 
            redemption Token = { input.data, issued: issuedTokens }
    与voprf的issuedTokens过程一致

    4) redemption:
    client:  token, info -> req
        tag = Finalize(token.data, token.issued, info) //info 加 timestamp，生成hash output
        req = redemption request = { data, tag, info }

    issuer server: 
        检查是否已遇到过该req.data，避免double spend;
        resp = VerifyFinalize(pkS, skS, req.data, req.info, req.tag) //相当于让server自己做一下签名校验
        如果resp.success，登记req.data 


# protocol

client 向 origin server 发起访问请求。

origin server 提供 token challenge。

client 与 issuer server 的authentication 参考rats(RFC9334)的attestation。

client 向 issuer server 请求签发 token。

origin server 校验 token。
