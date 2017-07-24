---
layout: post
category : "freedom"
title:  "访问互联网：ssh 远程登陆配置，ssh tunnel配置"
tagline: "笔记"
tags : [ "great.w", "ssh", "socks5" ]
---
{% include JB/setup %}

* TOC
{:toc}

# 说明

ssh tunnel的优点：十分稳定，连接比较快

ssh tunnel的缺点：windows下要装个ssh client，ios不越狱tunnel支持不好

建议：android / linux / windows 下使用

改进方案：linux下安装polipo，将socks5转换为http proxy，android / ios 下配置wlan连接使用该http proxy。比openvpn速度快很多。

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

## 浏览器pac文件示例（黑名单），默认直连

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

## 浏览器pac文件示例（黑白名单），默认代理

{% highlight bash %}
var direct = 'DIRECT';
var http_proxy = 'SOCKS5 127.0.0.1:7070; DIRECT';
var white_list = [
".cn", 
".com.cn",
".qq.com",
".jd.com",
".360buyimg.com",
".baidu.com",
".bdstatic.com",
".douban.com",
"weibo.com",
".taobao.com",
".alipay.com",
".alicdn.com", 
".taobaocdn.com"
];

var black_list = [
"google.com", 
"youtube.com"
];

function FindProxyForURL(url, host) {
    if(! host) return direct;

    for (var i = 0; i < black_list.length; i += 1) {
        var v = black_list[i];
        var dotv = '.' + v;
        if ( dnsDomainIs(host, dotv) || dnsDomainIs(host, v)) {
            return http_proxy;
        }
    }

    for (var i = 0; i < white_list.length; i += 1) {
        var v = white_list[i];
        var dotv = '.' + v;
        if ( dnsDomainIs(host, dotv) || dnsDomainIs(host, v)) {
            return direct;
        }
    }

    return http_proxy;
};
{% endhighlight %}

## ssh 保持连接

参考 [Keep Your Linux SSH Session From Disconnecting](http://www.howtogeek.com/howto/linux/keep-your-linux-ssh-session-from-disconnecting/)，在``~/.ssh/config``中添加
{% highlight bash %}
Host *
  ServerAliveInterval 60
{% endhighlight %}

## 将本地 socks5 转换为http proxy

[通过 Socks5 Proxy 实现 HTTP Proxy](http://cs-cjl.com/2014/10/29/http_proxy)

[archlinux polipo](https://wiki.archlinux.org/index.php/Polipo_%28%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87%29)

{% highlight bash %}
# /etc/polipo/config
proxyAddress = "0.0.0.0"
proxyPort = 7007
socksParentProxy = "127.0.0.1:7008"
socksProxyType = socks5
{% endhighlight %}

直接执行``sudo polipo``即可成功开启本地http proxy

测试： ``curl -x 127.0.0.1:7007  http://ipinfo.io``

### 手机使用本地http proxy访问外网

假设本地开启http proxy的机器内网ip为 192.168.1.111。

全局proxy：

android 无线配置：在wlan ssid名称处长按，选择“高级选项”，填入本地http proxy地址 192.168.1.111 、端口 7007。

ios配置与android类似。

指定某些app使用proxy：

anroid 可安装 [ProxyDroid](https://play.google.com/store/apps/details?id=org.proxydroid)，需要root权限

# socks tunnel使用方法（简易版）

假设已购买了vps，ip地址为xxx.xxx.xxx.xxx，用户名为someusr，密码为somepasswd

WINDOWS系统

下载 [plink](http://www.chiark.greenend.org.uk/%7Esgtatham/putty/download.html)

本地新建一个 p.bat 文件，其内容为

    plink -C -D 8888 -N someusr@xxx.xxx.xxx.xxx -pw somepasswd

将p.bat保存在与plink.exe相同目录下。

双击p.bat，运行，遇到提示信息选择 y (yes)，此时本地端口为8888，不要关闭窗口。

以firefox浏览器为例，下载并安装：[firefox-portable-install](http://portableapps.com/apps/internet/firefox_portable)

打开firefox-portable，option配置如下：

![firefox-socks](/assets/posts/firefox_socks.png)

配置完毕后直接测试访问google。

