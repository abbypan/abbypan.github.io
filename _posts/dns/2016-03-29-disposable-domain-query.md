---
layout: post
category : tech
title:  "dns : disposable domain query 临时域名查询"
tagline: "note"
tags : [ "dns", "domain" ] 
---
{% include JB/setup %}


[DNS noise: measuring the pervasiveness of temporary domains in modern DNS traffic](http://ieeexplore.ieee.org/xpls/abs_all.jsp?arnumber=6903614)

http://www.potaroo.net/ispcol/2016-03/zombies.html

“正常” 应用场景下的随机域名，如杀毒软件病毒库更新，短ttl

某些以“高频”重复查询，忽略ttl的查询

某些广告插件，临时生成uniq临时域名，只查一次

导致 cache 负担变重而无用 => 分级or热点
