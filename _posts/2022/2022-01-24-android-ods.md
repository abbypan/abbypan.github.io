---
layout: post
category: tech
title:  "Android: on device signing"
tagline: ""
tags: [ "android", "security", "ods" ] 
---
{% include JB/setup %}

* TOC
{:toc}

# 概要

on device signing 的核心是：采用本地签名，保障artifacts文件的完整性。兼容支持or不支持fsverity两种场景。

# odsign_main

[odsign_main.cpp](https://cs.android.com/android/platform/superproject/+/master:system/security/ondevice-signing/odsign_main.cpp)

- 生成ods signing key。
- 如果支持fsverity，则把ods signing key对应的自签名cert加入keyring，标识为`fsv_ods`。
- 如果` useCompOs = kUseCompOs && supportsFsVerity && compOsPresent();`为true，则使用ods signing key对compos public key签名生成CompOS leaf cert，将CompOS leaf cert加入keyring，标识为`fsv_compos`。
- 检查 checkCompOsPendingArtifacts ，确认是否有artifacts文件需要refresh。如果有，则compileArtifacts。
- 如果odsrefresh返回ok，则校验` verifyArtifacts(*key, supportsFsVerity)`
- 如果odsrefresh返回compilationSuccess/compilationFailed，则

            if (supportsFsVerity) {
                digests = addFilesToVerityRecursive(kArtArtifactsDir, *key);  //打开文件的fsverity支持
            } else {
                // If we can't use verity, just compute the root hashes and store
                // those, so we can reverify them at the next boot.
                digests = computeDigests(kArtArtifactsDir);  //仅计算文件的digest
            }

- 使用ods signing key对计算得到的digests列表签名，存储签名结果，`persistStatus = persistDigests(*digests, *key);`

# VerityUtils

[VerityUtils.cpp](https://cs.android.com/android/platform/superproject/+/master:system/security/ondevice-signing/VerityUtils.cpp)


odsign的一些基础校验函数。

`static Result<std::vector<uint8_t>> createDigest(int fd)` 生成文件的`merkle_tree digest`

`static Result<std::string> enableFsVerity(int fd, const SigningKey& key)` 使用SigningKey对文件的`merkle_tree digest`签名，并将signture结合SigningKey的公钥信息，转换为pkcs7格式，将pkcs7内容序列化，加入fd的fsverity指针内容。

`Result<void> verifyAllFilesUsingCompOs(const std::string& directory_path, const std::map<std::string, std::string>& digests, const SigningKey& signing_key) ` 从compos digests列表中，一一取出`<file, digest>`检查。如果file已开启fsverity，检查digest是否与file对应的fs verity的digest一致；否则，为文件开启fsverity，即，使用SigningKey计算签名并转为pkcs7并序列化插入fd verity指针内容。

# KeystoreKey

[KeystoreKey.cpp](https://cs.android.com/android/platform/superproject/+/master:system/security/ondevice-signing/KeystoreKey.cpp)

注意ods signing key对应的public key，还用一个keystore保护的hmac key进行完整性保护。

# other 

CertUtils.cpp、 KeystoreHmacKey.cpp 的内容比较简单，主要是按primitive、x.509、pkcs来。

# CompOS

[lib.rs](https://cs.android.com/android/platform/superproject/+/master:packages/modules/Virtualization/compos/common/lib.rs)

[compos_key_cmd.cpp](https://cs.android.com/android/platform/superproject/+/master:/packages/modules/Virtualization/compos/compos_key_cmd/compos_key_cmd.cpp)
