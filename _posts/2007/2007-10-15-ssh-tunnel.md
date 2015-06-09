---
layout: post
category : 穿越火线
title:  "访问互联网：ssh 远程登陆配置，ssh tunnel配置"
tagline: "笔记"
tags : [ "ssh", "plink", "pac", "tunnel", "socks5", "sshpass" ]
---
{% include JB/setup %}

ssh tunnel的优点：十分稳定，连接比较快

ssh tunnel的缺点：windows下要装个ssh client，ios不越狱tunnel支持不好

建议：android / linux / windows 下使用

# 使用ssh进行远程登录

假设远程机子叫remote，地址为xxx.xxx.xxx.xxx，用户名为someuser

## 输密码

### 每次手动输密码

ssh xxx.xxx.xxx.xxx -l someuser

### 直接命令行传密码

需要预先安装 sshpass

sshpass -p somepasswd ssh someuser@xxx.xxx.xxx.xxx

## 不输密码（公钥认证）

在本地用ssh-keygen -t rsa生成 remote_rsa/remote_rsa.pub的密钥对，要求输passphrase时可以置空，不然登录的时候虽然不用输密码，passphrase又逃不掉了。

把本地生成的remote_rsa.pub传到remote上的/home/someuser/.ssh/目录下，并改名为authorized_keys。

在本地用``ssh -i remote_rsa someuser@xxx.xxx.xxx.xxx``命令进行远程登录。 

### 存入配置文件

也可以写入本地``~/.ssh/config``文件，后续可以用 ssh someuser@remote 直接登陆

注意remote_rsa是私钥

    Host remote
        HostName xxx.xxx.xxx.xxx
        Port 22
        User someuser
        IdentityFile ~/.ssh/remote_rsa


### 批量免登陆

批量指定多台机器免登陆

```
Host *.xxx.com
    IdentityFile ~/.ssh/remote_rsa
    User someuser
```

### 多层ssh

参考：[transparent multi hop](http://sshmenu.sourceforge.net/articles/transparent-mulithop.html)

假设登陆顺序： 本地 -> middle -> remote

假设middle登陆端口为12345，remote登陆端口为23456

在三台机器上安装netcat

``公钥认证``配置，使得：``本地``能够不输密码登陆middle，middle能够不输密码登陆``remote``

本地``.ssh/config``示例

    Host middle
    User miduser
    Hostname mid.xxx.com
    Port 12345
    PreferredAuthentications publickey
    IdentityFile ~/.ssh/middle_rsa

    Host remote
    Hostname rem.yyy.com
    User remuser
    ProxyCommand ssh -q middle nc -q0 %h 23456

middle上的``.ssh/config``示例

    Host remote
    User remuser
    Hostname rem.yyy.com
    Port 23456
    PreferredAuthentications publickey
    IdentityFile ~/.ssh/remote_rsa

# ssh tunnel

## android 

安装 sshtunnel app，配置host相关信息即可

## linux环境

``ssh someuser@remote -N -D 127.0.0.1:7070 -F ~/.ssh/config``

## windows环境

下载 [plink](http://www.chiark.greenend.org.uk/~sgtatham/putty/download.html)

根据用户名、密码登录： ``plink -C -D 7070 -N someuser@xxx.xxx.xxx.xxx -pw somepasswd``

根据用户名、私钥登录： ``plink -C -D 7070 -N someuser@xxx.xxx.xxx.xxx -i private.ppk``

### 将文本形式的私钥文件 remote_rsa.key 转换成 putty可用的ppk文件

打开 PuTTYgen

选择conversions -> import key，载入 remote_rsa

选择save private key，生成 private.ppk

![puttygen](/assets/posts/puttygen.jpg)

## 浏览器pac文件示例

{% highlight bash %}
var direct = 'DIRECT';
var http_proxy = 'SOCKS5 127.0.0.1:7070; DIRECT';

var tunnel_list = [
"gmail.com",
"google.com",
"google.com.hk",
"googleapis.com"
];

function FindProxyForURL(url, host) {
    if(! host) return direct;
    for (var i = 0; i < tunnel_list.length; i += 1) {
        var v = tunnel_list[i];
        if ( dnsDomainIs(host, v)) {
            return http_proxy;
        }
    }
    return direct;
};
{% endhighlight %}
