---
layout: post
category: tech
title:  "Apple Continuity"
tagline: ""
tags: [ "connectivity", "security", "privacy" ] 
---
{% include JB/setup %}

* TOC
{:toc}

# Continuity

[Discontinued Privacy: Personal Data Leaks in AppleBluetooth-Low-Energy Continuity Protocols](https://hal.inria.fr/hal-02394619/document)

[Disrupting Continuity of Apple’s Wireless Ecosystem Security: New Tracking, DoS, and MitM Attacks on iOS and macOS Through Bluetooth Low Energy, AWDL, and Wi-Fi](https://www.usenix.org/system/files/sec21-stute.pdf)

Continuity: apple设备近场通信，基于Bluetooth/BLE/WiFi

## BLE

### protocol

BLE 4.0 共 40 个 physical channel，3个用于广播发现(advertisement)，37个用于传输(data transmission)

advertisement packet:  header + payload (up to 31 bytes)

advertisement data structure: length (1 byte) + type (1 byte) + data (up to 29 bytes)

Manufacturer Specific Data type: 0xFF

### device address

device Advertising Address 48 bits，即蓝牙mac地址

4种类型：
- Public device address: 公开且固定
- Random Static device address：每次开机启动重新生成
- Random Non-resolvable device address：随机生成，可定期更新
- Random Resolvable device address：配对的双方通过交换IRK，结合random value，定期轮换

建议每15 min更新一次

### RSSI

Received Signal Strength Indicator (RSSI) 信号强度

## Apple

HomeKit Accessory Protocol (HAP) specifications

### AD

Apple Manufacturer Specific Data 域里的payload结构： company identifier (2 bytes) + message (up to 27 bytes)

例如apple的company identifier是 0x004c

message是TLV格式: type (1 byte) + length (1 byte) + value

### Content Protection

Continuity message: 作为Advertising packet的一部分

Proximity Pairing & Handoff messages: 含有encrypted payload，aes-128/256-ecb

AirDrop, Nearby Action message (WiFi-SSID, email, phone number):  SHA256 -> TRUNC

Handoff, Nearby Action message, Nearby Info message: AES-256-GCM

### random device address

BLE per-15 min random address (default)

AirPrint, AirPlay:  public MAC address

AirDrop, HeySiri: Random Non-resolvable device address，每次开启蓝牙时随机生成一个地址，然后一直不动

### Continuity Protocols

AirPrint: 远程打印。message含printer ip/port

AirDrop: 传文件。message 含2 byte的hash标识， (email + phone number) -> sha256 -> trunc top 16 bits

HomeKit: 智能家居。支持HomeKit Accessory Protocol (HAP)的家用设备，monitoring & control。message含device id, device category, Global State Number(GSN)。每次状态改变，GSN++。

Proximity Pairing: audio device与iphone/ipad互联。message包含device attr(model, color), UTP position(在耳朵里/在盒子里），电量，充电状态，lid open counter（开盖计数？）, encrypted payload

HeySiri: 声音控制设备。message包含Perceptual Hash，SNR, Confidence, Device Class, Random Byte

AirPlay: 多媒体播放。与AirPrint类似，message含AirPlay target的目标IP地址。

Magic Switch: 手表watchOS与配对的iphone互联。watch与iphone断连，且亮屏时，发送此类消息。含 2-byte data域，confidence域

Handoff: 同一账号下的设备，用户activities的活动同步。AES-256-GCM, 还有ECB，IV递增（这两个不好）。

Instant Hotspot: 同一账号下的设备，开热点分享连网。Wifi scan时应寻找的identifier（4-byte）是基于DSID生成，DSID是基于icloud account生成、每24小时rotated。Tethering Target Presence message用于提供identifier信息。Tethering Source Presence message用于提供热点相关能力信息。

Nearby: 一个设备通知附近设备。Nearby Action message: setting up a speaker, 分享wifi密码, 接电话等。Nearby Info message：设备后台同步，不论是否处于锁屏状态，带AuthTag。

### Passive tracking

device address 固定

random Resolvable address 长时间不轮换

authTag的范围不覆盖address，或者说是不同步

AD中含static identifier，例如AirDrop/Nearby场景中的 trunc(hash(email + phone number))

AD中含轮换时间比较长的DSID (4 bytes)/SSID, 例如Tethering Target Presence message

长时间固定不变的message

IV可预测

明文显示的、可预测的data field，例如递增的lid open counter

### Active tracking/linking

replay attack，勾出同account下的设备

corrputed Handoff message：由于IV递增，伪造全0的IV，可以诱导近场所有关联设备主动重连

Global State Number 的规律性可以反向关联

语音控制场景的Perceptual Hash对应的command~

BLE的范围(up to 100m ?!, 61m outdoor, 38m indoor)

## Recommendation

encryption

minimization message

timestamp

device address change & continuity protocol message change 尽量同步

## conclusion

这两句不错，怼人可以用：

security by obscurity does not work.

even companies with extended resources ad dedicated security/privacy teams can not only rely on internal scrutiny of their systems to avoid such issues.


# airdrop

[PrivateDrop: Practical Privacy-Preserving Authentication for Apple AirDrop](https://www.usenix.org/conference/usenixsecurity21/presentation/heinrich)

把private set intersection (PSI) 用到airdrop连接发现上，近场ddos有点问题
