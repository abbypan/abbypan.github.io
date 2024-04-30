---
layout: post
category: crypto
title:  "The BBS Signature Scheme"
tagline: ""
tags: [ "bbs", "zkp", "privacy", "cfrg", "zcash" ] 
---
{% include JB/setup %}

* TOC
{:toc}

# doc

[The BBS Signature Scheme](https://datatracker.ietf.org/doc/draft-irtf-cfrg-bbs-signatures/)

[Zcash Overwinter Consensus and Sapling Cryptography Review](https://research.nccgroup.com/wp-content/uploads/2020/07/NCC_Group_Zcash2018_Public_Report_2019-01-30_v1.3.pdf)

[Slide: The BBS Signature Scheme](https://datatracker.ietf.org/meeting/114/materials/slides-114-cfrg-bbs-signature-scheme-pdf-00)

bbs的核心特征是short group Signature，支持zkp，选择性披露部分消息(Selective Disclosure)，而proof of possession本身并不泄漏与原始signature的关联(Unlinkable)。

BLS12-381 pairing curve，同zcash，117~120 bits security。

G1/G2均为r质数阶的subgroup，public key在G2，signature在G1。

random要求CSPRNG。

基于IKM，结合keyinfo，派生私钥SK。

PK = P2 * SK, P2为G2的生成元。

header 配置信息，signature/proof中都含header。

messages 内容信息，signature全量，proof按需。

# Sign

    Sign(SK, PK, header, messages)

生成确定的generators

    (Q_1, Q_2, H_1, ..., H_L) = create_generators(L+2)

基于PK、generators、header计算domain，一个hash2scalar映射。

      domain = calculate_domain(PK, Q_1, Q_2, (H_1, ..., H_L), header)

基于SK、domain, msg1 ... msgL 计算 (e, s)，一个expand_message，两个hash2scalar映射。

    e_s_octs = serialize((SK, domain, msg_1, ..., msg_L))
    e_s_expand = expand_message(e_s_octs, expand_dst, e_s_len)
    e = hash_to_scalar(e_s_expand[0..(octet_scalar_length - 1)])
    s = hash_to_scalar(e_s_expand[octet_scalar_length..(e_s_len - 1)])

 计算A

    B = P1 + Q_1 * s + Q_2 * domain + H_1 * msg_1 + ... + H_L * msg_L
    A = B * (1 / (SK + e))

 signature = (A, e, s)

# Verify

    ProofVerify(PK, proof, header, ph, disclosed_messages, disclosed_indexes)

同样生成generators、domain

计算B

    B = P1 + Q_1 * s + Q_2 * domain + H_1 * msg_1 + ... + H_L * msg_L

校验签名

     if e(A, W + P2 * e) * e(B, -P2) != Identity_GT, return INVALID
     return VALID

pairing比较简单，`W = octets_to_pubkey(PK) = P2 * SK`

# ProofGen

    proof = ProofGen(PK, signature, header, ph, messages, disclosed_indexes)

L为messages总数，R为披露的messages数，U为未披露的messages数

同样生成generators、domain

生成random列表

    random_scalars = calculate_random_scalars(6+U)
    (r1, r2, e~, r2~, r3~, s~, m~_j1, ..., m~_jU) = random_scalars

计算中间参数

    B = P1 + Q_1 * s + Q_2 * domain + H_1 * msg_1 + ... + H_L * msg_L
    r3 = r1 ^ -1 mod r
    A' = A * r1
    Abar = A' * (-e) + B * r1
    D = B * r1 + Q_1 * r2
    s' = r2 * r3 + s mod r
    C1 = A' * e~ + Q_1 * r2~
    C2 = D * (-r3~) + Q_1 * s~ + H_j1 * m~_j1 + ... + H_jU * m~_jU

计算challenge，同样是hash2scalar

    c = calculate_challenge(A', Abar, D, C1, C2, (i1, ..., iR), (msg_i1, ..., msg_iR), domain, ph)

计算proof

    e^ = c * e + e~ mod r
    r2^ = c * r2 + r2~ mod r
    r3^ = c * r3 + r3~ mod r
    s^ = c * s' + s~ mod r
    for j in (j1, ..., jU): m^_j = c * msg_j + m~_j mod r
    proof = (A', Abar, D, c, e^, r2^, r3^, s^, (m^_j1, ..., m^_jU))

注意j1, ..., jU 是未披露的messages index

# ProofVerify

    result = ProofVerify(PK, proof, header, ph, disclosed_messages, disclosed_indexes)

同样生成generators、domain

计算C1

    C1 = (Abar - D) * c + A' * e^ + Q_1 * r2^
       = (A' * (-e) + B * r1 - D) * c + A' * e^ + Q_1 * r2^
       = (A' * (-e) - Q_1 * r2) * c + A' * e^ + Q_1 * r2^
       = A' * (e^ - e * c) + Q_1 * (r2^ - r2 * c)
       = A' * e~ + Q_1 * r2~
       = C1

计算C2

    T = P1 + Q_2 * domain + H_i1 * msg_i1 + ... + H_iR * msg_iR

    C2 = T * c - D * r3^ + Q_1 * s^ + H_j1 * m^_j1 + ... + H_jU * m^_jU
       = (P1 + Q_2 * domain + H_i1 * msg_i1 + ... + H_iR * msg_iR) * c - D * (c * r3 + r3~) + Q_1 * (c * s' + s~)  + H_j1 * (c * msg_j1 + m~_j1) + ... + H_jU * (c * msg_jU + m~_jU)
       = (P1 + Q_2 * domain + H_1 * msg_1 + ... + H_L * msg_L - D * r3 + Q_1 * s') * c - D * r3~ + Q_1 * s~ + H_j1 * m~_j1 + ... + H_jU * m~_jU 
       = (B - Q_1 * s - D * r3 + Q_1 * s') * c + D * (-r3~) + Q_1 * s~ + H_j1 * m~_j1 + ... + H_jU * m~_jU  
       = (B + Q_1 * r2 * r3 - B * r1 * r3 - Q_1 * r2 * r3) * c + D * (-r3~) + Q_1 * s~ + H_j1 * m~_j1 + ... + H_jU * m~_jU  
       = D * (-r3~) + Q_1 * s~ + H_j1 * m~_j1 + ... + H_jU * m~_jU  
       = C2

计算cv 

    cv = calculate_challenge(A', Abar, D, C1, C2, (i1, ..., iR), (msg_i1, ..., msg_iR), domain, ph)

检查cv是否与c相等

    if A' == Identity_G1, return INVALID
    if e(A', W) * e(Abar, -P2) != Identity_GT, return INVALID

    e(A', W) * e(Abar, -P2)
    = e(A', P2 * SK) * e(A' * (-e) + B * r1, -P2)
    = e(A * r1 * SK, P2) * e( (A * (-e) + B) * r1, -P2)
    = e(A * r1 * SK, P2) * e( A * SK * r1, -P2)
    = Identity_GT

# security

valid public key

valid point

prime order check

run in constant time

nonce reuse attack

header中带个nonce

G1与G2不同构

DRBG

proof replay attack

# use case

改进oauth2式的bearer access token

改进oauth2 DPoP式的校验形态，不用hmac/hash啥的

verifiable credential，例如driver license

