---
layout: post
category: tech
title:  "Vehicle Bus Protocol: CAN"
tagline: ""
tags: [ "can" ] 
---
{% include JB/setup %}

* TOC
{:toc}

# 资料

[Security Authentication System for In-Vehicle Network](http://global-sei.com/technology/tr/bn81/pdf/81-01.pdf)

[Security in Automotive Bus Systems](http://www.weika.eu/papers/WolfEtAl_SecureBus.pdf)


# CAN (Controller Area Network)

[CAN入门书](http://archive.eet-china.com/www.eet-china.com/ARTICLES/2006SEP/PDF/rcj05b0027_can_intro.pdf?SOURCES=DOWNLOAD)

[CAN基础](http://d1.amobbs.com/bbs_upload782111/files_34/ourdev_599225UCE6YK.pdf)

[Introduction to the Controller Area Network (CAN)](http://www.ti.com/lit/an/sloa101b/sloa101b.pdf)

[CAN词典](https://www.can-cia.org/fileadmin/resources/documents/publications/candictionary_v1_cn.pdf)

CAN 控制器根据两根线上的电位差来判断总线电平。

多个单元以CSMA/CD方式访问总线，同时发送则以ID (Identifier) 区分优先级。

标准：ISO11898 (高速，最高1Mbps, 总线最大长度40m/1Mbps，连接单元数最多30)及ISO11519(低速，最高125kbps，总线最大长度1km/40kbps，连接单元数最多20)。

## 帧格式

5种帧：数据帧、遥控帧(向某个单元请求某个ID的数据)、错误帧、过载帧(接收单元通知说尚未准备好接收数据)、帧间隔(将数据帧与遥控帧与前面其他帧分开)。

数据帧和遥控帧有标准格式和扩展格式两种格式。标准格式有11bit的ID，扩展格式有29bit的ID。

IDE = 0 标准帧，IDE = 1 扩展帧

DLC : Data Length Code, 4bit

CAN数据帧组成：帧起始(1bit)，仲裁段(ID 11bit，RTR 1bit), 控制段(6bit，含IDE, r0, DLC 4bit)，数据段(0~64bit)，CRC段(16bit, 含CRC 15bit, CRC界定符 1bit)，ACK段(2bit)，帧结束(7bit)

CAN扩展数据帧组成：帧起始(1bit)，仲裁段(ID 11bit, SRR 1bit, IDE 1bit, Identifier 18bit, RTR 1bit), 控制段(6bit，含r1, r0, DLC 4bit)，数据段(0~64bit)，CRC段(16bit, 含CRC 15bit, CRC界定符 1bit)，ACK段(2bit)，帧结束(7bit)

遥控帧不含数据段。

主要用于车身（车窗、座椅等）、状态（仪表、故障诊断等）、实时控制（发动机控制、变速控制等）系统。不同功能域的CAN总线会连接到网关。

## 安全

CAN协议是完全默认信任的，没有任何认证处理。

任何一个单元都可以发送任意高优先级ID的消息，抢占资源或引发拒绝服务。

任何一个单元都可以伪造其他ID的消息。

任何一个单元都可以窃听其他单元交互的消息。

安全方案：公私钥对+HMAC做认证(预置对端ECU公钥)，AES+HMAC做加密及认证，识别ECU发送的CAN电平信号特征做入侵检测及前期阻断。。。

相关HASH函数：FIP180 SHA2, SHA-256/384/512；FIPS 202, SHA3-224/512。

## CAN FD (FD=Flexible Data-rate)

[CAN FD传统CAN之比较](https://www.kvaser.cn/wp-content/uploads/2015/04/comparing-can-fd-with-classical-can.pdf)

[CAN FD Protocol Specification](https://can-newsletter.org/uploads/media/raw/e5740b7b5781b8960f55efcc2b93edf8.pdf)

[CAN FD - The basic idea](https://www.can-cia.org/can-knowledge/can/can-fd/)

[CAN with Flexible Data-Rate –CAN-FD](http://www.aut.upt.ro/~pal-stefan.murvay/teaching/nes/Lecture_05_CAN-FD.pdf)

减小时延(峰值到8Mbit/s，均值到5.9Mbit/s)，提高带宽，增大Data Length(从8byte扩到64byte)，改进CRC。。。 

CAN FD 标准帧：帧起始(SOF 1bit)，仲裁段（ID 11bit，r1），控制段（IDE, EDL, R0, BRS, ESI, DLC），数据段(0~64byte)，CRC段(CRC 21bit，DEL），ACK段(ACK, DEL)，帧结束(EOF 7bit，ITM 3bit)。

CAN FD 扩展帧：帧起始, 仲裁段(ID 11bit, SRR, IDE, Extended ID 18bit, r1)，控制段(EDL, R0, BRS, ESI, DLC)，。。。

数据字节<16时，CRC为17bit。

EDL(Extended Data Length)用于区分CAN帧与CAN FD帧。

BRS(Bit Rate Switch)用于区分位速率。如果BRS=1 则所有位将与仲裁段使用相同的位速率发送；如果BRS＝0，则仲裁段之后，CRC定界符之前的所有位将使用较高的速率发送。

ESI(Error State Indicator)错误状态指示，主动错误1，被动错误0。

CAN FD中不含遥控帧，直接将CAN帧中的RTR位换成r1，可以直接用做CAN FD帧。

注意CAN FD的Data Length扩展到64字节，DLC字段值使用变长编码（传统CAN帧长度内仍是线性编码）

CAN FD将填充位纳入CRC计算中。。。

明显CAN FD比CAN更合适增加加密、认证等安全措施（数据段变长了）。。。


# LIN

# FlexRay

# MOST

# Bluetooth
