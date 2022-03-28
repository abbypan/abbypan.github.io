---
layout: post
category: tech
title:  "iot security"
tagline: ""
tags: [ "iot", "security" ] 
---
{% include JB/setup %}

* TOC
{:toc}

# doc


[The DNS and the Internet of Things: Opportunities, Risks, and Challenges](https://www.icann.org/en/system/files/files/sac-105-en.pdf)

[Charting the Atack Surface of Trigger-Action IoT Platforms](https://adambates.org/documents/Wang_Ccs19.pdf)

[9 Main Security Challenges for the Future of the Internet Of Things (IoT)](https://readwrite.com/2019/09/05/9-main-security-challenges-for-the-future-of-the-internet-of-things-iot/)

[Enhancing-IoT-Security-Report](https://www.internetsociety.org/wp-content/uploads/2019/05/Enhancing-IoT-Security-Report-2019_EN.pdf)

[Hardware or Software Security: Which is right for my IoT Device?](https://www.iotcentral.io/blog/hardware-or-software-security-which-is-right-for-my-iot-device)

[Privacy, Discovery, and Authentication for the Internet of Things](https://arxiv.org/abs/1604.06959)

[A Privacy-Enhancing Framework for Internet of Things Services](https://eprint.iacr.org/2019/1471.pdf)

# gfce

[International IoT Security Initiative](https://thegfce.org/initiatives/international-iot-security-initiative/)

[Internet of Things (IoT) Security GFCE Global Good Practices](https://cybilportal.org/wp-content/uploads/2019/10/GFCE-GGP-IoT.pdf)

思路不错，问题点，bcp（设计，实践，认证，基线，标准），challenge（供应链，碎片化，生命周期，rot，监控，人员） 都列了一下。

# ietf

## rfc8576 : iot security

从威胁讲起：漏洞、隐私、clone of things、替换、监听、MITM、镜像、信息提取、路由攻击(改包、选择性转发、分光、伪装）、提权、ddos。

影响：业务影响、安全风险、隐私风险、安全事件处理

一堆协议。。。

基于IP的安全框架。。。

PSK, Raw Public Key, Cert 安全模式。。。

主要问题点：异构网络、资源受限、DDoS、E2E、初始化、group comm、移动网络状态变换、secure update、update old and insecure cryptographic primitives、end of life (eol)、设备证明、应急响应、quantum-resistance、privacy (idenfication, localization, profiling, interaction, life cycle transitions, inventory attack, linkage)、逆向、可信操作。

# iotsf 

[IoT Security Foundation Publications](https://www.iotsecurityfoundation.org/best-practice-guidelines/)

[Secure Design Best Practice Guides](https://www.iotsecurityfoundation.org/wp-content/uploads/2019/12/Best-Practice-Guides-Release-2_Digitalv3.pdf)

主要是报菜名：classification of data, physical security, device secure boot, secure os, application security, credential Management, encryption, network connections, securing software updates, logging, software update policy, secure boot, secure update, side channel attack。

[IoT Security Assurance Framework](https://www.iotsecurityfoundation.org/wp-content/uploads/2021/11/IoTSF-IoT-Security-Assurance-Framework-Release-3.0-Nov-2021-1.pdf)

分了几个安全等级，以及对上面的菜名的细化要求。 

# etsi

[ETSI IoT Security WORKSHOP](https://docbox.etsi.org/Workshop/2016/201606_SECURITYWS/S03_RISKSFROMTRANSPORTDOMAIN/RENAULT_LONC.pdf)

# nist

[NISTIR 8228 Considerations for Managing Internet of Things (IoT) Cybersecurity and Privacy Risks](https://csrc.nist.gov/publications/detail/nistir/8228/final)

主要关注device security, data security, privacy (personally identifiable information, PII)。

[NISTIR 8259 Foundational Cybersecurity Activities for IoT Device Manufacturers](https://csrc.nist.gov/publications/detail/nistir/8259/final)

8259主要扯厂商可以在iot device的出厂前，出厂后干些什么事。注意出厂后的安全生命周期、升级、过期等等处理。

8259A关注device Cybersecurity的基线: device idenfication, device configuration, data protection, logical access to interface, software update, cybersecurity state awareness。

8259B主要扯要有什么人，应该干什么事。

[NIST  SP 800-213 IoT Device Cybersecurity Guidance for the Federal Government: Establishing IoT Device Cybersecurity Requirements](https://csrc.nist.gov/publications/detail/sp/800-213/final)

800-213 主要是表态。

800-213A 是针对8259讨论的内容的一些描述与解释，看目录也行。

[NIST Cybersecurity for IoT Program](https://www.nist.gov/programs-projects/nist-cybersecurity-iot-program)

[Trusted Internet of Things (IoT) Device 4 Network-Layer Onboarding and Lifecycle 5 Management](https://nvlpubs.nist.gov/nistpubs/CSWP/NIST.CSWP.09082020-draft.pdf)


# arm psa

[The PSA Certified 10 Security Goals Explained](https://www.psacertified.org/blog/psa-certified-10-security-goals-explained/)

[Entity Attestation Tokens](https://www.psacertified.org/blog/what-is-an-entity-attestation-token/)

arm主要是列了10大安全目标: unique idenfication, security lifecycle, software authorization, secure update, anti-rollback, isolation, interaction, device binding of stored data, cryptographic and trusted services。

基线内容是安全启动、HUK、安全存储等等，扩展内容是eat设备证明。

[JSADEN014 Platform Security Model](https://www.psacertified.org/app/uploads/2021/12/JSADEN014_PSA_Certified_SM_V1.1_BET0.pdf)

针对10 security goals的细化要求。

[psa Certifying Your Product](https://www.psacertified.org/development-resources/certification-resources/)

认证材料。

PSA Certified Level 1 Questionnaire Version 2.1 REL-02 有与其他标准(例如nist, etsi)的映射

PSA Certified Level 2 Attack Methods 威胁建模

[Platform Threat Model and Security Goals](https://www.psacertified.org/development-resources/building-in-security/platform-threat-model-and-security-goals/)

表列得不错

# arm

[Platform security](https://developer.arm.com/architectures/architecture-security-features/platform-security)

[Trusted Firmware-M Documentation](https://tf-m-user-guide.trustedfirmware.org/index.html)

[initial_attestation](https://git.trustedfirmware.org/TF-M/trusted-firmware-m.git/tree/secure_fw/partitions/initial_attestation)


# paper

## Evaluation of Out-of-Band Channels for IoT Security

[Evaluation of Out-of-Band Channels for IoT Security](https://link.springer.com/article/10.1007/s42979-019-0018-8)

secure bootstrapping in ad-hot IoT deployment。

Out-of-Band : NFC, QR Code, audio。

Extensible Authentication Protocol (EAP)。


One-time password (OTP): SMS。

### group messaging

telegram, whatsapp, signal, support e2e encryption with oob verification, require users to compare information shown on each other's devices。

telegram: 生成一个图片展示已交换的keys。

whatsapp: 
- 60-bit string = hash (user's public identity key) 到 30-bit + 30-bit (两个string)；用户比较60-bit string
- 或者扫qr code


### Nimble Out-of-Band Authentication for EAP (EAP-NOOB)

dynamic OOB messages, refresh cycle 3600s。

secret nonce (Noob): first authentication, mutually authentication。

cryptographic fingerprint(Hoob): verify the integrity of the key exchange, detect impersonation and mitm on the in-band channel。

OOB mesage url example (60bytes): server domain name (60 characters base64),  PeerId (22 characters base64),  secret nonce (Noob) 16-byte, fingerprint (Hoob) 16-byte。

# case

## firmware

[tlstorm](https://www.armis.com/research/tlstorm) : ups, firmware没签名
