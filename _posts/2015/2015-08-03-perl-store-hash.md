---
layout: post
category : tech
title:  "perl : 持久化存储 hash"
tagline: ""
tags : [ "perl", "hash" ] 
---
{% include JB/setup %}

[Storable](https://metacpan.org/pod/Storable) 接口简单，不能存嵌套的hash。跨平台时注意用nstore，不然字节序可能对不上。

[JSON](https://metacpan.org/pod/JSON)  接口简单，hash里面有不同编码数据时会出错。

[JSON::PP](https://metacpan.org/pod/JSON::PP)  支持深层hash，其他与JSON模块基本相同。

[DBM::Deep](https://metacpan.org/pod/distribution/DBM-Deep/lib/DBM/Deep.pod) 接口麻烦点，适合存复杂hash。

参考 [http://perlmaven.com/data-serialization-in-perl](http://perlmaven.com/data-serialization-in-perl)
