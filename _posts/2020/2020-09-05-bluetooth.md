---
layout: post
category: security
title:  "Bluetooth Security"
tagline: ""
tags: [ "ble", "bluetooth", "Security" ] 
---
{% include JB/setup %}

* TOC
{:toc}

# doc

[Dialog SDK 5.0.x/6.0.x Tutorial Pairing, Bonding and Security](https://www.dialog-semiconductor.com/sites/default/files/training_05_ble_security_example_v1.2.pdf)

[Understanding Bluetooth Security By Mark Loveless](https://duo.com/decipher/understanding-bluetooth-security)

[Bluetooth security](https://www.slideshare.net/ShantanuKrishna1/bluetooth-security-25861180)

[Security Considerations For Bluetooth Smart Devices](https://www.design-reuse.com/articles/39779/security-considerations-for-bluetooth-smart-devices.html)

[Bluetooth's Complexity Has Become a Security Risk](https://www.wired.com/story/bluetooth-complex-security-risk/)

[Breaking BLE — Vulnerabilities in pairing protocols leave Bluetooth devices open for attack](https://www.microcontrollertips.com/breaking-ble-vulnerabilities-in-bluetooth-pairing-provide-openings-for-attack-faq/)

[ble-spec](https://www.bluetooth.com/specifications/protocol-specifications/)

[Evaluation of Out-of-Band Channels for IoT Security](https://link.springer.com/article/10.1007/s42979-019-0018-8)

[BLE Pairing and Bonding](https://www.kynetics.com/docs/2018/BLE_Pairing_and_bonding/)

[Cryptographic Analysis of the Bluetooth Secure Connection Protocol Suite](https://eprint.iacr.org/2021/1597.pdf)

# privacy

[Protecting Privacy of BLE Device Users](https://www.semanticscholar.org/paper/Protecting-Privacy-of-BLE-Device-Users-Fawaz-Kim/558380e0cba2c5bcda7d4d94e23f215ede0e910f?p2df)

[Bluetooth Low Energy - privacy enhancement for advertisement](https://core.ac.uk/download/pdf/52107479.pdf)

[Automatic Fingerprinting Of Vulnerable BLE IoT DevicesWith Static UUIDs From Mobile Apps](https://web.cse.ohio-state.edu/~lin.3021/file/CCS19a-slides.pdf#beamerbibfawaz2016protecting)

# attack

[CVE-2018-5383: Breaking the Bluetooth Pairing – The Fixed Coordinate Invalid Curve Attack](https://eprint.iacr.org/2019/1043.pdf)

[CVE-2019-9506: The KNOB is Broken: Exploiting Low Entropy in the Encryption Key Negotiation Of Bluetooth BR/EDR](https://knobattack.com/)

[Bluetooth Impersonation Attacks (BIAS)](http://securityaffairs.co/wordpress/103480/hacking/bias-attack-bluetooth.html)

[Misbinding Attacks on Secure Device Pairing and Bootstrapping](https://dl.acm.org/doi/10.1145/3321705.3329813)

[Breaking BLE — Vulnerabilities in pairing protocols leave Bluetooth devices open for attack](https://www.microcontrollertips.com/breaking-ble-vulnerabilities-in-bluetooth-pairing-provide-openings-for-attack-faq/)

## blesa

[BLESA: Spoofing Attacks against Reconnections in Bluetooth Low Energy](https://www.usenix.org/system/files/woot20-paper-wu-updated.pdf)

缺乏authentication & encryption，伪造交互信息，从secure connection降级

其根源在于向后兼容，允许降级

## misbinding attack 

[Misbinding Attacks on Secure Device Pairing and Bootstrapping](https://arxiv.org/pdf/1902.07550.pdf)

ble pairing & eap-noob 的核心问题在于，pairing时并未对device identifier做认证。因此存在identity misbinding的风险。

缓解：sts, sigma, ike

device provsioning protocol (dpp)



# nist sp 800-121

[NIST SP 800-121 Guide to BluetoothSecurity](https://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.800-121r2.pdf)

RSSI: received signal strength indication 信号强度

## data rate

BR: basic rate

EDR: Enhance data rate

AMP: Alternate MAC/PHYs, 即HS高速连接

LE: Low Energy

## device mode

discoverable mode: 设备周期性的监测是否有inquiry

connectable mode: 设备周期性的扫瞄是否有可用连接

inquiry

paging

advertising

## Device Architecture

Host: GAP, SMP, ATT/GATT, SDP, L2CAP...

LE Controller:  Link Manager/Controller (LLP)

BR/EDR Controller:  Link Controller (LCP), Link Manager(LMP)

L2CAP: Logical Link Control and Adaptation Protocol

SDP: Service Discovery Protocol

## topo

BR/EDR: 7 active slave devices, 255 inactive slave devices

LE: unlimited number of slaves ——扯。。。

## security

主要考察：pairing, link key generation, authentication, confidentiality 信息

注意，蓝牙支持是设备层认证，而非用户层认证

设备双方pairing成功后，存储相关的shared secret keys，后续进入Bonding模式，复用这些keys，无需重复pairing。

BR/EDR/HS的安全指标：FIPS alg， MITM protection，user interaction during pairing, encryption

如果要求Device满足FIPS要求，则除Service Discovery场景之外，设备应在Secure Connections Only模式。

##  pairing & link key generation

pairing的核心是经过authentication，设备双方获得对称密钥（即LK/LTK)

LE: Long Term Key (LTK)

BR/EDR: Link Key (LK)

### PIN/legacy Pairing

Legacy low energy pairing: 协商生成TK，基于TK+random生成 STK (Short Term Key)，使用STK distribute Slave/Master LTK，也就是key transport

PIN Pairing: 基于PIN码派生Link Key——与secure connection不同。

Low Energy Pairing: 没有ECDH，无法防eavesdropping；能抓包就能破（除了OOB）。

### secure simple pairing

Low Energy secure connection: ECDH协商生成LTK，key agreement；可以抵御eavesdropping

4种连接模式：
- Numeric Comparision（仅secure connection支持此模式）：用户查看两个互联的设备显示的6位digit是否一致；注意，digit仅参与认证，不参与密钥派生，digit无需保密——可以抵御eavesdropping；可以抵御MITM（用户确认）
- Passkey Entry: 用户查看一个设备显示的digit，在另一个设备输入6位digit；注意，digit仅参与认证，不参与密钥派生，digit无需保密——可以抵御eavesdropping；可以抵御MITM（用户输入）
- Just Works: 两个互联设备无显示、无输入，直接连接；底层处理与Numeric Comparision类似——无法抵御MITM
- Out of Band (OOB): 通过NFC之类的外围设备，交换连接信息——可抵御MITM、eavesdropping

### AMP Link Key 

AMP LK从Bluetooth Link Key派生，HMAC-SHA256

## device authentication

challenge-response模式，基于link key的机密性保证，challenge由verifier随机生成，由claimant提供证明

### legacy authentication

e1 alg，基于link key， bd\_addr, rand计算出SRES(32 bit), ACO(06 bit)

SRES用于校验

ACO用于后续派生加密key

### seucure authentication

基于双向bd\_addr, rand，结合link key计算SRES

注意两个方向的SRES不同

Master ACO用于后续派生加密key

## confidentiality

mode 1: no encryption

mode 2: individual link keys 加密配对数据；广播数据不加密

mode 3: 所有数据用master link key加密

加密key记为K\_c，注意协商key size要有漏洞的

### E0 Encryption alg

基于link key，结合COF值派生K\_c

COF:
- Master Link Key的场景，取`Addr_M || Addr_S`
- Individual Link Key的场景，取ACO

### AES-CCM encryption alg

link key, `BD_ADDR`, btak（固定字串），ACO 派生AES KEY

## fips alg

BR/EDR :  P-256, HMAC-SHA256

LE: P-256, AES-CMAC

AES-CCM

## LK & LTK

BR/EDR的 link key 可以与 LE的Long Term Key 相互派生, 

结合设备双方的addr & random做派生，h6 aes-cmac-128

## IRK ( Identity Resolving Key ) 

LE隐私feature支持，IRK用于map Resolvable Private Address (RPA) to an Identity Address

Identity Address: 随机固定地址，或者公共地址

开启RPA更新，即，周期性更换基于IRK+随机hash处理的地址

## CSRK

没加密的数据流，可以用CSRK做一下MAC校验

LE legacy pairing: LTK/IRK/CSRK  key transport

LE Secure Connection: LTK key agreement, IRK/CSRK key transport

## Vulnerabilities

MITM protection (Just Work)

ECDH KEY太弱

passkey的随机性

降级攻击

蓝牙地址关联到个人

Link Key安全存储

Device Discoverable

## Mitigation

security vs cost, performance, operational

security equipment, inconvenience, maintenance, operation

defense-in-depth

user authorize

application-level authentication/encryption

PKI, two-factor

不要太经常pairing

