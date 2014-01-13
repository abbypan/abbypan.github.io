---
layout: post
category : tech
title:  "Crypt::OpenSSL::Bignum"
tagline: "大数"
tags : ["perl", "cpan", "crypt", "openssl" ] 
---
{% include JB/setup %}

## win32 下安装 Crypt::OpenSSL::Bignum 0.4 失败

参考：http://www.nntp.perl.org/group/perl.win32.vanilla/2010/04/msg219.html

把Makefile.pl里的

``'LIBS'    => ['-lcrypto'],``

改成 

``'LIBS'    => ($^O eq 'MSWin32') ? ['-leay32'] : ['-lcrypto'],``

即可 
