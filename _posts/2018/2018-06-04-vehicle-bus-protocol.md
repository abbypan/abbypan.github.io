---
layout: post
category: tech
title:  "Vehicle Bus Protocol: CAN, LIN, FlexRay, MOST"
tagline: ""
tags: [ "vehicle", "can", "lin", "flexray", "most" ] 
---
{% include JB/setup %}

* TOC
{:toc}

# 资料

[Security Authentication System for In-Vehicle Network](http://global-sei.com/technology/tr/bn81/pdf/81-01.pdf)

[Security in Automotive Bus Systems](http://www.weika.eu/papers/WolfEtAl_SecureBus.pdf)

[Awesome Vehicle Security](https://github.com/jaredthecoder/awesome-vehicle-security)

[Basics of In-Vehicle Networking (IVN) Protocols](http://www.onsemi.cn/PowerSolutions/document/TND6015-D.PDF)

[Introduction In-Vehicle-Networking](https://www.youtube.com/watch?v=DeQb8Q6hEkA)

[Automotive Bus Systems](https://theeshadow.com/files/S40MY2005/pg29_32_autobussyste.pdf)

# CAN (Controller Area Network)

[Introduction to CAN](https://elearning.vector.com/index.php?wbt_ls_kapitel_id=1329975&root=378422&seite=vl_can_introduction_en)

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


# LIN (Local Interconnect Network)

[LIN Specification](https://elearning.vector.com/index.php?wbt_ls_kapitel_id=508184&root=378422&seite=vl_sbs_introduction_en)

[LIN入门](http://www.jingbei.com/xxpdf/R8C%20lIN%E5%85%A5%E9%97%A8.pdf)

[LIN Protocol and Physical Layer Requirements](http://www.ti.com/lit/an/slla383/slla383.pdf)

[LIN Bus](http://www.wangdali.net/lin/)

[Introduction to the Local Interconnect Network (LIN) Bus](http://sine.ni.com/np/app/main/p/ap/icomm/lang/en/pg/1/sn/n17:icomm,n21:9536/fmid/2955/)

ISO 17987，SAE（Society of Automotive Engineers）负责分配ID。

串行通信协议，1主N从式的结构，由master发指令，对应的slave应答。master接入上层ecu。

12V电压，节点数<=16，最高20kbps，适用于远距离节点间的低速通信。

主要应用在车身系统(对安全和整车性能影响不大)，比如门窗、雨刮、空调、座椅、照明、后视镜。

由进度表schedule控制frame时隙。master节点必须设置较高精度的时钟(作为时间基准，保证位速率），而slave节点则不必。


## 帧格式

帧由两部分组成：帧头（master发送）、应答（slave发送）。

帧头Header：sync break (14bit), sync (10bit), PID (Protect Identifier, 10bit)

应答Response：Data(10~80bit)，checksum(10bit)

## 帧类型

无条件帧 Unconditional Frame：一旦有帧头发出，必须有从机无条件应答

事件触发帧 Event Triggered Frame：一次查询多个slave信号是否发生变化。只有变化的slave才需要应答；如果所有slave都没变化则该帧只有头部段没有应答段；如果有多个slave变化导致应答冲突，则通过进度表解决冲突，进行轮询处理。

偶发帧 Sporadic Frame：master的信号发生改变，此时master作为发布节点(sender)，把信号发给slave节点。

诊断帧 Diagnostic Frame：主要用于配置、识别和诊断。master作为sender的帧ID为0x3C，slave作为sender的帧ID为0x3D。

保留帧 Reserved Frame：帧ID为0x3E/0x3F，用于未来扩展。

## 规范

LIN规范定义配置功能的服务时，参照了ISO制定的UDS(Unified DiagnosticServices，车辆统一诊断服务)标准和OBD(On-board Diagnostic，车载自动诊断)标准。配置功能各项服务及其SID都是ISO标准的子集。

Node Capability Files(NCF), 定义了节点名称和节点的属性值，包括产品代号、位速率、帧的定义等信息。

LIN Description File (LDF)，LIN子网设计工具收集到节点性能文件的信息，自动生成LIN描述文件(LDF)。LDF包含了整个子网的信息，包括所有的信号和帧的声明，以及进度表等信息。

## 安全

LIN比CAN更加简单，主要在于master节点、以及master节点上级ECU的安全控制。

slave节点由于计算资源限制，除了接收master指令外，一般别无处理。

# FlexRay

[FlexRay Specification](https://elearning.vector.com/index.php?wbt_ls_kapitel_id=508201&root=378422&seite=vl_sbs_introduction_en)

[The FlexRay Protocol](https://www.ece.cmu.edu/~ece649/lectures/23_flexray.pdf)

[FlexRay Module Training](http://www.ti.com/lit/ml/sprt718/sprt718.pdf)

[FlexRay Communications System Protocol Specification](https://svn.ipd.kit.edu/nlrp/public/FlexRay/FlexRay%E2%84%A2%20Protocol%20Specification%20Version%203.0.1.pdf)

[FlexRay 通訊協定與設計](https://www.artc.org.tw/upfiles/ADUpload/knowledge/tw_knowledge_IA-96-0025.pdf)

[Overview of FlexRay scheduling issues](http://retis.sssup.it/~marco/files/lesson10-introduction_to_FlexRay.pdf)

FlexRay 主要用于线控(X-by-Wire)、底盘控制、引擎控制、动力总成。

高带宽、高容错(确定性)、低延迟，单channel最高10Mbps，双channel可以达到20Mbps(非冗余模式)。

节点不需要同时连两个channel，也可以只连一个channel。

支持总线、星形拓扑。

支持频率、相位同步，单节点故障不会干扰其他节点的同步。

## 帧格式

含3个部分：Header, Payload, Trailer

Header: Indicator(5bit, Reserved, Payload Preamble, Null Frame Indicator, Sync Frame Indicator, Start Frame Indicator), ID(11bit), Payload Length(7bit), CRC(11bit), Cycle Count(6bit)

Payload: 0~254 Bytes

Trailer: CRC(24bit)

可见11bit的ID支持定义2048种FlexRay帧。

Header里的CRC针对前面的内容进行校验。

## 分时

TDMA (Time Division Multiple Access) 分时

每个Cycle含四个部分：Static Communication Segment, Dynamic Communication Segment, Symbol Window, Network Idle Time

Static Communication Segment内按frame ID，每种帧获得固定的时间

Dynamic Communication Segment内如果某个frame ID没有发消息，则在指定的短时间内结束该frame ID占用的time slot，轮到下一个frame ID

## 安全

FlexRay 主要优势是通过分时time slot确定传输的frame，避免冲突。其次是低时延、以及相比于CAN的高吞吐量。

总线拓扑问题与CAN相同，默认也没有针对Frame ID来源合法性校验，网关增强。。。

星形拓扑可以在star节点做一些处置。

# MOST (Media Oriented Systems Transport)

[Media Oriented Systems Transport (MOST)](https://vector.com/vi_most_en.html)

[MOST: THE AUTOMOTIVE MULTIMEDIA NETWORK](http://www.ciando.com/img/books/extract/3645250611_lp.pdf)

[MOST150 – The Next Generation Automotive Infotainment Backbone](https://www.mouser.com/pdfdocs/Microchip-Next-Generation-Automotive-Infotainment.pdf)

[Bridging MOST to IEEE Standards](http://www.ieee802.org/1/files/public/docs2012/new-Bridging-MOST-Muyshondt-Bridging-MOST-to-IEEE-Standards-0712.pdf)

[Vehicle Networks Multimedia Protocols](https://www.sti-innsbruck.at/sites/default/files/courses/fileadmin/documents/vn-ws0809/06-VN-MultimediaNetworks.pdf)

[New elements in vehicle communication “media oriented systems transport” protocol](http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.1006.4793&rep=rep1&type=pdf)

[MOST Technology Report - MOST Cooperation](https://www.mostcooperation.com/publications/.../most-technology-report/)

一般是环形拓扑，最多64个节点，节点即插即用。也可采用星形，或双环。

有一个Time Master节点负责向ring发布frame，其他Time Slave节点保持同步。25Mbps~150Mbps，光纤，主要用于车载娱乐系统(音频，视频，数据）。60 Channels.

Every slave synchronizes with the frame preamble by a Phase-Locked Loop (PLL)

MOST提供控制指令的信道，也可以用专用信道tunnel Ethernet Communication。

## 帧格式

MOST25, 64Bytes: Preamble, Boundary Descriptor, Synchronous channel, Asynchronous Packet Data channel, Control channel 2Bytes, Frame Control, Parity Bit

MOST50, 128Bytes: Control 4Bytes, Synchronous, Asynchronous Packet Data Channel

MOST150, 384Bytes: Control 4Bytes, Synchronous/isochronous streaming channel, Asynchronous Packet Channel/Most Ethernet Packet (MEP) Channel

## Ethernet over MOST150

[Interfacing to the MOST Ethernet Channel](http://www.ieee802.org/1/files/public/docs2013/AC-Muyshondt-InterfacingMOSTEthernetChannel-0713-v01.pdf)

## 安全

娱乐系统一般很少有入侵动机，除非做为攻击跳板。

MOST frame比较大，传输关键channel数据的时候可加校验。

# Automotive Ethernet

[Automotive Ethernet:  An Overview](https://support.ixiacom.com/sites/default/files/resources/whitepaper/ixia-automotive-ethernet-primer-whitepaper_1.pdf)

[Automotive Ethernet Specifications](http://www.opensig.org/Automotive-Ethernet-Specifications/)

