---
layout: post
category: crypto
title:  "imessage pq3"
tagline: ""
tags: [ "crypto", "apple" ] 
---
{% include JB/setup %}

* TOC
{:toc}

# doc

[iMessage with PQ3: The new state of the art in quantum-secure messaging at scale](<https://security.apple.com/blog/imessage-pq3/) 

[Advancing iMessage security: iMessage Contact Key Verification](https://security.apple.com/blog/imessage-contact-key-verification)

https://security.apple.com/assets/files/A_Formal_Analysis_of_the_iMessage_PQ3_Messaging_Protocol_Basin_et_al.pdf

https://security.apple.com/assets/files/Security_analysis_of_the_iMessage_PQ3_protocol_Stebila.pdf

用的lattice kem，kyber-1024/768。Pre-key是1024，rekey是768。

Lattice kem encap的ss用于hkdf派生。

prekey（ecdh pub key, kyber pub key）通过IDS发布（与identity关联），以device auth key（secure enclave保护）签名。device auth key有可能跨device shared。

device auth pub key 以 account contact key 签名，IDS以类似pki的CT （user opt-in)机制发布，按需更新。CT机制参考了CONIKS的数据结构，采用VRF处理。点对点确认选用Vaudenay SAS 。

account contact key为long-term key，keychain同步。

session key派生机制参考signal，per-message symmetric ratchet , per-direction ecdh ratchet,  periodical kyber ratchet.

rekeying参考signal，支持BS/PCS。

Message auth用device auth key，不一定仅限于establishment。

其余基础内容不变。
