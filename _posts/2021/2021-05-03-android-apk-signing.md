---
layout: post
category: device
title:  "android: apk signing"
tagline: ""
tags: [ "android" ] 
---
{% include JB/setup %}

* TOC
{:toc}

# doc

[Application Signing](https://source.android.com/security/apksigning)

[apksig](https://android.googlesource.com/platform/tools/apksig)

相同public key对应的apk，可以选择share UID。

# apk signature scheme v1

[JAR signing](https://docs.oracle.com/javase/8/docs/technotes/guides/jar/jar.html#Signature_File)

[Android code signing](https://nelenkov.blogspot.com/2013/04/android-code-signing.html)

以下以wechat apk为例

## manifest.mf

manifest.mf 为各资源文件的digest，例如：

    $ cd META-INF
    $ cat ../r/f/bj.xml |openssl dgst -sha1 -binary |openssl base64
    K/y4OJlp+JDHAkGomyWpdsUMK40=

在manifest.mf里表示为

    Name: r/f/bj.xml
    SHA1-Digest: K/y4OJlp+JDHAkGomyWpdsUMK40=

## x.sf

x.sf 为manifest.mf里各资源块摘要信息的二次digest

   $ echo -n "Name: r/f/bj.xml\r\nSHA1-Digest: K/y4OJlp+JDHAkGomyWpdsUMK40=\r\n\r\n" | openssl dgst -sha1 -binary |openssl base64
   RPsYSzcn/QIIfiVAg08OP8hIZJY=

在x.sf里表示为

   Name: r/f/bj.xml
   SHA1-Digest: RPsYSzcn/QIIfiVAg08OP8hIZJY=

### x-Digest-Manifest-Main-Attributes

    $ echo -n "Manifest-Version: 1.0\r\nCreated-By: 1.7.0_45 (Oracle Corporation)\r\n\r\n"  | openssl dgst -sha1 -binary |openssl base64
    sY6+RQ4DWdnxCfSpiwTT6GRIwA0=

x.sf 中包含manifest.mf的头部main attributes的摘要信息

    SHA1-Digest-Manifest-Main-Attributes: sY6+RQ4DWdnxCfSpiwTT6GRIwA0=


### x-Digest-Manifest

    $ cat MANIFEST.MF| openssl dgst -sha1 -binary |openssl base64
    NTBvqC+3bBhUhQAKSFjl2tsMuOI=

x.sf 中包含对manifest.mf的摘要信息

    SHA1-Digest-Manifest: NTBvqC+3bBhUhQAKSFjl2tsMuOI=

## x.rsa

查看pkcs7签名文件

    $ openssl asn1parse -i -inform DER -in x.rsa

查看cert

    $ keytool -printcert -file x.rsa

导出cert & pubkey

    $ openssl pkcs7 -inform DER -print_certs -out cert.pem -in x.rsa
    $ openssl x509 -in cert.pem -pubkey -noout > pubkey.pem

校验pkcs7签名文件

    $ openssl smime -verify -binary -inform DER -in x.rsa -content x.sf -certfile cert.pem -nointern -noverify >/dev/null
    Verification successful

从pkcs7中提取x.sig：

[How can I extract certificates contained in an ashx file with openssl?](https://stackoverflow.com/questions/34319168/how-can-i-extract-certificates-contained-in-an-ashx-file-with-openssl)

    $ openssl dgst -md5 -verify pubkey.pem -signature x.sig x.sf

## summary

解压后才能进行签名校验

仅能确保manifest.mf中的文件完整性

难以防御添加文件重新打包的攻击

# apk signature scheme v2, android 7

{ 1. Contents of ZIP entries, 2. APK Signing Block, 3. ZIP Central Directory, 4. ZIP End of Central Directory }

section 2 的 apk signing block 用于校验其他3个section的完整性, block ID 0x7109871a。

section 1, 3, 4 构造一个双层merkle tree：
- 每个section拆成1MB的chunks，每个chunk计算digest(0xa5, chunk's length, chunk's content)
- 顶层digest(0x5a, number of chunks, concatenation of digests of chunks)

## rollback protection

为防止rollback回v1 signature，可以在`META-INF/*.SF`中添加 X-Android-APK-Signed : 2

此时，对于支持v2 signature校验的platform，重打包攻击无法生效

## 校验

先验签（确保签名ok、选择强度最高的algorithm ID)

确保digest与signature指定的algorithm ID一致

再验merkle tree

最后验certificate(签名校验的pubkey必须与first certificate的publkey一致、确保能验到一个见过的/首次见的signer)

# apk signature scheme v3, android 9

v3 签名的结构体与 v2签名基本一致, section 2 的 block ID 0xf05368c0。

支持指定minSDK, maxSDK，限定版本范围。

支持key rotation，即通过certificate chain链式信任，支持更新signing key。

## 校验

先验签

再检查minSDK, maxSDK

确保digest与signature指定的algorithm ID一致

再验merkle tree

确保签名校验的pubkey必须与first certificate的publkey一致

如果proof-of-rotation设定了ID 0x3ba06f8c, 确保last certificate中的signer为旧的signer

确保能验到一个见过的/首次见的signer

# apk signature scheme v4, android 11

v4签名的merkle tree与fs-verity的hash tree格式相同

签名文件单独存放于`<apk name>.apk.idsig`，包含内容：
- version
- `hasing_info`： 构造merkle tree的参数(`hash_algorithm, log2_blocksize, salt`)、`root_hash`
- `signing_info`: 签名信息(`apk_digest`从v3/v2 Signing block中提取，证书相关信息，签名相关信息)
- `merkle_tree`: 可选

签名的predata包含：签名文件大小、`hasing_info`、`signing_info`的`apk_digest`/证书等相关信息

## `apk_digest`

`apk_digest` is the first available content digest in order

## incremental 

[Incremental File System](https://source.android.com/devices/architecture/kernel/incfs)

merkle tree的特性，天然适合增量安装

即签名校验通过后，优先安装指定偏移量的文件块，剩下的再慢慢装

适用于游戏包的安装场景，先装启动必须的，再装资源文件
