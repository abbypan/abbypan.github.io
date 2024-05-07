---
layout: post
category: device
title:  "Android: Remote Key Provision (RKP)"
tagline: ""
tags: [ "rkp", "dice", "android" ] 
---
{% include JB/setup %}

* TOC
{:toc}

# doc

[Android RemoteProvisioner](https://cs.android.com/android/platform/superproject/+/master:packages/apps/RemoteProvisioner/src/com/android/remoteprovisioner/)

[Android RemoteProvisioning](https://cs.android.com/android/platform/superproject/+/master:out/soong/.intermediates/system/security/keystore2/aidl/android.security.remoteprovisioning-java-source/gen/android/security/remoteprovisioning/)

[Android Keymint v1](https://cs.android.com/android/platform/superproject/+/master:out/soong/.intermediates/hardware/interfaces/security/keymint/aidl/android.hardware.security.keymint-V1-java-source/gen/android/hardware/security/keymint/)

# 概要

rkp的核心在于替换原有的工厂预置attestation key的模式，达到device unique level的远程provision。

工厂收集device info & `DK_pub`(BCC 上游 public key，或者随机生成的自签名public key)，同步给google。

google通过识别`DK_pub`，确认终端attestation cert request的合法性；通过检查bcc中的device信息，确认device的安全状态；最终决策是否签发attestation certificate。

attestation certificate为短周期(30天)有效，定期resume。

[device info.aidl](https://cs.android.com/android/platform/superproject/+/master:hardware/interfaces/security/keymint/aidl/android/hardware/security/keymint/DeviceInfo.aidl)

# attestation certificate 签发流程

- device provisioner 向google server请求GEEK相关信息。注意device应检查google server通信证书的合法性。
- google server返回GEEK相关信息：主要包含一个临时公钥geek，一个challenge，geek在google证书链下签名（证书链+签名也一并返回）。
- device provisioner向keystore请求genCertReq(N, GEEK)。
- keystore请求keymint生成N个公私钥对，并由keymint执行genCertReq(pubKeys, GEEK)。
- keymint应检查GEEK的合法性。
- keymint向keystore返回protected data，包含使用GEEK进行ECIES加密的: BCC, 临时生成的mac key即`ek_mac`, signature({challenge, `device info`, `ek_mac`} 由`KM_priv`签名）。参考[ProtectedData.aidl](https://cs.android.com/android/platform/superproject/+/master:hardware/interfaces/security/keymint/aidl/android/hardware/security/keymint/ProtectedData.aidl)
- keystore构造cert request，主要包含：device info, challenge, protected data, MacedKeysToSign(待签发的pubKeys由`ek_mac`计算mac)。参考keymint/IRemotelyProvisionedComponent.java、[MacedPublicKey.aidl](https://cs.android.com/android/platform/superproject/+/master:hardware/interfaces/security/keymint/aidl/android/hardware/security/keymint/MacedPublicKey.aidl)。
- provisioner向google server提交cert request。
- google server校验cert request，签发certificates，返回给provsioner。
- provisioner交由keystore存储certificates。

测试: EEK response 如果没有传入Google的证书链，则为测试场景下使用的EEK。

# 算法

- 签发的attestation certificates为P-256，格式x.509v3。
- 执行RKP签发过程时使用 ED25519签名/X25519通信，格式COSE/CBOR。

# 信任关系

BCC Root = `DK_pub` -> ... -> BCC Leaf = `KM_pub` -> mac key -> public keys 

- 过渡：`DK_pub`工厂随机生成，`BCC Root`=`DK_pub` = `KM_pub`
- BCC：`DK_pub`通过DICE机制生成，`BCC Root = DK_pub -> ... -> KM_pub`

# `DK_pub`同步

`DK_pub`可以直接工厂同步。

`DK_pub`还可以在出厂后首次boot时，与google server联网上报。上报`DK_pub`的流程与联网签发attestation certificates流程类似，区别主要在于：此时没有需要签发的pubKeys，即N=0; google server不返回attestation cert，而是登记`DK_pub`。
- `DK_pub` 可以由SoC Vendor Root签名/Strongbox Vendor Root签名/OEM 签名/自签名，参考[ProtectedData.aidl]中的AdditionalDKSignatures。
- 工厂提前向google server同步对应的root public key；工厂签发DKCertChain。
