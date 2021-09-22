---
layout: post
category: tech
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

工厂收集device info & `DK_pub`(BCC上游的public key，或者随机生成的自签名public key)，同步给google。

google通过识别`DK_pub`，确认终端attestation cert request的合法性；通过检查bcc中的device信息，确认device的安全状态；最终决策是否签发attestation certificate。

attestation certificate为短周期(30天)有效，定期resume。

# attestation certificate 签发流程

- device provisioner 向google server请求GEEK相关信息。注意device应检查google server通信证书的合法性。
- google server返回GEEK相关信息：主要包含一个临时公钥geek，一个challenge，geek在google证书链下签名（证书链+签名也一并返回）。
- device provisioner向keystore请求genCertReq(N, GEEK)。
- keystore请求keymaster生成N个公私钥对，并由keymaster执行genCertReq(pubKeys, GEEK)。
- keymaster向keystore返回protected data，包含使用GEEK进行ECIES加密的: BCC, 临时生成的mac key即`ek_mac`, signature({challenge, `device info`, `ek_mac`} 由`DK_priv`签名）。参考[ProtectedData.aidl](https://cs.android.com/android/platform/superproject/+/master:hardware/interfaces/security/keymint/aidl/android/hardware/security/keymint/ProtectedData.aidl)
- keystore构造cert request，主要包含：device info, challenge, protected data, MacedKeysToSign(待签发的pubKeys由`ek_mac`计算mac)。参考keymint/IRemotelyProvisionedComponent.java、[MacedPublicKey.aidl](https://cs.android.com/android/platform/superproject/+/master:hardware/interfaces/security/keymint/aidl/android/hardware/security/keymint/MacedPublicKey.aidl)。
- provisioner向google server提交cert request。
- google server校验cert request，签发certificates，返回给provsioner。
- provisioner交由keystore存储certificates。

# 算法

- 签发的certificates为P-256，格式x.509v3。
- 执行RKP签发过程时使用 ED25519签名/X25519通信，格式COSE/CBOR。

# 信任关系

BCC -> `DK_pub` -> mac key -> public keys
- 如果没有BCC：`DK_pub`工厂随机生成，Root -> `DK_pub`, 自签名/SoC Vendor/Strongbox Vendor/OEM签名都行，参考[ProtectedData.aidl]中的AdditionalDKSignatures。
- 如果有BCC：工厂同步的是BCC上游的public key，则`DK_pub`应通过device联网上报, google server校验后信任。上报流程与签发流程类似，区别仅在于此时没有需要签发的pubKeys，即N=0。

Google -> GEEK
- 如果没有传入Google的证书链，则为测试场景下使用的EEK。
