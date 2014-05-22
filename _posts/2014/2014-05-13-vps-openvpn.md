---
layout: post
category : tech
title:  "在 vps 搭建 openvpn 服务，通过windows/android/iphone访问"
tagline: ""
tags : [ "openvpn", "vps", "iphone", "android", "windows", "itools" ] 
---
{% include JB/setup %}

# server端

## 安装openvpn服务，生成client的key/crt文件

[bandwagonhost的VPS一键安装OpenVPS](http://www.goagent.biz/thread-1362-1-1.html)

[CentOS上OpenVPN的安装与使用](http://www.oschina.net/question/54100_26864)

[Linode VPS OpenVPN安装配置教程(基于Debian/Ubuntu)](http://www.vpser.net/build/linode-install-openvpn.html)

## openvpn的配置文件示例

假设服务器ip为``xxx.xxx.xxx.xxx``

server端生成的ca文件为``ca.crt``

server端生成的client文件为``client1.crt``、``client1.key``

则可以制作一个``client1.ovpn``配置文件，大概格式如下

    client
    dev tun      
    proto tcp
    remote xxx.xxx.xxx.xxx 8080
    resolv-retry infinite
    nobind
    persist-key
    persist-tun

    <ca>
    ca.crt的内容
    </ca>

    <cert>
    client1.crt的内容
    </cert>

    <key>
    client1.key的内容
    </key>

    ns-cert-type server
    redirect-gateway
    keepalive 20 60
    #tls-auth ta.key 1
    comp-lzo
    verb 3
    mute 20
    route-method exe
    route-delay 2


# client端

将``client1.ovpn``导入openvpn客户端，即可正常连接

## android

[Android 4.x 设置 (OpenVPN方式)](https://www.grjsq.me/shiyong/90.html)

把``client1.ovpn``拷到sd卡就可以用

## iphone

[IOS系统(iPhone,iPad,iTouch)OPENVPN设置教程](http://jingyan.baidu.com/article/f0e83a25da438222e5910193.html)

注：也可以用 [itools](http://www.itools.cn/) 导入``client1.ovpn``

## windows 

[bandwagonhost的VPS一键安装OpenVPS](http://www.goagent.biz/thread-1362-1-1.html)
