---
layout: post
category: tech
title:  "HD Wallets"
tagline: ""
tags: [ "bitcoin", "wallet" ] 
---
{% include JB/setup %}

* TOC
{:toc}

# BIP-0032

[bip-0032](https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki)

hierarchical deterministic wallets，通过单个CSPRNG，来回调用hmac-sha256，结合ec point的加法、乘法，层次化派生公私钥对，用于bitcoin wallet。

通过`i>=2^31`区分派生的hardened / normal

    i ≥ 2^31: hardened child
        let I = HMAC-SHA512(Key = cpar, Data = 0x00 || ser256(kpar) || ser32(i))
    otherwise: normal child
        let I = HMAC-SHA512(Key = cpar, Data = serP(point(kpar)) || ser32(i))

    IL || IR = I
    ki = parse256(IL) + kpar (mod n)
    ci = IR
    private key: (ki, ci)
    public key: (Ki, ci),  Ki=point(ki)

hardened child无法通过父公钥直接派生子公钥，而normal child可以

    CKDpub((Kpar, cpar), i) → (Ki, ci)

    i ≥ 2^31: hardened child
        return fail
    otherwise: normal child
        let I = HMAC-SHA512(Key = cpar, Data = serP(Kpar) || ser32(i))

    IL || IR = I
    Ki = point(parse256(IL)) + Kpar
    ci = IR
    public key: (Ki, ci)

# BIP-0044

[bip-0044](https://github.com/bitcoin/bips/blob/master/bip-0044.mediawiki)

    m / purpose' / coin_type' / account' / change / address_index
