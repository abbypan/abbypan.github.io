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

[NIST Cybersecurity for IoT Program](https://www.nist.gov/programs-projects/nist-cybersecurity-iot-program)

[Privacy, Discovery, and Authentication for the Internet of Things](https://arxiv.org/abs/1604.06959)

[ETSI IoT Security WORKSHOP](https://docbox.etsi.org/Workshop/2016/201606_SECURITYWS/S03_RISKSFROMTRANSPORTDOMAIN/RENAULT_LONC.pdf)

[The DNS and the Internet of Things: Opportunities, Risks, and Challenges](https://www.icann.org/en/system/files/files/sac-105-en.pdf)

[Charting the Atack Surface of Trigger-Action IoT Platforms](https://adambates.org/documents/Wang_Ccs19.pdf)

[9 Main Security Challenges for the Future of the Internet Of Things (IoT)](https://readwrite.com/2019/09/05/9-main-security-challenges-for-the-future-of-the-internet-of-things-iot/)

[Enhancing-IoT-Security-Report](https://www.internetsociety.org/wp-content/uploads/2019/05/Enhancing-IoT-Security-Report-2019_EN.pdf)

[Trusted Internet of Things (IoT) Device 4 Network-Layer Onboarding and Lifecycle 5 Management](https://nvlpubs.nist.gov/nistpubs/CSWP/NIST.CSWP.09082020-draft.pdf)

[Hardware or Software Security: Which is right for my IoT Device?](https://www.iotcentral.io/blog/hardware-or-software-security-which-is-right-for-my-iot-device)

# privacy

[A Privacy-Enhancing Framework for Internet of Things Services](https://eprint.iacr.org/2019/1471.pdf)




# paper

## Evaluation of Out-of-Band Channels for IoT Security

[Evaluation of Out-of-Band Channels for IoT Security](https://link.springer.com/article/10.1007/s42979-019-0018-8)

secure bootstrapping in ad-hot IoT deployment

Out-of-Band : NFC, QR Code, audio

Extensible Authentication Protocol (EAP) 


One-time password (OTP): SMS

### group messaging

telegram, whatsapp, signal, support e2e encryption with oob verification, require users to compare information shown on each other's devices.

telegram: 生成一个图片展示已交换的keys

whatsapp: 
- 60-bit string = hash (user's public identity key) 到 30-bit + 30-bit (两个string)；用户比较60-bit string
- 或者扫qr code


### Nimble Out-of-Band Authentication for EAP (EAP-NOOB)

dynamic OOB messages, refresh cycle 3600s

secret nonce (Noob): first authentication, mutually authentication

cryptographic fingerprint(Hoob): verify the integrity of the key exchange, detect impersonation and mitm on the in-band channel

OOB mesage url example (60bytes): server domain name (60 characters base64),  PeerId (22 characters base64),  secret nonce (Noob) 16-byte, fingerprint (Hoob) 16-byte
