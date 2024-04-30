---
layout: post
category: android
title:  "Android: selinux"
tagline: ""
tags: [ "android" ] 
---
{% include JB/setup %}

* TOC
{:toc}

# doc

[Security-Enhanced Linux in Android](https://source.android.com/security/selinux)


允许/不允许：什么进程(domain)访问什么对象(type)下的什么类型(class)的资源，授予什么权限(permission)

    allow domains types:classes permissions;

    neverallow { domain -debuggerd -vold -dumpstate -system_server } self:capability sys_ptrace;

