---
layout: post
category: android
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
- 如果`useCompOs = kUseCompOs && supportsFsVerity && compOsPresent();`为true，则使用ods signing key对compos public key签名生成CompOS leaf cert，将CompOS leaf cert加入keyring，标识为`fsv_compos`。检查 checkCompOsPendingArtifacts ，确认是否有artifacts文件需要refresh，如果需要，则`odrefresh_status = compileArtifacts(kForceCompilation);`。
- 如果odsrefresh返回ok，则` verifyArtifacts(*key, supportsFsVerity)`校验每个文件的digest是否与`trusted_digest`相符。
- 如果odsrefresh返回compilationSuccess/compilationFailed，则

            if (supportsFsVerity) {
                digests = addFilesToVerityRecursive(kArtArtifactsDir, *key);  //打开文件的fsverity支持
            } else {
                // If we can't use verity, just compute the root hashes and store
                // those, so we can reverify them at the next boot.
                digests = computeDigests(kArtArtifactsDir);  //仅计算文件的digest
            }

- 使用ods signing key对计算得到的digests列表签名，存储签名结果，`persistStatus = persistDigests(*digests, *key);`

`Result<OdsignInfo> getComposInfo(const std::vector<uint8_t>& compos_key)` 以compos public key校验artifacts文件的digests列表的签名，校验成功，则返回digests列表。

`Result<OdsignInfo> getOdsignInfo(const SigningKey& key)` 以ods signing public key校验artifacts文件的digests列表的签名，校验成功，则返回digests列表。

`art::odrefresh::ExitCode checkCompOsPendingArtifacts(const std::vector<uint8_t>& compos_key, const SigningKey& signing_key, bool* digests_verified) ` 以getComposInfo返回的digests信息为基准，调用verifyAllFilesUsingCompOs确保每一个文件开启fsverity。干完再checkArtifacts返回odsrefresh状态码，如果状态码为ok，则使用ods signing key对getComposInfo返回的digests信息签名，persistDigests。

`Result<void> verifyArtifacts(const SigningKey& key, bool supportsFsVerity)` 以getOdsignInfo返回的`trusted_digests`信息为基准。如果supportsFsVerity，则调用`verifyIntegrityFsVerity(trusted_digests)`检查；否则，调用`verifyIntegrityNoFsVerity(trusted_digests);`检查。

`verifyIntegrityFsVerity(trusted_digests)` 读取每一个artifacts文件的fsverity digest信息，与`trusted_digests`中的digest做比较。

`verifyIntegrityNoFsVerity(trusted_digests)` 对每一个artifacts文件计算digest信息，与`trusted_digests`中的digest做比较。

# VerityUtils

[VerityUtils.cpp](https://cs.android.com/android/platform/superproject/+/master:system/security/ondevice-signing/VerityUtils.cpp)

odsign的一些基础校验函数。

`static Result<std::vector<uint8_t>> createDigest(int fd)` 生成文件的`merkle_tree digest`

`static Result<std::string> enableFsVerity(int fd, const SigningKey& key)` 使用SigningKey对文件的`merkle_tree digest`签名，并将signture结合SigningKey的公钥信息，转换为pkcs7格式，将pkcs7内容序列化，加入fd的fsverity指针内容。

`Result<void> verifyAllFilesUsingCompOs(const std::string& directory_path, const std::map<std::string, std::string>& digests, const SigningKey& signing_key) ` 从compos digests列表中，一一取出`<file, digest>`检查。如果file已开启fsverity，检查digest是否与file对应的fs verity的digest一致，如果不一致，返回错误；否则，为文件开启fsverity，即，使用SigningKey计算签名并转为pkcs7并序列化插入fd verity指针内容。相当于完成compos public key 到 ods signing key 的信任传递。这个主要好处在于后续节省校验路径，信任链问题不大。

# KeystoreKey

[KeystoreKey.cpp](https://cs.android.com/android/platform/superproject/+/master:system/security/ondevice-signing/KeystoreKey.cpp)

注意ods signing key对应的public key，还用一个keystore保护的hmac key进行完整性保护。

# other 

CertUtils.cpp、 KeystoreHmacKey.cpp 的内容比较简单，主要是按primitive、x.509、pkcs来。

# CompOS

[lib.rs](https://cs.android.com/android/platform/superproject/+/master:packages/modules/Virtualization/compos/common/lib.rs)

[compos_key_cmd.cpp](https://cs.android.com/android/platform/superproject/+/master:/packages/modules/Virtualization/compos/compos_key_cmd/compos_key_cmd.cpp)
