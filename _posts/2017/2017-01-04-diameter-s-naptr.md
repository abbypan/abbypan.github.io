---
layout: post
category: tech
title:  "RFC6408: Diameter S-NAPTR"
tagline: ""
tags: [ "dns", "ietf", "rr" ] 
---
{% include JB/setup %}

## SRV

RFC2782 SRV的场景是 _foo._proto.example.com 标识服务+协议，例如 _ldap._tcp 之类

## NAPTR

RFC3403 NAPTR的场景是 提供一个正则替换表达式，借此为指定的URN提供对应的业务域名

  例如 urn:cid:199606121851.1@bar.example.com
  cid.urn.arpa.
  ;;       order pref flags service        regexp           replacement
  IN NAPTR 100   10   ""    ""  "!^urn:cid:.+@([^\.]+\.)(.*)$!\2!i"    .

## NAPTR, SIP

RFC3824 是NAPTR的典型应用场景，将E.164电话地址转换为SIP电话地址

  $ORIGIN 0.0.6.2.3.3.5.2.0.2.1.e164.arpa.
    IN NAPTR 100 10 "u" "E2U+sip"    "!^.*$!sip:user@example.com!"     .
    IN NAPTR 100 20 "u" "E2U+mailto" "!^.*$!mailto:info@example.com!"  .

注意第8节的隐私讨论，知道电话号码，就能反推sip地址，如果该地址没有匿名化处理，由于明文交互，这也可能是有security concern的

## Diameter Straightforward-Naming Authority Pointer(S-NAPTR)

Diameter 协议的场景是通信双方对等协商，计费，认证之类，RFC3588

这个S-NAPTR简化了NAPTR的设定，不再设置正则式了，而是直接返回最后一项replacement的值

RFC3958 section 5 有简化思路讨论，Dynamic Delegation Discovery Service(DDDS)，为啥SRV太弱，NAPTR太复杂，blablabla

服务标识 "aaa+apX:Y" 的X是登记的应用号码，Y是传输层协议

例如查询一个ex1.example.com域名的Diameter服务，flag="s"

    ;;        order pref flags service   regexp replacement
           IN NAPTR  50    50   "s"   "aaa:diameter.sctp" ""
                        _diameter._sctp.ex1.example.com
           IN NAPTR  50    50   "s"   "aaa+ap1:diameter.sctp" ""
                        _diameter._sctp.ex1.example.com
           IN NAPTR  50    50   "s"   "aaa+ap4:diameter.sctp" ""
                        _diameter._sctp.ex1.example.com

得到SRV记录，再查SRV，得到服务域名

或者直接返回域名flag="a"

     ;;        order pref flags service   regexp replacement
           IN NAPTR  150   50   "a"   "aaa:diameter.sctp"  ""
                        server1.ex2.example.com
           IN NAPTR  150   50   "a"   "aaa:diameter.tls.tcp"  ""
                        server2.ex2.example.com
