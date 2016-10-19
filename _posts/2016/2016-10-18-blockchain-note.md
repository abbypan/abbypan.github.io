---
layout: post
category: tech
title:  "笔记：区块链 blockchain"
tagline: ""
tags: [ "blockchain" ] 
---
{% include JB/setup %}

* TOC
{:toc}

## 资料


## 概念

每个区块的生成，代表确认该区块内的交易记录

一些待确认的交易合在一起，组成候选区块。然后求解一个nonce，使得该候选区块的hash值小于一个系统给定的值。求解出nonce后，全网广播，验证通过，承认该区块。

通过调节hash值结果限制，控制区块生成速度约为每10分钟一个。

求解nonce即为proof of work，工作量证明

CAP：一致性 Consistency、可用性 Availablity、分区容忍性 Partition

Paxos 一致性算法

环签名(Rivest, shamir, Tauman)，签名者用自己的私钥、集合中其他人的公钥生成签名。

## Merkle树

原始数据分块，计算hash。

hash两两合并（以二叉树为例），计算上层新hash，直至根节点。

底层数据变动时，沿着树向上，将变动一直连环传递到根

## 同态加密

Homomorphic	Encryption

##  区块结构

区块大小：4字节

区块头部：版本号4字节，上一个区块头sha256值32字节，此区块交易记录的Merkle根hash值32字节，timestamp 4字节，难度指标4字节，nonce4字节

交易个数

交易内容

## Hyperledger	

开源区块链账本
