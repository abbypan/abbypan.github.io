---
layout: post
category: tech
title:  "SSH: TerrapinAttack"
tagline: ""
tags: [ "ssh" ] 
---
{% include JB/setup %}

* TOC
{:toc}

# doc

[Terrapin Attack](https://terrapin-attack.com/)

[Terrapin Attack: Breaking SSH Channel Integrity By Sequence Number Manipulation](https://terrapin-attack.com/TerrapinAttack.pdf)

mitm条件下，操纵handshake sequence计数，drop关键extinfo，实施downgrade attack。

symmetric cipher mode影响的分析比较漂亮, something synced is influnenced by seq number。

核心还是full transcript hash，参考sequence number reset, handshake与record互不影响；end-of-communication message，标识h结束。
