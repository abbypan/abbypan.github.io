---
layout: post
category : tech
title:  "DNS relay与 DNS proxy的区别"
tagline: ""
tags : ["dns", "relay", "proxy"] 
---
{% include JB/setup %}

见：http://topic.csdn.net/u/20090217/09/88488b6d-7506-4514-9991-d75071e1fba1.html

wajj1209：

二者都是接收到dns请求包后,转发给dns server,然后等接收到回复包后,再回给PC。

fsxdxh：

relay一般不允许修改消息的内容，而是直接透传给别人，即左手接入，右手发出去。从客户端来看，一般你是能够感知到你是与DNS服务器在通信的。

而proxy表示可以查看并修改转发的消息内容。对于你来说，你只与代理在通信，你不知道代理的后面是什么服务器。 
