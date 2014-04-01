---
layout: post
category : tech
title:  "traceroute"
tagline: ""
tags : [ "network", "traceroute" ] 
---
{% include JB/setup %}

traceroute用于跟踪UDP包从本地到远程主机的路线，在追踪路径时，使用了小的TTL值及一个无效端口号。

开始将TTL置1，往前探测中间网关每次将TTL值加1。网关接收到数据，TTL减1；如果TTL=0，此时目的主机收到这个UDP包，然后向源端发送一个端口不可达的ICMP报文。

traceroute将列出从每个网关获得超时消息的时间。每次都发3个包，因此每个中间路由器都有3个往返时延值。如果有包丢失，就在丢包的路由器项后面加``*``号。

当目的端收到traceroute的数据包，将会返回一个端口不可达的消息，此时traceroute知道已经到达目的地，结束追踪。
