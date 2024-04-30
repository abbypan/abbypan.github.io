---
layout: post
category: arm
title:  "arm aarch64交叉编译，支持openssl"
tagline: ""
tags: [ "openssl", "arm" ] 
---
{% include JB/setup %}

* TOC
{:toc}

# install

以debian x86\_64环境为例，交叉编译aarch64，支持openssl

## 安装基础工具

    sudo apt install gcc-aarch64-linux-gnu binutils-aarch64-linux-gnu
    sudo apt install qemu-user

## 添加aarch64软件库

    sudo dpkg --add-architecture arm64
    sudo apt update
    sudo apt install libc6:arm64 libssl-dev:arm64 openssl:arm64

# test

## 新建 main.c

{% highlight c %}
#include<stdio.h>
#include<openssl/bio.h>

    int main()
    {
        unsigned char hc[] = "Hello World!\n";
        BIO_dump_indent_fp(stdout, hc, sizeof(hc), 2);
        return 0;
    }
{% endhighlight %}

## 编译

    aarch64-linux-gnu-gcc main.c -o main.out -lcrypto -lssl

## 执行

    qemu-aarch64 ./main.out

    0000 - 48 65 6c 6c 6f 20 57 6f-72 6c 64 21 0a 00         Hello World!..
