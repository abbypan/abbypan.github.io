---
layout: post
category : tech
title:  "路由识别 route"
tagline: ""
tags : [ "route", "traceroute" ] 
---
{% include JB/setup %}

分布式 traceroute 全网路由识别

近探测源的前N跳，过滤

路由别名：同一个路由器上的不同接口有着不一样的IP地址

    相同IP前缀；
    近路由器的前N跳（等跳数/不区分跳数）IP相同比例；
    相同探测源到两IP的路径基本相同；

traceroute的IP分类，例如贝叶斯，某个类别对应某些指标取值的条件概率
