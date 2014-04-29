---
layout: post
category : tech
title:  "perl Crypt::OpenSSL::Random 随机数"
tagline: "random"
tags : ["perl", "cpan", "crypt", "openssl" ] 
---
{% include JB/setup %}

## win32 下安装 Crypt::OpenSSL::Random 0.4 失败

见：http://www.nntp.perl.org/group/perl.win32.vanilla/2010/04/msg219.html

把Makefile.pl里的

``'LIBS'    => ['-lssl -lcrypto'],``

改成 

``'LIBS'    => ($^O eq 'MSWin32') ? ['-lssl32 -leay32'] : ['-lssl -lcrypto'],``

即可 
