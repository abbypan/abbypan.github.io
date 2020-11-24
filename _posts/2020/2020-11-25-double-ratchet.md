---
layout: post
category: tech
title:  "Double Ratchet"
tagline: ""
tags: [ "" ] 
---
{% include JB/setup %}

* TOC
{:toc}

# doc

[The Double Ratchet Algorithm](https://signal.org/docs/specifications/doubleratchet/)

通信双方基于share secret key = root key实施安全会话：
- earlier keys不能由later keys恢复
- later keys不能由earlier keys计算

# kdf chain

kdf key + input  派生出 kdf key + output key

通过input的迭代，更新 kdf key + output key

## chain

通信双方各自维护3个chain: root chain, sending chain, receiving chain

A 的 sending chain = B 的 receiving chain

A 的 receiving chain = B 的 sending chain

# ratchet

## symmetric-key ratchet

chain key + constant  派生出 chain key + message key

迭代派生

## Diffie-Hellman ratchet

Diffie-Hellman ratchet 的output secret 作为 root chain 的 input

### step

A预先获得B的ratchet public key

A计算 DH output 

A将自身的ratchet public key传给B

B计算 DH output

二者计算的DH output，即为 A的sending chain = B 的 receiving chain 的 input

root key + dh output 派生出 root key + A sending chain key

### next step

B切换新的ratchet public key

B计算 DH output

B将新的ratchet public key传给A

A计算DH output

二者计算的DH output，即为 A的receiving chain = B 的 sending chain 的 input

root key + dh output 派生出 root key + A receiving chain key

## double ratchet

sending chain key + constant 派生 sending chain key +  sending message key

receiving chain key + constant 派生 receiving chain key +  receiving message key

ratchet带动root chain更新，引发sending/receiving chain的更新

只要dh ratchet不更新，那么dh output不更新，root chain也不更新，就只有sending/receiving的两个chain的key在迭代更新

## double ratchet with header encryption

初始化key变成3个：root key， sending chain header key,  receiving chain next header key

root key + dh output 派生出 root key + chain key  + next header key，注意，这里next header key是与chain key关联的，例如，sending chain key对应sending chain的next header key。

A sending header key = B next receiving header key

A next receiving header key = B next sending header key

A以header key加密header，header中包含A新的ratchet public key & 消息序号 & 此次消息个数

A新的ratchet public key派生出新的root key, sending chain key, sending next header key

B以next header key加密header，header中包含B新的ratchet public key  & 消息序号 & 此次消息个数

A解密header后，派生出新的root key, receiving chain key, receiving next header key

注意，每一轮root chain的更新，上一轮的next header key自动变成当前轮的header key，并且自动生成下一次交换需要用的next header key。

ratchet public key不更新，header key就不需要用到

# detail

## out of order message

由于消息有序列，完全可以通过序列号定位message key。

message key由于one time use，用过之后可以删除。

## initial key

x3dh 密钥协商获得的sk  =  double ratchet 的 initial root key

x3dh 的 B的 signed prekey = B 的 initial ratchet public key

## cipher

aes-256-cbc pkcs7 padding

# security

messge key可以及时删除

这个轮转机制实在有够累的
