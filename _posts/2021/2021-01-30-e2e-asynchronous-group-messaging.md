---
layout: post
category: tech
title:  "On Ends-to-Ends Encryption:Asynchronous Group Messaging with Strong Security Guarantees"
tagline: ""
tags: [ "security" ] 
---
{% include JB/setup %}

* TOC
{:toc}

# background

[On Ends-to-Ends Encryption:Asynchronous Group Messaging with Strong Security Guarantees](https://eprint.iacr.org/2017/666.pdf)

Asynchronous Ratcheting Trees (ART) : tree-based DH key exchange, derive a shared symmetric key

IETF MLS group

## signal protocol

FS: forward secrecy

PCS: post-compromise security, "future secrecy", "self-healing"

PCS机制的关键在于，即使long-term key被exploit knowledge，只要有一次unintercepted exchange，就可以确保后向安全。

当前WhatsApp/Facebook Messenger/Google Allo等主要在two-party communication场景下支持PCS；在群聊的场景下，还是简单的key-transport mechanism（sender keys）机制。

## asynchronicity

asynchronicity: 发送方Alice可以给离线的Bob发消息，这也就意味着，异步消息传递。

因此，在asynchronicity场景下，DH是间接交换的，而非实时。

precomputed DH key => prekeys

## GKE (group key exchange)

group communication key应当支持：
- 支持 asynchronously。群聊里有人离线。
- scales sublinearly in group size。当group member人数很多时，two-party的消息加密显然不够经济。
- admits strong security guarantees  such as PCS ?

## copath

当前节点，到root的路径上，参与DH运算的节点。

# Group Messaging Protocols

OTR-style: Multi-Party Off the Record Messaging (mpOTR), 主要是实时key exchange。

Assuming an authentic network: 分布式系统，一些信息交互，支持异步，不支持PCS

Sender Keys: 当前节点加密自身“broadcast” keys，传给每一个group member。需要定期切换sender key，以防sender key泄漏的场景。WhatsApp在群聊的member有变动时更新sender keys，否则无法防范PCS。

n-party DH: joux protocol, with problem

Tree-based group DH, 每个叶子节点是一个group member的公钥，构造一个二叉树

# objectives

secrecy and aauthentication

FS & PCS

## out of scope

poor randomness

sender-specific authentic

malicious group members

# protocol

## signature & mac

initial group message => signature

subsequent updates => MAC, 用的stage sk

## keys

Leaf keys 叶子的DH Key

Node keys 非叶子的DH key

tk(tree key) 是 DH Tree 的根

sk(stage key)是会话的key，基于 上一次的sk + 当前的tk 迭代派生，初始值可以是0

## key exchange

假设a来setup整个DH Tree

ika为long-term key

suk = setup key，是a为此次会话临时生成的private key

Ekb 是Bob预先登录的prekeys, 用于Asynchronous异步one time use的ephemeral key

leaf key = keyexchange(ika, IKb, suk, EKb)

注意keyexchange可以有两种模式：
- unauthenticated:  直接 Ekb^suk，忽略ika, Ikb
- authenticated: 类似X3DH，ika, Ikb, suk, Ekb均参与运算，H(ika * EKb, suk*IKb, suk*EKb, ika*IKb)。

## initial message

4项内容：
- a所使用的group member的EK, IK列表
- a临时生成的SUK(公钥)
- tree T of public keys，即建立的DH树
- 对前3条消息的签名（使用自身的ik进行签名）

## Multiple devices

同一个用户有多个devices的场景，该用户可以有主设备接入，然后主设备再建一棵小树=>应该不用这么复杂。。。

## ART vs X3DH

ART比X3DH要简单

一个是支持static-static DH keys

另一个是使用stage key加密message，而非使用Double Ratchet里的chain key轮转

